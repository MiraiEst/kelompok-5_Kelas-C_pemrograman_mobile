/**
 * Server jobs for Imagi Auction WITHOUT Cloud Functions (no Blaze plan needed).
 *
 * Runs once and exits. GitHub Actions starts it every ~5 minutes
 * (.github/workflows/backend-cron.yml at the repo root). It does the work of
 * the Cloud Functions in functions/index.js, but by checking what changed
 * since the last run instead of reacting to triggers:
 *
 *   closeExpiredAuctions   close auctions past endsAt, notify winner/seller/losers
 *   createOrders           sold listings (auction or Buy It Now) -> orders/{listingId}
 *   orderStepNotices       shipped / delivered -> notify buyer
 *   endingSoonNotices      "1 hour / 10 minutes left" entries in the Notifications list
 *                          (the phone shows its own scheduled reminder)
 *   paymentReminders       winners whose payBy is < 24 h away
 *   autoCompleteDelivered  delivered > 3 days without a case -> completed
 *   ratings                new feedback -> users + publicProfiles rating numbers
 *   publicProfiles         new users -> publicProfiles; full resync once a day
 *   push                   new notification docs -> FCM push (respects settings)
 *
 * Every task is safe to run twice (markers on documents), so runs may overlap
 * a little and a failed run is simply retried by the next one.
 *
 * Local run:  GOOGLE_APPLICATION_CREDENTIALS=key.json node run.js
 * Emulator:   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 GCLOUD_PROJECT=demo-imagi node run.js
 */
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue, Timestamp} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const config = require("../functions/config");

initializeApp();
const db = getFirestore();

const MIN = 60 * 1000;
const DAY = 24 * 60 * MIN;
// Look back a bit further than the previous run, in case of clock skew or a
// delayed run. Markers make the overlap harmless.
const OVERLAP = 10 * MIN;
const STATE = db.doc("_cron/state"); // no client access (no rule matches)

const rupiah = (n) => "Rp " + Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
const masked = (name) => {
  const t = (name || "").trim();
  if (t.length === 0) return "***";
  if (t.length === 1) return `${t}***`;
  return `${t[0]}***${t[t.length - 1]}`;
};
const log = (...a) => console.log(new Date().toISOString(), ...a);

/** Writes an in-app notification; the push task sends it to the phone later. */
function notify(writer, to, {type, title, body, listingId, orderId}) {
  const data = {
    type, title, body,
    listingId: listingId || null,
    fromUid: "system",
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  };
  if (orderId) data.orderId = orderId;
  writer.set(db.collection(`users/${to}/notifications`).doc(), data);
}

// ---------------------------------------------------------------- auctions

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
      tx.update(ref, {status: "sold", winnerId, finalPrice: l.currentPrice,
        buyNowAvailable: false, endedAt: FieldValue.serverTimestamp()});
      notify(tx, winnerId, {type: "won", title: "You won!",
        body: `You won "${l.title}" for ${rupiah(l.currentPrice)}. Pay within ${config.PAY_WITHIN_DAYS} days.`,
        listingId: ref.id, orderId: ref.id});
      notify(tx, l.sellerId, {type: "sold", title: "Your item sold",
        body: `"${l.title}" sold for ${rupiah(l.currentPrice)}.`, listingId: ref.id});
    } else {
      tx.update(ref, {status: "unsold", buyNowAvailable: false, endedAt: FieldValue.serverTimestamp()});
      notify(tx, l.sellerId, {type: "unsold", title: "Auction ended unsold",
        body: bidCount === 0 ?
          `"${l.title}" ended with no bids. You can relist it.` :
          `"${l.title}" ended below your reserve price.`,
        listingId: ref.id});
    }
    for (const uid of losers) {
      notify(tx, uid, {type: "lost", title: "You didn't win",
        body: `"${l.title}" has ended.`, listingId: ref.id});
    }
    return true;
  });
}

async function closeExpiredAuctions() {
  const expired = await db.collection("listings")
    .where("status", "==", "active")
    .where("endsAt", "<=", Timestamp.now())
    .limit(100).get();
  let n = 0;
  for (const doc of expired.docs) {
    try {
      if (await closeOne(doc.ref)) n++;
    } catch (e) {
      log(`failed to close ${doc.id}:`, e.message);
    }
  }
  return n;
}

