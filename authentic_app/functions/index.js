/**
 * Cloud Functions for Imagi Auction (needs the Firebase Blaze plan).
 *
 * Notifications
 *   pushOnNotification     users/{uid}/notifications doc -> FCM push (respects
 *                          users/{uid}.notificationPrefs)
 *   endingSoonAlerts       every 5 min: "1 hour left" / "10 minutes left" to
 *                          watchers and bidders (once each, flags on listing)
 *   paymentReminders       every 6 h: remind winners whose payBy is < 24 h away
 *
 * Auctions
 *   closeExpiredAuctions   every minute: close auctions past endsAt
 *   onListingSold          listing -> "sold": create orders/{listingId}
 *
 * Payments (Xendit Invoice, test mode)
 *   createInvoice          callable: recompute total, create/reuse invoice
 *   xenditWebhook          HTTPS: PAID/SETTLED -> order "paid"
 *
 * Orders & reputation
 *   onOrderUpdated         shipped / delivered -> notify buyer
 *   autoCompleteDelivered  daily: delivered > 3 days -> completed
 *   onFeedbackCreated      recompute feedbackScore / positivePct / ratingCount
 *   syncPublicProfile      users/{uid} -> publicProfiles/{uid} (public data only)
 *
 * Account
 *   deleteAccount          callable: delete personal data + Auth user
 */
const {onDocumentCreated, onDocumentUpdated, onDocumentWritten} =
  require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onCall, onRequest, HttpsError} = require("firebase-functions/v2/https");
const {setGlobalOptions, logger} = require("firebase-functions/v2");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue, Timestamp} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {getAuth} = require("firebase-admin/auth");
const config = require("./config");

initializeApp();
setGlobalOptions({region: config.REGION, maxInstances: 10});

const db = getFirestore();

// Secrets live in Google Secret Manager, never in the app:
//   firebase functions:secrets:set XENDIT_SECRET_KEY
//   firebase functions:secrets:set XENDIT_CALLBACK_TOKEN
const XENDIT_SECRET_KEY = defineSecret("XENDIT_SECRET_KEY");
const XENDIT_CALLBACK_TOKEN = defineSecret("XENDIT_CALLBACK_TOKEN");

const DAY = 24 * 60 * 60 * 1000;
const rupiah = (n) =>
  "Rp " + Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
const masked = (name) => {
  const t = (name || "").trim();
  if (t.length === 0) return "***";
  if (t.length === 1) return `${t}***`;
  return `${t[0]}***${t[t.length - 1]}`;
};

/** Writes an in-app notification (pushOnNotification turns it into a push). */
function notify(writer, to, {type, title, body, listingId, orderId}) {
  const ref = db.collection(`users/${to}/notifications`).doc();
  const data = {
    type,
    title,
    body,
    listingId: listingId || null,
    fromUid: "system",
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  };
  if (orderId) data.orderId = orderId;
  return writer.set(ref, data);
}

// ===========================================================================
// Notifications
// ===========================================================================

/** Maps a notification type to its key in users/{uid}.notificationPrefs. */
function prefKeyFor(type) {
  return {
    outbid: "outbid",
    ending_soon: "endingSoon",
    won: "wonLost",
    lost: "wonLost",
    new_bid: "newBid",
    reserve_met: "reserveMet",
    sold: "orders",
    unsold: "orders",
    payment_reminder: "orders",
    payment_received: "orders",
    shipped: "orders",
    delivered: "orders",
    second_chance: "secondChance",
  }[type];
}

