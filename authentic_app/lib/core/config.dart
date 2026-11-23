/// Team decisions in one place. Replace the values marked TODO.
abstract final class AppConfig {
  /// TODO(team): real Terms of Service page.
  static const termsUrl = 'https://example.com/terms';

  /// TODO(team): real Privacy Policy page.
  static const privacyUrl = 'https://example.com/privacy';

  /// Final value fee charged to the seller, in percent of the sale price.
  /// TODO(team): confirm the fee.
  static const finalValueFeePercent = 5;

  /// Days the winner has to pay after the auction ends.
  static const payWithinDays = 4;

  /// Days after delivery before an order is confirmed automatically.
  static const autoConfirmDays = 3;

  /// Days a completed order can still be rated.
  static const ratingWindowDays = 60;

  /// Service fee charged to the buyer: 1% of the item price, max Rp 10.000.
  /// TODO(team): confirm. Keep in sync with functions/config.js (the server
  /// recalculates the total and is the source of truth).
  static const serviceFeePercent = 1;
  static const serviceFeeCap = 10000;

  static int serviceFee(int itemPrice) {
    final fee = (itemPrice * serviceFeePercent / 100).round();
    return fee > serviceFeeCap ? serviceFeeCap : fee;
  }

  static const maxPhotos = 12;
  static const minStartPrice = 1000;
}
