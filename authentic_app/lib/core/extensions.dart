import 'package:intl/intl.dart';

import '../l10n/l10n.dart';

/// Advanced Dart: extension methods on built-in types.

final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

extension RupiahFormat on int {
  /// 125000 -> "Rp 125.000"
  String toRupiah() => _rupiah.format(this);
}

/// "Ended" in the app's current language (Intl.defaultLocale is set from the
/// device language in app.dart).
String get _ended => currentL10n.endedLabel;

extension CountdownFormat on Duration {
  /// Human friendly time-left text, e.g. "2d 4h", "13m 05s", "Ended".
  String toCountdown() {
    if (isNegative || this == Duration.zero) return _ended;
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

extension ClockFormat on Duration {
  /// Countdown clock: "00:14:05", or "2d 04:10:00" when more than a day.
  String toClock() {
    if (isNegative || this == Duration.zero) return '00:00:00';
    String two(int n) => n.toString().padLeft(2, '0');
    final hms =
        '${two(inHours.remainder(24))}:${two(inMinutes.remainder(60))}:'
        '${two(inSeconds.remainder(60))}';
    return inDays > 0 ? '${inDays}d $hms' : hms;
  }

  /// Short "3h 20m" / "2d 4h" / "42m" for meta rows.
  String toShort() {
    if (isNegative || this == Duration.zero) return _ended;
    if (inDays > 0) return '${inDays}d ${inHours.remainder(24)}h';
    if (inHours > 0) return '${inHours}h ${inMinutes.remainder(60)}m';
    if (inMinutes > 0) return '${inMinutes}m';
    return '${inSeconds}s';
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
