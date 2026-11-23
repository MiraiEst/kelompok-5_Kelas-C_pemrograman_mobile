import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// Bold 13px label above a 48px-high input, grey helper text below.
/// Set [rupiah] for money fields: "Rp" prefix + thousands separators.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.rupiah = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled = true,
    this.fieldKey,
    this.focusNode,
    this.labelSuffix,
  });

  final String label;

  /// Grey text appended to the label, e.g. "(optional, hidden)".
  final String? labelSuffix;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final bool rupiah;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final Key? fieldKey;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (labelSuffix != null)
                TextSpan(
                  text: ' $labelSuffix',
                  style: const TextStyle(fontWeight: FontWeight.w400, color: AppColors.muted),
                ),
            ],
          ),
          style: AppText.fieldLabel,
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: fieldKey,
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          validator: validator,
          obscureText: obscureText,
          keyboardType: rupiah ? TextInputType.number : keyboardType,
          textInputAction: textInputAction,
          maxLength: maxLength,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          autofillHints: autofillHints,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          inputFormatters: rupiah
              ? [FilteringTextInputFormatter.digitsOnly, ThousandsFormatter()]
              : inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            prefixText: rupiah ? 'Rp ' : null,
            suffixIcon: suffix,
            counterText: maxLength == null ? null : '',
          ),
        ),
      ],
    );
  }
}

final _thousands = NumberFormat.decimalPattern('id_ID');

/// 500000 -> "500.000" while typing.
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final text = _thousands.format(n);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats an int for a [ThousandsFormatter] field.
String formatThousands(int n) => _thousands.format(n);

/// Reads a money field back: "500.000" -> 500000.
int? parseMoney(String text) => int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
