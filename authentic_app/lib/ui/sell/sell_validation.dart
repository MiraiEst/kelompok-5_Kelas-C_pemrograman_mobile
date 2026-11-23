import '../../core/config.dart';
import '../../domain/models/listing.dart';

/// Pure validation rules for the Sell form (unit-testable, no Flutter).
abstract final class SellValidation {
  static String? photos(int count) {
    if (count < 1) return 'Add at least 1 photo';
    if (count > AppConfig.maxPhotos) return 'Maximum ${AppConfig.maxPhotos} photos';
    return null;
  }

  static String? title(String v) => v.trim().length < 3 ? 'At least 3 characters' : null;

  static String? category(String? v) => v == null ? 'Pick a category' : null;

  static String? startPrice(ListingFormat f, int? start) {
    if (!f.hasAuction) return null;
    if (start == null || start < AppConfig.minStartPrice) return 'At least Rp 1.000';
    return null;
  }

  static String? reservePrice(ListingFormat f, int? start, int? reserve) {
    if (!f.hasAuction || reserve == null) return null;
    if (start != null && reserve <= start) return 'Must be higher than the starting price';
    return null;
  }

  static String? buyNowPrice(ListingFormat f, int? start, int? reserve, int? buyNow) {
    if (!f.hasBuyNow) return null;
    if (buyNow == null) return 'Enter the Buy It Now price';
    if (f == ListingFormat.buyNow) {
      return buyNow < AppConfig.minStartPrice ? 'At least Rp 1.000' : null;
    }
    if (start != null && buyNow <= start) return 'Must be higher than the starting price';
    if (reserve != null && buyNow < reserve) return 'Must be at least the reserve price';
    return null;
  }
}
