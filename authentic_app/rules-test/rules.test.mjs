// Security rules tests. Run from this folder:  npm install && npm test
// (needs the Firebase CLI and Java for the emulators).
import {readFileSync} from "node:fs";
import {after, before, beforeEach, describe, test} from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  Timestamp,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import {ref, uploadBytes} from "firebase/storage";

let env;
const hour = 60 * 60 * 1000;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-imagi",
    firestore: {rules: readFileSync("../firestore.rules", "utf8"), host: "127.0.0.1", port: 8080},
    storage: {rules: readFileSync("../storage.rules", "utf8"), host: "127.0.0.1", port: 9199},
  });
});
after(() => env.cleanup());
beforeEach(() => env.clearFirestore());

const verified = (uid) => env.authenticatedContext(uid, {email_verified: true}).firestore();
const unverified = (uid) => env.authenticatedContext(uid, {email_verified: false}).firestore();

/** Seed data with rules disabled. */
async function seed(fn) {
  await env.withSecurityRulesDisabled((ctx) => fn(ctx.firestore()));
}

function listing(overrides = {}) {
  return {
    sellerId: "seller",
    sellerName: "seller",
    title: "Camera",
    description: "",
    category: "smartphones",
    condition: "used",
    imageUrls: [],
    startPrice: 100000,
    reservePrice: null,
    buyNowPrice: null,
    shippingCost: 0,
    format: "auction",
    handlingDays: 2,
    location: "Makassar",
    acceptsReturns: false,
    returnDays: 7,
    createdAt: Timestamp.now(),
    endsAt: Timestamp.fromMillis(Date.now() + 24 * hour),
    status: "active",
    currentPrice: 100000,
    bidCount: 0,
    bidderIds: [],
    leaderId: null,
    leaderName: null,
    leaderMax: null,
    reserveMet: true,
    buyNowAvailable: false,
    watcherCount: 0,
    watcherIds: [],
    winnerId: null,
    finalPrice: null,
    ...overrides,
  };
}

function order(overrides = {}) {
  return {
    listingId: "l1",
    buyerId: "buyer",
    sellerId: "seller",
    title: "Camera",
    itemPrice: 500000,
    shippingCost: 25000,
    serviceFee: 5000,
    total: 530000,
    status: "awaiting_payment",
    payBy: Timestamp.fromMillis(Date.now() + 96 * hour),
    hasOpenCase: false,
    createdAt: Timestamp.now(),
    ...overrides,
  };
}

describe("hidden maximum bids", () => {
  test("a bidder can read their own max but not someone else's", async () => {
    await seed((db) => Promise.all([
      setDoc(doc(db, "listings/l1"), listing()),
      setDoc(doc(db, "listings/l1/myMax/alice"), {maxAmount: 500000}),
    ]));
    await assertSucceeds(getDoc(doc(verified("alice"), "listings/l1/myMax/alice")));
    await assertFails(getDoc(doc(verified("bob"), "listings/l1/myMax/alice")));
  });

  test("nobody can write a max for another user", async () => {
    await assertFails(setDoc(doc(verified("bob"), "listings/l1/myMax/alice"), {maxAmount: 1}));
  });
});

describe("listings", () => {
  test("seller cannot change price or status directly", async () => {
    await seed((db) => setDoc(doc(db, "listings/l1"), listing()));
    const db = verified("seller");
    await assertFails(updateDoc(doc(db, "listings/l1"), {currentPrice: 999999}));
    await assertFails(updateDoc(doc(db, "listings/l1"), {status: "sold", winnerId: "seller"}));
  });

  test("unverified email cannot create a listing; verified can", async () => {
    const data = {...listing({sellerId: "u1"}), createdAt: serverTimestamp()};
    await assertFails(setDoc(doc(unverified("u1"), "listings/new1"), data));
    await assertSucceeds(setDoc(doc(verified("u1"), "listings/new2"), data));
  });

  test("buy-it-now-only listings reject bids", async () => {
    await seed((db) => setDoc(doc(db, "listings/l1"), listing({
      format: "buy_now", buyNowPrice: 100000, buyNowAvailable: true,
    })));
    await assertFails(updateDoc(doc(verified("bob"), "listings/l1"), {
      currentPrice: 100000, bidCount: 1, bidderIds: ["bob"], leaderId: "bob",
      leaderName: "b***b", leaderMax: 200000, reserveMet: true, buyNowAvailable: false,
    }));
  });

  test("a verified bidder can place a normal bid; an unverified one cannot", async () => {
    await seed((db) => setDoc(doc(db, "listings/l1"), listing()));
    const bid = {
      currentPrice: 100000, bidCount: 1, bidderIds: ["bob"], leaderId: "bob", leaderName: "b***b",
      leaderMax: 200000, reserveMet: true, buyNowAvailable: false, lastBidAt: serverTimestamp(),
      recentBidCount: 1, recentBidWindowStart: Timestamp.now(),
    };
    await assertFails(updateDoc(doc(unverified("bob"), "listings/l1"), bid));
    await assertSucceeds(updateDoc(doc(verified("bob"), "listings/l1"), bid));
  });

  test("watching only adds your own uid", async () => {
    await seed((db) => setDoc(doc(db, "listings/l1"), listing()));
    await assertSucceeds(updateDoc(doc(verified("bob"), "listings/l1"), {
      watcherCount: 1, watcherIds: ["bob"],
    }));
    await assertFails(updateDoc(doc(verified("eve"), "listings/l1"), {
      watcherCount: 2, watcherIds: ["bob", "mallory"],
    }));
  });
});

