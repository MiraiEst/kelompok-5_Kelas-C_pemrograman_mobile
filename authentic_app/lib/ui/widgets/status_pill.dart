import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum PillVariant { filled, outlined, soft }

/// Small uppercase label: "HIGHEST BIDDER", "OUTBID", "PAID"…
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.variant = PillVariant.soft});
  final String label;
  final PillVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      PillVariant.filled => (AppColors.ink, AppColors.onInk, AppColors.ink),
      PillVariant.outlined => (AppColors.background, AppColors.ink, AppColors.ink),
      PillVariant.soft => (AppColors.soft, AppColors.ink, AppColors.soft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label.toUpperCase(), style: AppText.pill.copyWith(color: fg)),
    );
  }
}
