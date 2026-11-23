/**
 * Team decisions used by Cloud Functions. Keep in sync with
 * lib/core/config.dart in the app (the server is the source of truth).
 */
module.exports = {
  // Buyer service fee: 1% of the item price, max Rp 10.000. TODO(team): confirm.
  SERVICE_FEE_PERCENT: 1,
  SERVICE_FEE_CAP: 10000,
  // Winner must pay within this many days after the auction ends.
  PAY_WITHIN_DAYS: 4,
  // Delivered orders are auto-completed after this many days.
  AUTO_CONFIRM_DAYS: 3,
  REGION: "asia-southeast1",
};

module.exports.serviceFee = (itemPrice) =>
  Math.min(
    Math.round((itemPrice * module.exports.SERVICE_FEE_PERCENT) / 100),
    module.exports.SERVICE_FEE_CAP,
  );
