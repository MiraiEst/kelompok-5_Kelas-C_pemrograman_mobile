import 'package:flutter/material.dart';

/// Authentic visual style: monochrome (black on white), Poppins, thick black
/// outlines, rounded black buttons and underline text fields.
abstract final class AppColors {
  static const ink = Color(0xFF000000);
  static const paper = Color(0xFFFFFFFF);
  static const muted = Color(0xFF6B6B6B);
  static const line = Color(0xFFDADADA);
  static const fill = Color(0xFFF2F2F2);
  static const error = Color(0xFFC62828);
}

abstract final class AppRadius {
  static const button = 12.0;
  static const card = 16.0;
  static const panel = 28.0;
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.ink,
    onPrimary: AppColors.paper,
    primaryContainer: AppColors.ink,
    onPrimaryContainer: AppColors.paper,
    secondary: AppColors.ink,
    onSecondary: AppColors.paper,
    secondaryContainer: AppColors.fill,
    onSecondaryContainer: AppColors.ink,
    tertiary: AppColors.ink,
    onTertiary: AppColors.paper,
    error: AppColors.error,
    onError: AppColors.paper,
    surface: AppColors.paper,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    surfaceContainerLowest: AppColors.paper,
    surfaceContainerLow: AppColors.paper,
    surfaceContainer: AppColors.paper,
    surfaceContainerHigh: AppColors.fill,
    surfaceContainerHighest: AppColors.fill,
    outline: AppColors.ink,
    outlineVariant: AppColors.line,
    surfaceTint: Colors.transparent,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: 'Poppins');
  final text = base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
  );
  const buttonText = TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500);
  const buttonSize = Size(64, 48);
  const underline = UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ink, width: 1.5));

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.paper,
    textTheme: text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      // Thin black line under every app bar, as in the design.
      shape: Border(bottom: BorderSide(color: AppColors.ink, width: 1.5)),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.paper,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.ink, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        disabledBackgroundColor: AppColors.line,
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        elevation: 0,
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink, width: 1.5),
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ink,
        textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.ink),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.paper,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      ),
      extendedTextStyle: buttonText,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: underline,
      enabledBorder: underline,
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ink, width: 2.5)),
      errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.error, width: 1.5)),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 2.5),
      ),
      contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 6),
      labelStyle: TextStyle(color: AppColors.ink, fontSize: 16),
      floatingLabelStyle: TextStyle(color: AppColors.ink),
      hintStyle: TextStyle(color: AppColors.ink, fontSize: 16),
      helperStyle: TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.ink,
      suffixIconColor: AppColors.ink,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.paper,
      selectedColor: AppColors.ink,
      disabledColor: AppColors.fill,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.ink,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.paper,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(color: AppColors.ink, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
      ),
      checkmarkColor: AppColors.paper,
      showCheckmark: false,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.ink,
        selectedForegroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink, width: 1.5),
        shape: buttonShape,
        textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.ink,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.ink,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.ink,
      labelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.ink, width: 3),
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.panel)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.ink, width: 1.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.panel)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.ink, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.paper),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.ink),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.ink,
      linearTrackColor: AppColors.fill,
    ),
    badgeTheme: const BadgeThemeData(backgroundColor: AppColors.ink, textColor: AppColors.paper),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.ink,
      selectionColor: AppColors.line,
      selectionHandleColor: AppColors.ink,
    ),
  );
}
