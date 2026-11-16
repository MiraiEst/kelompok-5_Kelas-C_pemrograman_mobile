import 'package:intl/intl.dart';

/// Advanced Dart: extension methods on built-in types.

final _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

extension RupiahFormat on int {
  /// 125000 -> "Rp 125.000"
  String toRupiah() => _rupiah.format(this);
}

extension CountdownFormat on Duration {
  /// Human friendly time-left text, e.g. "2d 4h", "13m 05s", "Ended".
  String toCountdown() {
    if (isNegative || this == Duration.zero) return 'Ended';
    final d = inDays;
    final h = inHours.remainder(24);
    final m = inMinutes.remainder(60);
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return switch ((d, h, m)) {
      (> 0, _, _) => '${d}d ${h}h',
      (0, > 0, _) => '${h}h ${m}m',
      _ => '${m}m ${s}s',
    };
  }
}

extension NameMask on String {
  /// Masks a bidder name for the public bid history: "andi" -> "a***i".
  String masked() {
    final t = trim();
    if (t.isEmpty) return '***';
    if (t.length == 1) return '$t***';
    return '${t[0]}***${t[t.length - 1]}';
  }
}

extension NullableTrim on String? {
  /// Returns null for null / blank strings.
  String? get nullIfBlank {
    final v = this?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }
}