exports.pushOnNotification = onDocumentCreated(
  "users/{uid}/notifications/{notificationId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const n = snap.data();
    const {uid, notificationId} = event.params;

    const userRef = db.doc(`users/${uid}`);
    const user = await userRef.get();
    if (!user.exists) return;

    // Respect the user's notification settings (push on by default).
    const key = prefKeyFor(n.type);
    const prefs = user.get("notificationPrefs") || {};
    if (key && prefs[key] && prefs[key].push === false) {
      logger.info(`push to ${uid} skipped: ${key} switched off`);
      return;
    }
    // Email: prefs[key].email is stored for a future email provider
    // (e.g. the "Trigger Email" extension). Not sent yet.

    const tokens = user.get("fcmTokens") || [];
    if (tokens.length === 0) return;

    const res = await getMessaging().sendEachForMulticast({
      tokens,
      notification: {title: n.title || "Imagi Auction", body: n.body || ""},
      data: {
        listingId: n.listingId || "",
        orderId: n.orderId || "",
        notificationId,
        type: n.type || "other",
      },
      android: {priority: "high", notification: {channelId: "auction_alerts"}},
      apns: {payload: {aps: {sound: "default"}}},
    });

    // Clean up tokens of uninstalled apps / logged-out devices.
    const dead = [];
    res.responses.forEach((r, i) => {
      const code = r.error && r.error.code;
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token"
      ) {
        dead.push(tokens[i]);
      }
    });
    if (dead.length > 0) {
      await userRef.update({fcmTokens: FieldValue.arrayRemove(...dead)});
    }
    logger.info(`push to ${uid}: ${res.successCount} ok, ${res.failureCount} failed`);
  },
);

exports.endingSoonAlerts = onSchedule("every 5 minutes", async () => {
  const now = Date.now();
  const soon = await db
    .collection("listings")
    .where("status", "==", "active")
    .where("endsAt", ">", Timestamp.fromMillis(now))
    .where("endsAt", "<=", Timestamp.fromMillis(now + 60 * 60 * 1000))
    .limit(200)
    .get();

  for (const doc of soon.docs) {
    const l = doc.data();
    const left = l.endsAt.toMillis() - now;
    const tenMin = left <= 10 * 60 * 1000;
    if (tenMin ? l.notified10m : l.notified1h) continue;

    const recipients = new Set([...(l.watcherIds || []), ...(l.bidderIds || [])]);
    recipients.delete(l.sellerId);
    const batch = db.batch();
    for (const uid of recipients) {
      notify(batch, uid, {
        type: "ending_soon",
        title: tenMin ? "10 minutes left" : "1 hour left",
        body: `"${l.title}" ends soon. Current price ${rupiah(l.currentPrice)}.`,
        listingId: doc.id,
      });
    }
    batch.update(doc.ref, tenMin ? {notified10m: true, notified1h: true} : {notified1h: true});
    await batch.commit();
  }
});

exports.paymentReminders = onSchedule("every 6 hours", async () => {
  const due = await db
    .collection("orders")
    .where("status", "==", "awaiting_payment")
    .where("payBy", "<=", Timestamp.fromMillis(Date.now() + DAY))
    .limit(200)
    .get();
  for (const doc of due.docs) {
    const o = doc.data();
    if (o.reminderSent || o.payBy.toMillis() < Date.now()) continue;
    const batch = db.batch();
    notify(batch, o.buyerId, {
      type: "payment_reminder",
      title: "Payment due soon",
      body: `Pay for "${o.title}" within 24 hours to keep your win.`,
      listingId: o.listingId,
      orderId: doc.id,
    });
    batch.update(doc.ref, {reminderSent: true});
    await batch.commit();
  }
});

// ===========================================================================
// Auctions
// ===========================================================================

async function closeOne(ref) {
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return false;
    const l = snap.data();
    if (l.status !== "active" || l.endsAt.toMillis() > Date.now()) return false;

    const bidCount = l.bidCount || 0;
    const winnerId = bidCount > 0 && l.reserveMet ? l.leaderId : null;
    const losers = (l.bidderIds || []).filter((id) => id !== winnerId);

    if (winnerId) {
      tx.update(ref, {
        status: "sold",
        winnerId,
        finalPrice: l.currentPrice,
        buyNowAvailable: false,
        endedAt: FieldValue.serverTimestamp(),
      });
      notify(tx, winnerId, {
        type: "won",
        title: "You won!",
        body: `You won "${l.title}" for ${rupiah(l.currentPrice)}. Pay within ` +
          `${config.PAY_WITHIN_DAYS} days.`,
        listingId: ref.id,
        orderId: ref.id,
      });
      notify(tx, l.sellerId, {
        type: "sold",
        title: "Your item sold",
        body: `"${l.title}" sold for ${rupiah(l.currentPrice)}.`,
        listingId: ref.id,
      });
    } else {
      tx.update(ref, {
        status: "unsold",
        buyNowAvailable: false,
        endedAt: FieldValue.serverTimestamp(),
      });
      notify(tx, l.sellerId, {
        type: "unsold",
        title: "Auction ended unsold",
        body: bidCount === 0 ?
          `"${l.title}" ended with no bids. You can relist it.` :
          `"${l.title}" ended below your reserve price.`,
        listingId: ref.id,
      });
    }
    for (const uid of losers) {
      notify(tx, uid, {
        type: "lost",
        title: "You didn't win",
        body: `"${l.title}" has ended.`,
        listingId: ref.id,
      });
    }
    return true;
  });
}

