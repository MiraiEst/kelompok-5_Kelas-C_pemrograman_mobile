import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import '../../domain/models/catalog_product.dart';

/// Client for DummyJSON (https://dummyjson.com), an open-source fake
/// e-commerce REST API (MIT, github.com/Ovi/DummyJSON).
///
/// Used for "Import from catalog", which pre-fills a new listing with a title,
/// description, category (mapped by ItemCategory.parse) and photo URLs.
class CatalogApi {
  CatalogApi(this._client);
  final http.Client _client;

  static const _base = 'https://dummyjson.com';

  Future<List<CatalogProduct>> search(String query) async {
    final uri = Uri.parse('$_base/products/search').replace(
      queryParameters: {
        'q': query,
        'limit': '20',
        'select': 'title,description,category,price,thumbnail,images',
      },
    );
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    _check(res);
    final body = res.body;
    // Advanced Dart: decode JSON on a background isolate so large responses
    // never block the UI thread.
    return Isolate.run(() => _parseProducts(body));
  }

  static List<CatalogProduct> _parseProducts(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    return (json['products'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(CatalogProduct.fromJson)
        .toList();
  }

  void _check(http.Response res) {
    if (res.statusCode != 200) {
      throw http.ClientException('DummyJSON error ${res.statusCode}', res.request?.url);
    }
  }
}
