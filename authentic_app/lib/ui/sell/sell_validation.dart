import '../../core/config.dart';
import '../../domain/models/listing.dart';

/// What is wrong with a Sell form field (translated in l10n/labels.dart).
enum SellError {
  noPhotos,
  tooManyPhotos,
  titleTooShort,
  noCategory,
  priceTooLow,
  notAboveStart,
  noBuyNowPrice,
  belowReserve,
}

/// Pure validation rules for the Sell form (unit-testable, no Flutter).
/// Each returns null when the value is fine.
abstract final class SellValidation {
  static SellError? photos(int count) {
    if (count < 1) return SellError.noPhotos;
    if (count > AppConfig.maxPhotos) return SellError.tooManyPhotos;
    return null;
  }

  static SellError? title(String v) => v.trim().length < 3 ? SellError.titleTooShort : null;

  static SellError? category(String? v) => v == null ? SellError.noCategory : null;

  static SellError? startPrice(ListingFormat f, int? start) {
    if (!f.hasAuction) return null;
    if (start == null || start < AppConfig.minStartPrice) return SellError.priceTooLow;
    return null;
  }

  static SellError? reservePrice(ListingFormat f, int? start, int? reserve) {
    if (!f.hasAuction || reserve == null) return null;
    if (start != null && reserve <= start) return SellError.notAboveStart;
    return null;
  }

  static SellError? buyNowPrice(ListingFormat f, int? start, int? reserve, int? buyNow) {
    if (!f.hasBuyNow) return null;
    if (buyNow == null) return SellError.noBuyNowPrice;
    if (f == ListingFormat.buyNow) {
      return buyNow < AppConfig.minStartPrice ? SellError.priceTooLow : null;
    }
    if (start != null && buyNow <= start) return SellError.notAboveStart;
    if (reserve != null && buyNow < reserve) return SellError.belowReserve;
    return null;
  }
}