exports.closeExpiredAuctions = onSchedule("every 1 minutes", async () => {
  const expired = await db
    .collection("listings")
    .where("status", "==", "active")
    .where("endsAt", "<=", Timestamp.now())
    .limit(100)
    .get();

  let closed = 0;
  for (const doc of expired.docs) {
    try {
      if (await closeOne(doc.ref)) closed++;
    } catch (e) {
      logger.error(`failed to close ${doc.id}`, e);
    }
  }
  if (closed > 0) logger.info(`closed ${closed} auctions`);
});

/** One order per sale: orders/{listingId}. */
exports.onListingSold = onDocumentUpdated("listings/{id}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.status === "sold" || after.status !== "sold" || !after.winnerId) return;

  const id = event.params.id;
  const itemPrice = after.finalPrice || after.currentPrice;
  const shippingCost = after.shippingCost || 0;
  const serviceFee = config.serviceFee(itemPrice);
  const endedAt = after.endedAt ? after.endedAt.toMillis() : Date.now();
  const [buyer, seller] = await Promise.all([
    db.doc(`users/${after.winnerId}`).get(),
    db.doc(`users/${after.sellerId}`).get(),
  ]);

  try {
    await db.doc(`orders/${id}`).create({
      listingId: id,
      buyerId: after.winnerId,
      sellerId: after.sellerId,
      buyerName: (buyer.exists && buyer.get("displayName")) || "Buyer",
      sellerName: (seller.exists && seller.get("displayName")) || after.sellerName || "Seller",
      title: after.title,
      imageUrl: (after.imageUrls || [])[0] || null,
      itemPrice,
      shippingCost,
      serviceFee,
      total: itemPrice + shippingCost + serviceFee,
      handlingDays: after.handlingDays || 2,
      status: "awaiting_payment",
      payBy: Timestamp.fromMillis(endedAt + config.PAY_WITHIN_DAYS * DAY),
      address: null,
      courier: null,
      paymentMethod: null,
      xenditInvoiceId: null,
      invoiceUrl: null,
      paidAt: null,
      hasOpenCase: false,
      createdAt: FieldValue.serverTimestamp(),
    });
  } catch (e) {
    if (e.code === 6) return; // ALREADY_EXISTS: retried trigger, nothing to do
    throw e;
  }

  // Auctions already send "You won!" when they close. Buy It Now doesn't,
  // so tell the buyer here.
  if ((after.bidCount || 0) === 0) {
    await notify(db.batch(), after.winnerId, {
      type: "won",
      title: "You bought it!",
      body: `"${after.title}" is yours for ${rupiah(itemPrice)}. Pay within ` +
        `${config.PAY_WITHIN_DAYS} days.`,
      listingId: id,
      orderId: id,
    }).commit();
  }
});

// ===========================================================================
// Payments: Xendit Invoice
// ===========================================================================

const XENDIT_CHANNELS = {
  virtual_account: ["BCA", "BNI", "MANDIRI", "BRI"],
  qris: ["QRIS"],
  // GoPay is not offered through Xendit Invoice in every account; check the
  // dashboard and add it here if it is enabled for you.
  ewallet: ["OVO", "DANA", "SHOPEEPAY"],
};