describe("user profiles", () => {
  beforeEach(() => seed((db) => setDoc(doc(db, "users/alice"), {
    displayName: "alice", email: "a@x.id", role: "user", fcmTokens: [], ratingCount: 0,
  })));

  test("cannot make yourself admin or fake your rating", async () => {
    const db = verified("alice");
    await assertFails(updateDoc(doc(db, "users/alice"), {role: "admin"}));
    await assertFails(updateDoc(doc(db, "users/alice"), {ratingCount: 999, feedbackScore: 999}));
    await assertSucceeds(updateDoc(doc(db, "users/alice"), {displayName: "alice2", phone: "0812"}));
  });

  test("cannot read another user's profile, addresses or payout account", async () => {
    await seed((db) => Promise.all([
      setDoc(doc(db, "users/alice/addresses/a1"), {name: "A", city: "Makassar"}),
      setDoc(doc(db, "users/alice/private/payout"), {bankName: "BCA", accountNumber: "1234567821", accountHolder: "A"}),
    ]));
    const bob = verified("bob");
    await assertFails(getDoc(doc(bob, "users/alice")));
    await assertFails(getDoc(doc(bob, "users/alice/addresses/a1")));
    await assertFails(getDoc(doc(bob, "users/alice/private/payout")));
    await assertSucceeds(getDoc(doc(verified("alice"), "users/alice/addresses/a1")));
  });
});

describe("orders", () => {
  beforeEach(() => seed((db) => setDoc(doc(db, "orders/l1"), order())));

  test("only buyer and seller can read an order", async () => {
    await assertSucceeds(getDoc(doc(verified("buyer"), "orders/l1")));
    await assertSucceeds(getDoc(doc(verified("seller"), "orders/l1")));
    await assertFails(getDoc(doc(verified("eve"), "orders/l1")));
  });

  test("buyer cannot mark an order paid or change the total", async () => {
    const db = verified("buyer");
    await assertFails(updateDoc(doc(db, "orders/l1"), {status: "paid"}));
    await assertFails(updateDoc(doc(db, "orders/l1"), {total: 1}));
    await assertSucceeds(updateDoc(doc(db, "orders/l1"), {
      address: {name: "B"}, courier: "JNE REG", paymentMethod: "qris",
    }));
  });

  test("seller can ship only a paid order; buyer cannot ship", async () => {
    const shipped = {status: "shipped", courier: "JNE REG", trackingNumber: "JNE123456", shippedAt: serverTimestamp()};
    await assertFails(updateDoc(doc(verified("seller"), "orders/l1"), shipped)); // unpaid
    await seed((db) => updateDoc(doc(db, "orders/l1"), {status: "paid"}));
    await assertFails(updateDoc(doc(verified("buyer"), "orders/l1"), shipped));
    await assertSucceeds(updateDoc(doc(verified("seller"), "orders/l1"), shipped));
  });

  test("feedback only after completion, once, by a party of the order", async () => {
    const fb = {orderId: "l1", fromUid: "buyer", toUid: "seller", role: "buyer",
      rating: "positive", comment: "Great", createdAt: serverTimestamp()};
    await assertFails(setDoc(doc(verified("buyer"), "feedback/l1_buyer"), fb)); // not completed
    await seed((db) => updateDoc(doc(db, "orders/l1"), {status: "completed", completedAt: Timestamp.now()}));
    await assertFails(setDoc(doc(verified("eve"), "feedback/l1_buyer"), {...fb, fromUid: "eve"}));
    await assertSucceeds(setDoc(doc(verified("buyer"), "feedback/l1_buyer"), fb));
    await assertFails(setDoc(doc(verified("buyer"), "feedback/l1_buyer"), {...fb, rating: "negative"}));
  });
});

describe("storage", () => {
  const img = new Uint8Array([0xff, 0xd8, 0xff, 0xe0]);
  const storage = (uid) => env.authenticatedContext(uid).storage();

  test("only the owner can upload into their folder", async () => {
    const meta = {contentType: "image/jpeg"};
    await assertSucceeds(uploadBytes(ref(storage("alice"), "listings/alice/l1/0.jpg"), img, meta));
    await assertFails(uploadBytes(ref(storage("bob"), "listings/alice/l1/1.jpg"), img, meta));
  });

  test("rejects non-images and files over 5 MB", async () => {
    const s = storage("alice");
    await assertFails(uploadBytes(ref(s, "listings/alice/l1/2.jpg"), img, {contentType: "text/plain"}));
    const big = new Uint8Array(5 * 1024 * 1024 + 1);
    await assertFails(uploadBytes(ref(s, "listings/alice/l1/3.jpg"), big, {contentType: "image/jpeg"}));
  });
});