/** One order per sale: orders/{listingId}. Safe to repeat (create fails if it exists). */
async function createOrder(doc) {
  const l = doc.data();
  if (l.status !== "sold" || !l.winnerId) return false;
  const itemPrice = l.finalPrice || l.currentPrice;
  const shippingCost = l.shippingCost || 0;
  const serviceFee = config.serviceFee(itemPrice);
  const endedAt = l.endedAt ? l.endedAt.toMillis() : Date.now();
  const [buyer, seller] = await Promise.all([
    db.doc(`users/${l.winnerId}`).get(),
    db.doc(`users/${l.sellerId}`).get(),
  ]);
  try {
    await db.doc(`orders/${doc.id}`).create({
      listingId: doc.id,
      buyerId: l.winnerId,
      sellerId: l.sellerId,
      buyerName: (buyer.exists && buyer.get("displayName")) || "Buyer",
      sellerName: (seller.exists && seller.get("displayName")) || l.sellerName || "Seller",
      title: l.title,
      imageUrl: (l.imageUrls || [])[0] || null,
      itemPrice, shippingCost, serviceFee,
      total: itemPrice + shippingCost + serviceFee,
      handlingDays: l.handlingDays || 2,
      status: "awaiting_payment",
      payBy: Timestamp.fromMillis(endedAt + config.PAY_WITHIN_DAYS * DAY),
      address: null, courier: null, paymentMethod: null,
      xenditInvoiceId: null, invoiceUrl: null, paidAt: null,
      hasOpenCase: false,
      createdAt: FieldValue.serverTimestamp(),
    });
  } catch (e) {
    if (e.code === 6) return false; // ALREADY_EXISTS
    throw e;
  }
  // Auctions already said "You won!" when they closed; Buy It Now didn't.
  if ((l.bidCount || 0) === 0) {
    const batch = db.batch();
    notify(batch, l.winnerId, {type: "won", title: "You bought it!",
      body: `"${l.title}" is yours for ${rupiah(itemPrice)}. Pay within ${config.PAY_WITHIN_DAYS} days.`,
      listingId: doc.id, orderId: doc.id});
    await batch.commit();
  }
  return true;
}

async function createOrders(since) {
  // endedAt is set by every close / Buy It Now (app or this job).
  const ended = await db.collection("listings").where("endedAt", ">=", since).get();
  let n = 0;
  for (const doc of ended.docs) {
    try {
      if (await createOrder(doc)) n++;
    } catch (e) {
      log(`failed to create order ${doc.id}:`, e.message);
    }
  }
  return n;
}

// ------------------------------------------------------------------ orders

async function orderStepNotices(since) {
  const steps = {
    shipped: ["shippedAt", (o) => ({title: "Your item has shipped",
      body: `"${o.title}" is on its way with ${o.courier}. Tracking: ${o.trackingNumber}.`})],
    delivered: ["deliveredAt", (o) => ({title: "Delivered",
      body: `"${o.title}" was delivered. Confirm you received it, or report a problem.`})],
  };
  let n = 0;
  for (const [step, [field, message]] of Object.entries(steps)) {
    const snap = await db.collection("orders").where(field, ">=", since).get();
    for (const doc of snap.docs) {
      const o = doc.data();
      if ((o.noticesSent || []).includes(step)) continue;
      const batch = db.batch();
      notify(batch, o.buyerId, {type: step, ...message(o), listingId: o.listingId, orderId: doc.id});
      batch.update(doc.ref, {noticesSent: FieldValue.arrayUnion(step)});
      await batch.commit();
      n++;
    }
  }
  return n;
}

async function paymentReminders() {
  const now = Date.now();
  const due = await db.collection("orders")
    .where("status", "==", "awaiting_payment")
    .where("payBy", ">", Timestamp.fromMillis(now))
    .where("payBy", "<=", Timestamp.fromMillis(now + DAY))
    .limit(200).get();
  let n = 0;
  for (const doc of due.docs) {
    const o = doc.data();
    if (o.reminderSent) continue;
    const batch = db.batch();
    notify(batch, o.buyerId, {type: "payment_reminder", title: "Payment due soon",
      body: `Pay for "${o.title}" within 24 hours to keep your win.`,
      listingId: o.listingId, orderId: doc.id});
    batch.update(doc.ref, {reminderSent: true});
    await batch.commit();
    n++;
  }
  return n;
}

