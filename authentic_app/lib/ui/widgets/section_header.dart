import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

import '../theme/app_theme.dart';

/// Bold 16px section title with an optional "See all" action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.onSeeAll, this.actionLabel, this.trailing});
  final String title;
  final VoidCallback? onSeeAll;
  final String? actionLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Semantics(header: true, child: Text(title, style: AppText.sectionTitle)),
      ),
      ?trailing,
      if (onSeeAll != null)
        TextButton(onPressed: onSeeAll, child: Text(actionLabel ?? context.l10n.seeAll)),
    ],
  );
}

/// Small uppercase grey group label ("TODAY", "SELLING").
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key, this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 8)});
  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Semantics(header: true, child: Text(text.toUpperCase(), style: AppText.groupLabel)),
  );
}

/// Large page heading at the top of a tab (22 bold).
class PageHeading extends StatelessWidget {
  const PageHeading(this.text, {super.key, this.trailing, this.subtitle});
  final String text;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(header: true, child: Text(text, style: AppText.screenTitle)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppText.meta),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