exports.createInvoice = onCall({secrets: [XENDIT_SECRET_KEY]}, async (req) => {
  const uid = req.auth && req.auth.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");
  const orderId = req.data && req.data.orderId;
  if (typeof orderId !== "string") throw new HttpsError("invalid-argument", "orderId is required.");

  const orderRef = db.doc(`orders/${orderId}`);
  const order = await orderRef.get();
  if (!order.exists) throw new HttpsError("not-found", "Order not found.");
  const o = order.data();
  if (o.buyerId !== uid) throw new HttpsError("permission-denied", "This is not your order.");
  if (o.status !== "awaiting_payment") {
    throw new HttpsError("failed-precondition", "This order is already paid or closed.");
  }
  if (o.payBy.toMillis() <= Date.now()) {
    throw new HttpsError("failed-precondition", "The payment window for this order has expired.");
  }
  if (!o.address) throw new HttpsError("failed-precondition", "Add a shipping address first.");

  // Never trust amounts from the app: recompute from the listing.
  const listing = (await db.doc(`listings/${o.listingId}`).get()).data();
  const itemPrice = listing.finalPrice || listing.currentPrice;
  const shippingCost = listing.shippingCost || 0;
  const serviceFee = config.serviceFee(itemPrice);
  const total = itemPrice + shippingCost + serviceFee;

  // Reuse a still-valid invoice for the same amount and method.
  if (
    o.invoiceUrl && o.invoiceExpiresAt && o.invoiceExpiresAt.toMillis() > Date.now() + 60000 &&
    o.invoiceAmount === total && o.invoiceMethod === o.paymentMethod
  ) {
    return {invoiceUrl: o.invoiceUrl};
  }

  const seconds = Math.max(300, Math.floor((o.payBy.toMillis() - Date.now()) / 1000));
  const res = await fetch("https://api.xendit.co/v2/invoices", {
    method: "POST",
    headers: {
      "Authorization": "Basic " + Buffer.from(`${XENDIT_SECRET_KEY.value()}:`).toString("base64"),
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      external_id: orderId,
      amount: total,
      currency: "IDR",
      payer_email: req.auth.token.email,
      description: `Imagi Auction: ${o.title}`,
      invoice_duration: seconds,
      payment_methods: XENDIT_CHANNELS[o.paymentMethod] || undefined,
    }),
  });
  const body = await res.json();
  if (!res.ok) {
    logger.error("Xendit invoice failed", body);
    throw new HttpsError("internal", body.message || "Payment provider error. Try again.");
  }

  await orderRef.update({
    itemPrice,
    shippingCost,
    serviceFee,
    total,
    xenditInvoiceId: body.id,
    invoiceUrl: body.invoice_url,
    invoiceAmount: total,
    invoiceMethod: o.paymentMethod,
    invoiceExpiresAt: Timestamp.fromDate(new Date(body.expiry_date)),
  });
  return {invoiceUrl: body.invoice_url};
});

exports.xenditWebhook = onRequest({secrets: [XENDIT_CALLBACK_TOKEN]}, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("POST only");
    return;
  }
  if (req.get("x-callback-token") !== XENDIT_CALLBACK_TOKEN.value()) {
    res.status(401).send("invalid token");
    return;
  }
  const {external_id: orderId, status, id: invoiceId} = req.body || {};
  if (!orderId) {
    res.status(400).send("missing external_id");
    return;
  }
  if (status !== "PAID" && status !== "SETTLED") {
    // EXPIRED and others: leave the order as it is (buyer can retry).
    res.status(200).send("ignored");
    return;
  }

  const orderRef = db.doc(`orders/${orderId}`);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(orderRef);
    if (!snap.exists) return;
    const o = snap.data();
    if (o.status !== "awaiting_payment") return; // idempotent
    if (o.xenditInvoiceId && invoiceId && o.xenditInvoiceId !== invoiceId) return;
    tx.update(orderRef, {
      status: "paid",
      paidAt: FieldValue.serverTimestamp(),
      paymentChannel: req.body.payment_channel || req.body.payment_method || null,
    });
    notify(tx, o.sellerId, {
      type: "payment_received",
      title: "Payment received",
      body: `Payment received for "${o.title}". Ship within ${o.handlingDays || 2} days.`,
      listingId: o.listingId,
      orderId,
    });
  });
  res.status(200).send("ok");
});

// ===========================================================================
// Orders & reputation
// ===========================================================================