async function autoCompleteDelivered() {
  const cutoff = Timestamp.fromMillis(Date.now() - config.AUTO_CONFIRM_DAYS * DAY);
  const due = await db.collection("orders")
    .where("status", "==", "delivered")
    .where("deliveredAt", "<=", cutoff)
    .limit(300).get();
  const batch = db.batch();
  let n = 0;
  for (const doc of due.docs) {
    if (doc.get("hasOpenCase")) continue; // buyer protection: keep on hold
    batch.update(doc.ref, {status: "completed", completedAt: FieldValue.serverTimestamp(),
      payoutStatus: "pending", autoConfirmed: true});
    n++;
  }
  if (n > 0) await batch.commit();
  return n;
}

// ------------------------------------------------------------ ending soon

async function endingSoonNotices() {
  const now = Date.now();
  const soon = await db.collection("listings")
    .where("status", "==", "active")
    .where("endsAt", ">", Timestamp.fromMillis(now))
    .where("endsAt", "<=", Timestamp.fromMillis(now + 60 * MIN))
    .limit(200).get();
  let n = 0;
  for (const doc of soon.docs) {
    const l = doc.data();
    const tenMin = l.endsAt.toMillis() - now <= 10 * MIN;
    if (tenMin ? l.notified10m : l.notified1h) continue;
    const recipients = new Set([...(l.watcherIds || []), ...(l.bidderIds || [])]);
    recipients.delete(l.sellerId);
    const batch = db.batch();
    for (const uid of recipients) {
      notify(batch, uid, {type: "ending_soon", title: tenMin ? "10 minutes left" : "1 hour left",
        body: `"${l.title}" ends soon. Current price ${rupiah(l.currentPrice)}.`, listingId: doc.id});
    }
    batch.update(doc.ref, tenMin ? {notified10m: true, notified1h: true} : {notified1h: true});
    await batch.commit();
    n++;
  }
  return n;
}

// ---------------------------------------------------- ratings & profiles

function publicProfileOf(u) {
  return {
    maskedName: masked(u.displayName),
    positivePct: u.positivePct || 0,
    ratingCount: u.ratingCount || 0,
    feedbackScore: u.feedbackScore || 0,
    memberSince: u.createdAt || null,
  };
}

async function syncProfile(uid) {
  const user = await db.doc(`users/${uid}`).get();
  const ref = db.doc(`publicProfiles/${uid}`);
  if (user.exists) await ref.set(publicProfileOf(user.data()));
  else await ref.delete();
}

async function ratings(since) {
  const fresh = await db.collection("feedback").where("createdAt", ">=", since).get();
  const people = new Set(fresh.docs.map((d) => d.get("toUid")).filter(Boolean));
  for (const uid of people) {
    const all = await db.collection("feedback").where("toUid", "==", uid).get();
    let pos = 0;
    let neg = 0;
    all.forEach((d) => {
      if (d.get("rating") === "positive") pos++;
      if (d.get("rating") === "negative") neg++;
    });
    const user = db.doc(`users/${uid}`);
    if (!(await user.get()).exists) continue;
    // eBay-style: neutral ratings count as ratings but not in the percentage.
    await user.update({
      feedbackScore: pos - neg,
      ratingCount: all.size,
      positivePct: pos + neg === 0 ? 100 : Math.round((pos / (pos + neg)) * 100),
    });
    await syncProfile(uid);
  }
  return people.size;
}

async function publicProfiles(since, state) {
  const fresh = await db.collection("users").where("createdAt", ">=", since).get();
  for (const doc of fresh.docs) await syncProfile(doc.id);
  // Name changes and deleted accounts: full resync once a day.
  const last = state.lastFullSync ? state.lastFullSync.toMillis() : 0;
  if (Date.now() - last < DAY) return fresh.size;
  const [users, profiles] = await Promise.all([
    db.collection("users").get(),
    db.collection("publicProfiles").get(),
  ]);
  const writer = db.bulkWriter();
  const ids = new Set();
  users.forEach((u) => {
    ids.add(u.id);
    writer.set(db.doc(`publicProfiles/${u.id}`), publicProfileOf(u.data()));
  });
  profiles.forEach((p) => {
    if (!ids.has(p.id)) writer.delete(p.ref);
  });
  await writer.close();
  await STATE.set({lastFullSync: Timestamp.now()}, {merge: true});
  log(`full public profile sync: ${users.size} users`);
  return fresh.size;
}

