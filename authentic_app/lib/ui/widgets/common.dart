import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

import '../../core/extensions.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';

/// Network image with a neutral placeholder and optional rounded corners.
class ListingImage extends StatelessWidget {
  const ListingImage({
    super.key,
    required this.url,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
  });

  final String? url;

  /// Square size (shortcut for width = height = size).
  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;
    final placeholder = Container(
      width: w,
      height: h,
      color: AppColors.placeholder,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.muted),
    );
    final u = url;
    Widget image = (u == null || u.isEmpty)
        ? placeholder
        : Semantics(
            label: semanticLabel,
            image: semanticLabel != null,
            excludeSemantics: true,
            child: CachedNetworkImage(
              imageUrl: u,
              width: w,
              height: h,
              fit: fit,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            ),
          );
    final r = borderRadius;
    if (r != null) image = ClipRRect(borderRadius: r, child: image);
    return image;
  }
}

/// Live countdown driven by a 1-second timer. Only this text rebuilds.
/// Calls [onFinished] once when the end time passes (closes the auction).
class CountdownText extends StatefulWidget {
  const CountdownText({
    super.key,
    required this.endsAt,
    this.style,
    this.onFinished,
    this.prefix = '',
    this.suffix = '',
    this.format,
  });

  final DateTime endsAt;
  final TextStyle? style;
  final VoidCallback? onFinished;
  final String prefix;
  final String suffix;

  /// Defaults to [CountdownFormat.toClock] ("00:14:05", "2d 04:10:00").
  final String Function(Duration left)? format;

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  Timer? _timer;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final left = widget.endsAt.difference(DateTime.now());
    if (left <= Duration.zero) {
      if (!_fired) {
        _fired = true;
        widget.onFinished?.call();
      }
      _timer?.cancel();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(CountdownText old) {
    super.didUpdateWidget(old);
    if (old.endsAt != widget.endsAt && (_timer == null || !_timer!.isActive)) {
      _fired = false;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.endsAt.difference(DateTime.now());
    if (left <= Duration.zero) return Text(context.l10n.endedLabel, style: widget.style);
    final urgent = left < const Duration(minutes: 10);
    final text = (widget.format ?? (d) => d.toClock())(left);
    return Text(
      '${widget.prefix}$text${widget.suffix}',
      style: urgent
          ? (widget.style ?? const TextStyle()).copyWith(fontWeight: FontWeight.w700)
          : widget.style,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}

/// Error message with an optional "Try again" button.
class ErrorText extends StatelessWidget {
  const ErrorText(this.error, {super.key, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: AppColors.muted),
          const SizedBox(height: 8),
          Text(friendlyError(error), textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            SecondaryButton(label: context.l10n.tryAgain, onPressed: onRetry, expand: false),
          ],
        ],
      ),
    ),
  );
}

/// Short, human message for an exception.
String friendlyError(Object e) {
  final s = e.toString();
  if (s.contains('permission-denied')) return currentL10n.noPermission;
  if (s.contains('unavailable') || s.contains('network')) return currentL10n.noConnection;
  return s.replaceFirst(RegExp(r'^\[[^\]]+\]\s*'), '');
}

/// Grey skeleton block used while loading.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height, this.radius = AppRadius.photo});
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.placeholder,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Round 44x44 icon button with a tooltip (used on top of photos/headers).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = true,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;

  /// Icon colour; when set the button also gets a thin grey ring.
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 22),
    style: IconButton.styleFrom(
      backgroundColor: filled ? AppColors.background : null,
      foregroundColor: color ?? AppColors.ink,
      fixedSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
      shadowColor: AppColors.shadow,
      elevation: filled && color == null ? 1 : 0,
      side: color == null ? null : const BorderSide(color: AppColors.line),
    ),
  );
}

void showSnack(BuildContext context, String message, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}

/// Square product photo on a white rounded card with a soft shadow.
class PhotoCard extends StatelessWidget {
  const PhotoCard({super.key, required this.url, required this.size, this.radius = 10});
  final String? url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [BoxShadow(color: Color(0x29000000), blurRadius: 4, offset: Offset(0, 2))],
    ),
    child: ListingImage(url: url, size: size, borderRadius: BorderRadius.circular(radius)),
  );
}
