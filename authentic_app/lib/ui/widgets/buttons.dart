import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../l10n/l10n.dart';

/// Full-width pill button (ink background, white bold text, height 52).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.expand = true,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool expand;

  /// Background colour; defaults to the theme's ink.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final child = _ButtonContent(
      label: label,
      icon: icon,
      loading: loading,
      color: AppColors.onInk,
    );
    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      style: color == null ? null : FilledButton.styleFrom(backgroundColor: color),
      child: child,
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Full-width pill button with a 1.5px ink outline.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.expand = true,
    this.dashed = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool expand;

  /// Dashed outline (e.g. "Import from catalog").
  final bool dashed;

  /// Outline and text colour; defaults to the theme's ink.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.ink;
    final child = _ButtonContent(label: label, icon: icon, loading: loading, color: c);
    Widget button = OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: dashed
          ? OutlinedButton.styleFrom(side: BorderSide.none)
          : color == null
          ? null
          : OutlinedButton.styleFrom(
              foregroundColor: c,
              side: BorderSide(color: c, width: 2),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
      child: child,
    );
    if (dashed) {
      button = CustomPaint(
        painter: const DashedBorderPainter(radius: AppRadius.button, color: AppColors.ink),
        child: button,
      );
    }
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.loading,
    required this.color,
  });
  final String label;
  final IconData? icon;
  final bool loading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Semantics(
        label: context.l10n.labelLoading(label),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
      );
    }
    final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Flexible(child: text),
      ],
    );
  }
}

/// Paints a dashed rounded rectangle around its child.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    required this.radius,
    this.color = AppColors.inputBorder,
    this.strokeWidth = 1.5,
    this.dash = 6,
    this.gap = 4,
  });

  final double radius;
  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius.clamp(0, size.shortestSide / 2)),
    ).deflate(strokeWidth / 2);
    final path = Path()..addRRect(r);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.strokeWidth != strokeWidth;
}
