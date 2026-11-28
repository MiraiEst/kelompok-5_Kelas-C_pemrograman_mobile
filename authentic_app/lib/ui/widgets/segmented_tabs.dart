import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Segmented control in a pale-cyan bordered box (radius 6, height 48). The
/// selected segment is filled cyan with bold white text.
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
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cyanSoft, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: Semantics(
                button: true,
                selected: v == selected,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () => onChanged(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    constraints: const BoxConstraints(minHeight: 46),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    decoration: BoxDecoration(
                      color: v == selected ? AppColors.brandBright : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      label(v),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: v == selected ? AppColors.onInk : AppColors.ink,
                        fontWeight: v == selected ? FontWeight.w700 : FontWeight.w400,
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
