import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

import '../theme/app_theme.dart';

/// The Authentic "A" brand mark, 72 tall.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 72});
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Authentic',
    image: true,
    child: Image.asset('assets/brand/logo_mark.png', height: height, excludeFromSemantics: true),
  );
}

/// Centred, scrollable column with 24px padding, max 440 wide.
class AuthBody extends StatelessWidget {
  const AuthBody({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    ),
  );
}

/// "──── or ────"
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(context.l10n.or, style: AppText.meta),
      ),
      const Expanded(child: Divider()),
    ],
  );
}

class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, required this.subtitle, this.center = true});
  final String title;
  final String subtitle;
  final bool center;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: AppText.heading,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: AppText.subtitle,
      ),
    ],
  );
}
