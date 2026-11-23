import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Segmented control in a bordered box (radius 10, height 40). The selected
/// segment is ink with bold white text.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: Semantics(
                button: true,
                selected: v == selected,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.input - 2),
                  onTap: () => onChanged(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    constraints: const BoxConstraints(minHeight: AppSizes.segmentedHeight),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: v == selected ? AppColors.ink : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.input - 2),
                    ),
                    child: Text(
                      label(v),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: v == selected ? AppColors.onInk : AppColors.ink,
                        fontWeight: v == selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
