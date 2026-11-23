import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../theme/app_theme.dart';

/// Bold Rupiah amount ("Rp 305.000") at a configurable size.
class PriceText extends StatelessWidget {
  const PriceText(
    this.amount, {
    super.key,
    this.size = 15,
    this.color = AppColors.ink,
    this.weight = FontWeight.w700,
  });
  final int amount;
  final double size;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) => Text(
    amount.toRupiah(),
    style: TextStyle(fontSize: size, fontWeight: weight, color: color),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
