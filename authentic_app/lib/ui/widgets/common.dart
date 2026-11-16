import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/extensions.dart';

/// Network image with a neutral placeholder (photos come from URLs, e.g.
/// DummyJSON's CDN, so no paid Firebase Storage is needed for the MVP).
class ListingImage extends StatelessWidget {
  const ListingImage({super.key, required this.url, this.size, this.fit = BoxFit.cover});
  final String? url;
  final double? size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_outlined),
    );
    final u = url;
    if (u == null || u.isEmpty) return placeholder;
    return Image.network(
      u,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

/// Live countdown driven by a 1-second timer. Calls [onFinished] once when
/// the end time passes (used to close the auction).
class CountdownText extends StatefulWidget {
  const CountdownText({super.key, required this.endsAt, this.style, this.onFinished});
  final DateTime endsAt;
  final TextStyle? style;
  final VoidCallback? onFinished;

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
    if (left <= Duration.zero && !_fired) {
      _fired = true;
      widget.onFinished?.call();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.endsAt.difference(DateTime.now());
    final urgent = left > Duration.zero && left < const Duration(minutes: 10);
    return Text(
      left.toCountdown(),
      style: (widget.style ?? const TextStyle()).copyWith(
        color: urgent ? Theme.of(context).colorScheme.error : null,
        fontWeight: urgent ? FontWeight.bold : null,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              Text(text, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class ErrorText extends StatelessWidget {
  const ErrorText(this.error, {super.key});
  final Object error;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error: $error', textAlign: TextAlign.center),
        ),
      );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