// ------------------------------------------------------------------- push

/** Maps a notification type to its key in users/{uid}.notificationPrefs. */
const PREF_KEY = {
  outbid: "outbid", ending_soon: "endingSoon", won: "wonLost", lost: "wonLost",
  new_bid: "newBid", reserve_met: "reserveMet", sold: "orders", unsold: "orders",
  payment_reminder: "orders", payment_received: "orders", shipped: "orders",
  delivered: "orders", second_chance: "secondChance",
};

async function push(since) {
  const fresh = await db.collectionGroup("notifications").where("createdAt", ">=", since).get();
  const users = new Map(); // uid -> user snapshot (cache)
  let sent = 0;
  for (const doc of fresh.docs) {
    const n = doc.data();
    if (n.pushedAt) continue;
    const mark = () => doc.ref.update({pushedAt: FieldValue.serverTimestamp()});
    // Too old to be useful as a push (e.g. the job was down for a while).
    if (n.createdAt.toMillis() < Date.now() - 2 * 60 * MIN) {
      await mark();
      continue;
    }
    // The phone shows its own, on-time "ending soon" reminder.
    if (n.type === "ending_soon") {
      await mark();
      continue;
    }
    const uid = doc.ref.parent.parent.id;
    if (!users.has(uid)) users.set(uid, await db.doc(`users/${uid}`).get());
    const user = users.get(uid);
    const key = PREF_KEY[n.type];
    const prefs = (user.exists && user.get("notificationPrefs")) || {};
    const tokens = (user.exists && user.get("fcmTokens")) || [];
    if (tokens.length === 0 || (key && prefs[key] && prefs[key].push === false)) {
      await mark();
      continue;
    }
    const res = await getMessaging().sendEachForMulticast({
      tokens,
      notification: {title: n.title || "Imagi Auction", body: n.body || ""},
      data: {listingId: n.listingId || "", orderId: n.orderId || "",
        notificationId: doc.id, type: n.type || "other"},
      android: {priority: "high", notification: {channelId: "auction_alerts"}},
      apns: {payload: {aps: {sound: "default"}}},
    });
    await mark();
    sent += res.successCount;
    // Forget tokens of uninstalled apps / logged-out devices.
    const dead = tokens.filter((_, i) => {
      const code = res.responses[i].error && res.responses[i].error.code;
      return code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token";
    });
    if (dead.length > 0) {
      await db.doc(`users/${uid}`).update({fcmTokens: FieldValue.arrayRemove(...dead)});
      users.delete(uid);
    }
  }
  return sent;
}

// ------------------------------------------------------------------- main

async function main() {
  const startedAt = Timestamp.now();
  const state = (await STATE.get()).data() || {};
  const lastRun = state.lastRunAt ? state.lastRunAt.toMillis() : Date.now() - 60 * MIN;
  const since = Timestamp.fromMillis(lastRun - OVERLAP);

  // Order matters: close auctions and create orders before sending pushes,
  // so this run already pushes the notifications it created.
  const tasks = [
    ["closed auctions", closeExpiredAuctions],
    ["orders created", () => createOrders(since)],
    ["order notices", () => orderStepNotices(since)],
    ["ending soon", endingSoonNotices],
    ["payment reminders", paymentReminders],
    ["auto-completed", autoCompleteDelivered],
    ["ratings updated", () => ratings(since)],
    ["new profiles", () => publicProfiles(since, state)],
    ["pushes sent", () => push(since)],
  ];
  let failed = false;
  for (const [name, task] of tasks) {
    try {
      const n = await task();
      if (n) log(`${name}: ${n}`);
    } catch (e) {
      failed = true;
      log(`${name} FAILED:`, e.message);
    }
  }
  // Only move forward when everything worked; otherwise the next run retries.
  if (!failed) await STATE.set({lastRunAt: startedAt}, {merge: true});
  log(failed ? "done with errors" : "done");
  process.exitCode = failed ? 1 : 0;
}

main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
