import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client for Frankfurter (https://frankfurter.dev), a free, open-source
/// exchange-rate API (github.com/lineofflight/frankfurter). No API key.
///
/// Used for: showing an auction's price in other currencies, and converting
/// DummyJSON's USD prices into a suggested Rupiah starting price.
class CurrencyApi {
  CurrencyApi(this._client);
  final http.Client _client;

  static const _base = 'https://api.frankfurter.dev/v1';

  final _cache = <String, ({DateTime fetchedAt, Map<String, double> rates})>{};

  /// Rates for 1 unit of [base], e.g. base IDR -> {USD: 0.000061, ...}.
  /// Cached for an hour (rates only change daily).
  Future<Map<String, double>> latest({required String base, required List<String> symbols}) async {
    final key = '$base:${symbols.join(',')}';
    final hit = _cache[key];
    if (hit != null && DateTime.now().difference(hit.fetchedAt) < const Duration(hours: 1)) {
      return hit.rates;
    }
    final uri = Uri.parse(
      '$_base/latest',
    ).replace(queryParameters: {'base': base, 'symbols': symbols.join(',')});
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw http.ClientException('Frankfurter error ${res.statusCode}', uri);
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final rates = (json['rates'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
    _cache[key] = (fetchedAt: DateTime.now(), rates: rates);
    return rates;
  }

  /// Converts a USD amount to whole Rupiah.
  Future<int> usdToIdr(double usd) async {
    final rates = await latest(base: 'USD', symbols: const ['IDR']);
    return (usd * (rates['IDR'] ?? 16000)).round();
  }
}