exports.onOrderUpdated = onDocumentUpdated("orders/{id}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.status === after.status) return;
  const id = event.params.id;
  const messages = {
    shipped: {
      title: "Your item has shipped",
      body: `"${after.title}" is on its way with ${after.courier}. Tracking: ${after.trackingNumber}.`,
    },
    delivered: {
      title: "Delivered",
      body: `"${after.title}" was delivered. Confirm you received it, or report a problem.`,
    },
  };
  const m = messages[after.status];
  if (!m) return;
  await notify(db.batch(), after.buyerId, {
    type: after.status,
    ...m,
    listingId: after.listingId,
    orderId: id,
  }).commit();
});

exports.autoCompleteDelivered = onSchedule("every 24 hours", async () => {
  const cutoff = Timestamp.fromMillis(Date.now() - config.AUTO_CONFIRM_DAYS * DAY);
  const due = await db
    .collection("orders")
    .where("status", "==", "delivered")
    .where("deliveredAt", "<=", cutoff)
    .limit(300)
    .get();
  const batch = db.batch();
  let n = 0;
  for (const doc of due.docs) {
    if (doc.get("hasOpenCase")) continue; // buyer protection: keep on hold
    batch.update(doc.ref, {
      status: "completed",
      completedAt: FieldValue.serverTimestamp(),
      payoutStatus: "pending",
      autoConfirmed: true,
    });
    n++;
  }
  if (n > 0) await batch.commit();
  logger.info(`auto-completed ${n} orders`);
});

exports.onFeedbackCreated = onDocumentCreated("feedback/{id}", async (event) => {
  const toUid = event.data && event.data.get("toUid");
  if (!toUid) return;
  const all = await db.collection("feedback").where("toUid", "==", toUid).get();
  let pos = 0;
  let neg = 0;
  all.forEach((d) => {
    if (d.get("rating") === "positive") pos++;
    if (d.get("rating") === "negative") neg++;
  });
  // eBay-style: neutral ratings count as ratings but not in the percentage.
  await db.doc(`users/${toUid}`).update({
    feedbackScore: pos - neg,
    ratingCount: all.size,
    positivePct: pos + neg === 0 ? 100 : Math.round((pos / (pos + neg)) * 100),
  });
});

/** Copies only public fields to publicProfiles/{uid} (shown on listings). */
exports.syncPublicProfile = onDocumentWritten("users/{uid}", async (event) => {
  const ref = db.doc(`publicProfiles/${event.params.uid}`);
  const after = event.data.after;
  if (!after.exists) {
    await ref.delete();
    return;
  }
  const u = after.data();
  await ref.set({
    maskedName: masked(u.displayName),
    positivePct: u.positivePct || 0,
    ratingCount: u.ratingCount || 0,
    feedbackScore: u.feedbackScore || 0,
    memberSince: u.createdAt || null,
  });
});

// ===========================================================================
// Account deletion (required by Google Play and the App Store)
// ===========================================================================

exports.deleteAccount = onCall(async (req) => {
  const uid = req.auth && req.auth.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");

  const open = (snap) => snap.docs.some((d) => !["completed", "cancelled"].includes(d.get("status")));
  const [asBuyer, asSeller, liveWithBids] = await Promise.all([
    db.collection("orders").where("buyerId", "==", uid).get(),
    db.collection("orders").where("sellerId", "==", uid).get(),
    db.collection("listings").where("sellerId", "==", uid).where("status", "==", "active").get(),
  ]);
  if (open(asBuyer) || open(asSeller)) {
    throw new HttpsError("failed-precondition", "Finish or cancel your open orders before deleting your account.");
  }
  if (liveWithBids.docs.some((d) => (d.get("bidCount") || 0) > 0)) {
    throw new HttpsError("failed-precondition", "You have live auctions with bids. Wait until they end.");
  }

  // End live listings without bids.
  const batch = db.batch();
  liveWithBids.docs.forEach((d) =>
    batch.update(d.ref, {status: "ended", buyNowAvailable: false, endedAt: FieldValue.serverTimestamp()}));
  await batch.commit();

  // Personal data: profile + notifications, watchlist, drafts, addresses, payout.
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await db.doc(`publicProfiles/${uid}`).delete();
  // Photo files live in Supabase Storage; the app can't delete them with the
  // anon key, so they are left there (see README).
  await getAuth().deleteUser(uid);
  return {ok: true};
});
