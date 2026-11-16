/// Product template from the open-source DummyJSON API, used to pre-fill a
/// new listing (title, description, category, photos, suggested price).
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priceUsd,
    required this.thumbnail,
    required this.images,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double priceUsd;
  final String thumbnail;
  final List<String> images;

  factory CatalogProduct.fromJson(Map<String, dynamic> j) => CatalogProduct(
        id: (j['id'] as num).toInt(),
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        category: j['category'] as String? ?? 'other',
        priceUsd: (j['price'] as num?)?.toDouble() ?? 0,
        thumbnail: j['thumbnail'] as String? ?? '',
        images: List<String>.from(j['images'] as List? ?? const []),
      );
}

class CatalogCategory {
  const CatalogCategory({required this.slug, required this.name});
  final String slug;
  final String name;

  /// DummyJSON returns objects `{slug, name, url}`; older versions returned
  /// plain strings. Pattern matching handles both shapes.
  static CatalogCategory? tryParse(Object? raw) => switch (raw) {
        {'slug': final String slug, 'name': final String name} =>
          CatalogCategory(slug: slug, name: name),
        final String s => CatalogCategory(slug: s, name: s),
        _ => null,
      };
}
