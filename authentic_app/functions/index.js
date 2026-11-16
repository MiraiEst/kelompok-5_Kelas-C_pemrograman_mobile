/**
 * Cloud Functions for Imagi Auction (optional; needs the Firebase Blaze plan).
 *
 * 1. pushOnNotification  - every new users/{uid}/notifications doc (outbid,
 *    won, sold, ...) is sent as an FCM push to all of that user's devices.
 *    This is what makes alerts arrive when the app is closed.
 * 2. closeExpiredAuctions - every minute, closes auctions whose end time has
 *    passed, even if nobody has the app open.
 */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {setGlobalOptions, logger} = require("firebase-functions/v2");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue, Timestamp} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();
setGlobalOptions({region: "asia-southeast1", maxInstances: 10});

const db = getFirestore();

const rupiah = (n) =>
  "Rp " + Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");

// ---------------------------------------------------------------------------
// 1. Firestore notification doc -> FCM push
// ---------------------------------------------------------------------------
exports.pushOnNotification = onDocumentCreated(
  "users/{uid}/notifications/{notificationId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const n = snap.data();
    const {uid, notificationId} = event.params;

    const userRef = db.doc(`users/${uid}`);
    const user = await userRef.get();
    const tokens = (user.exists && user.get("fcmTokens")) || [];
    if (tokens.length === 0) return;

    const res = await getMessaging().sendEachForMulticast({
      tokens,
      notification: {title: n.title || "Imagi Auction", body: n.body || ""},
      data: {
        listingId: n.listingId || "",
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

// ---------------------------------------------------------------------------
// 2. Close expired auctions (same rules as ListingRepository.closeIfExpired)
// ---------------------------------------------------------------------------
function notify(tx, to, {type, title, body, listingId}) {
  tx.set(db.collection(`users/${to}/notifications`).doc(), {
    type,
    title,
    body,
    listingId,
    fromUid: "system",
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  });
}

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
        body: `You won "${l.title}" for ${rupiah(l.currentPrice)}.`,
        listingId: ref.id,
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
