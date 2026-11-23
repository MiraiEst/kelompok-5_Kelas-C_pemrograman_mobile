import 'package:flutter_test/flutter_test.dart';
import 'package:imagi_auction/domain/models/listing.dart';
import 'package:imagi_auction/ui/sell/sell_validation.dart';

void main() {
  test('photos: 1 to 12', () {
    expect(SellValidation.photos(0), isNotNull);
    expect(SellValidation.photos(1), isNull);
    expect(SellValidation.photos(13), isNotNull);
  });

  test('auction prices', () {
    const f = ListingFormat.auction;
    expect(SellValidation.startPrice(f, 500), isNotNull);
    expect(SellValidation.startPrice(f, 1000), isNull);
    expect(SellValidation.reservePrice(f, 10000, 10000), isNotNull);
    expect(SellValidation.reservePrice(f, 10000, 20000), isNull);
    expect(SellValidation.buyNowPrice(f, 10000, null, null), isNull); // not used
  });

  test('both: Buy It Now above start and not below reserve', () {
    const f = ListingFormat.both;
    expect(SellValidation.buyNowPrice(f, 10000, null, 10000), isNotNull);
    expect(SellValidation.buyNowPrice(f, 10000, 50000, 40000), isNotNull);
    expect(SellValidation.buyNowPrice(f, 10000, 50000, 50000), isNull);
  });

  test('buy it now only needs a price of at least Rp 1.000', () {
    const f = ListingFormat.buyNow;
    expect(SellValidation.startPrice(f, null), isNull);
    expect(SellValidation.buyNowPrice(f, null, null, null), isNotNull);
    expect(SellValidation.buyNowPrice(f, null, null, 1000), isNull);
  });
}
