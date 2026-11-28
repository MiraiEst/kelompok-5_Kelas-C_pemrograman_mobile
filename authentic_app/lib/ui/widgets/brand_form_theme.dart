import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Field label style inside a [BrandFormTheme] (bold 16, black).
const brandFieldLabel = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink);

/// Restyles the form controls below it for the new design (sign in,
/// register, sell): ocean-blue 2px rounded fields, bigger bold labels, ocean
/// checkboxes and cyan selected chips. Screens outside it keep the old look.
class BrandFormTheme extends StatelessWidget {
  const BrandFormTheme({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    OutlineInputBorder border(Color c, [double w = 2]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: c, width: w),
    );
    return Theme(
      data: base.copyWith(
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          // Read by AppTextField for its label above the box.
          labelStyle: brandFieldLabel,
          constraints: const BoxConstraints(minHeight: 52),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: border(AppColors.fieldBorder),
          enabledBorder: border(AppColors.fieldBorder),
          focusedBorder: border(AppColors.ocean, 2.5),
          errorBorder: border(AppColors.error),
          focusedErrorBorder: border(AppColors.error, 2.5),
          disabledBorder: border(AppColors.line),
          hintStyle: const TextStyle(color: AppColors.body, fontSize: 15),
          prefixStyle: const TextStyle(color: AppColors.body, fontSize: 15),
        ),
        checkboxTheme: base.checkboxTheme.copyWith(
          fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.ocean : Colors.transparent,
          ),
          side: const BorderSide(color: AppColors.fieldBorder, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        chipTheme: base.chipTheme.copyWith(
          selectedColor: AppColors.brandBright,
          side: WidgetStateBorderSide.resolveWith(
            (s) => BorderSide(
              color: s.contains(WidgetState.selected) ? AppColors.brandBright : AppColors.cyanSoft,
              width: 1.5,
            ),
          ),
        ),
        textSelectionTheme: base.textSelectionTheme.copyWith(
          cursorColor: AppColors.ocean,
          selectionHandleColor: AppColors.ocean,
        ),
      ),
      child: child,
    );
  }
}
