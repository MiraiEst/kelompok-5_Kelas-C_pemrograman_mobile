import 'package:flutter_test/flutter_test.dart';
import 'package:imagi_auction/domain/models/item_category.dart';

void main() {
  test('new slugs map to themselves', () {
    for (final c in ItemCategory.values) {
      expect(ItemCategory.parse(c.slug), c);
    }
  });

  test('old DummyJSON slugs map to the new groups', () {
    expect(ItemCategory.parse('smartphones'), ItemCategory.electronics);
    expect(ItemCategory.parse('womens-bags'), ItemCategory.fashion);
    expect(ItemCategory.parse('sports-accessories'), ItemCategory.hobbiesToys);
    expect(ItemCategory.parse('furniture'), ItemCategory.home);
    expect(ItemCategory.parse('motorcycle'), ItemCategory.automotive);
    expect(ItemCategory.parse('fragrances'), ItemCategory.other);
  });

  test('unknown values fall back to other; null stays null for the form', () {
    expect(ItemCategory.parse('something-new'), ItemCategory.other);
    expect(ItemCategory.tryParse(null), isNull);
  });

  test('the Home filter matches the slug and its legacy slugs', () {
    expect(ItemCategory.automotive.matchingSlugs, ['automotive', 'vehicle', 'motorcycle']);
    // Firestore "in" queries take at most 30 values.
    for (final c in ItemCategory.values) {
      expect(c.matchingSlugs.length, lessThanOrEqualTo(30));
    }
  });
}
