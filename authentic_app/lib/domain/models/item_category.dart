/// The fixed item categories. Listings store [slug] in Firestore.
///
/// Older listings and DummyJSON catalog imports use DummyJSON's own slugs
/// ("smartphones", "mens-shirts", …); [legacy] maps those onto these groups so
/// they still show up under the right category without migrating data.
enum ItemCategory {
  electronics('electronics', {'smartphones', 'laptops', 'tablets', 'mobile-accessories'}),
  fashion('fashion', {
    'mens-shirts',
    'mens-shoes',
    'mens-watches',
    'womens-bags',
    'womens-dresses',
    'womens-jewellery',
    'womens-shoes',
    'womens-watches',
    'sunglasses',
    'tops',
  }),
  antique('antique', {}),
  hobbiesToys('hobbies-toys', {'sports-accessories'}),
  home('home', {'furniture', 'home-decoration', 'kitchen-accessories'}),
  automotive('automotive', {'vehicle', 'motorcycle'}),
  other('other', {'beauty', 'fragrances', 'skin-care', 'groceries'});

  const ItemCategory(this.slug, this.legacy);

  /// Value stored on the listing.
  final String slug;

  /// DummyJSON / pre-2026-11 slugs that belong to this category.
  final Set<String> legacy;

  /// Every stored value that counts as this category (for the Home filter).
  List<String> get matchingSlugs => [slug, ...legacy];

  /// Maps any stored or DummyJSON slug to a category; unknown values are [other].
  static ItemCategory parse(Object? raw) {
    for (final c in values) {
      if (c.slug == raw || c.legacy.contains(raw)) return c;
    }
    return other;
  }

  /// Like [parse] but null when nothing is stored yet (new listing form).
  static ItemCategory? tryParse(Object? raw) => raw is String ? parse(raw) : null;
}
