import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

export 'app_colors.dart';

/// Corner radii from the wireframe.
abstract final class AppRadius {
  static const button = 26.0; // pill, height 52
  static const input = 10.0;
  static const card = 12.0;
  static const photo = 10.0;
  static const photoSmall = 8.0;
  static const sheet = 20.0;
  static const pill = 999.0;
}

/// Sizes and spacing from the wireframe.
abstract final class AppSizes {
  static const buttonHeight = 52.0;
  static const inputHeight = 48.0;
  static const touchTarget = 44.0;
  static const navBarHeight = 72.0;
  static const chipHeight = 36.0;
  static const searchHeight = 44.0;
  static const segmentedHeight = 40.0;
  static const indicator = 3.0;
  static const screenPadding = 16.0;
  static const gap = 12.0;
  static const secondaryBorder = 1.5;
}

/// Text styles used directly by widgets (all Inter via the theme).
abstract final class AppText {
  static const screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const heading = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const title = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const profileName = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const emphasis = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const priceHero = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const bidInput = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const subtitle = TextStyle(fontSize: 14, color: AppColors.muted);
  static const fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const body = TextStyle(fontSize: 14, color: AppColors.ink);
  static const small = TextStyle(fontSize: 13, color: AppColors.ink);
  static const caption = TextStyle(fontSize: 12, color: AppColors.muted);
  static const meta = TextStyle(fontSize: 13, color: AppColors.muted);
  static const price = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const groupLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.muted,
  );
  static const pill = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
}

/// Inter text theme. Kept in a function so tests can swap it out.
TextTheme Function([TextTheme? base]) appTextTheme = GoogleFonts.interTextTheme;

ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.ink,
    onPrimary: AppColors.onInk,
    primaryContainer: AppColors.ink,
    onPrimaryContainer: AppColors.onInk,
    secondary: AppColors.ink,
    onSecondary: AppColors.onInk,
    secondaryContainer: AppColors.surface,
    onSecondaryContainer: AppColors.ink,
    tertiary: AppColors.ink,
    onTertiary: AppColors.onInk,
    error: AppColors.error,
    onError: AppColors.onInk,
    surface: AppColors.background,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.background,
    surfaceContainer: AppColors.background,
    surfaceContainerHigh: AppColors.surface,
    surfaceContainerHighest: AppColors.placeholder,
    outline: AppColors.inputBorder,
    outlineVariant: AppColors.line,
    surfaceTint: Colors.transparent,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final text = appTextTheme(
    base.textTheme,
  ).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

  const pill = StadiumBorder();
  const buttonSize = Size(AppSizes.touchTarget, AppSizes.buttonHeight);
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.input),
    borderSide: BorderSide(color: c, width: w),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.merge(AppText.appBarTitle),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.line),
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.onInk,
        disabledBackgroundColor: AppColors.line,
        disabledForegroundColor: AppColors.muted,
        minimumSize: buttonSize,
        shape: pill,
        textStyle: AppText.button,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.onInk,
        elevation: 0,
        minimumSize: buttonSize,
        shape: pill,
        textStyle: AppText.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink, width: AppSizes.secondaryBorder),
        minimumSize: buttonSize,
        shape: pill,
        textStyle: AppText.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.onInk,
      elevation: 2,
      shape: StadiumBorder(),
      extendedSizeConstraints: BoxConstraints.tightFor(height: AppSizes.buttonHeight),
      extendedTextStyle: AppText.button,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      isDense: true,
      constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(AppColors.inputBorder),
      enabledBorder: border(AppColors.inputBorder),
      focusedBorder: border(AppColors.ink, 2),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 2),
      disabledBorder: border(AppColors.line),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      helperStyle: AppText.caption,
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      prefixStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      errorMaxLines: 2,
      helperMaxLines: 2,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.ink,
      disabledColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500, fontSize: 13),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.onInk,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      side: WidgetStateBorderSide.resolveWith(
        (s) => BorderSide(
          color: s.contains(WidgetState.selected) ? AppColors.ink : AppColors.inputBorder,
        ),
      ),
      shape: const StadiumBorder(),
      checkmarkColor: AppColors.onInk,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.ink,
        selectedForegroundColor: AppColors.onInk,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.inputBorder),
        minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.ink,
      unselectedLabelColor: AppColors.muted,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.ink, width: AppSizes.indicator),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: AppColors.line,
      labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.line),
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: TextStyle(color: AppColors.onInk),
      actionTextColor: AppColors.onInk,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.ink, minTileHeight: 48),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.ink,
      linearTrackColor: AppColors.surface,
    ),
    badgeTheme: const BadgeThemeData(backgroundColor: AppColors.ink, textColor: AppColors.onInk),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.onInk : AppColors.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.ink : AppColors.surface,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.ink : AppColors.inputBorder,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.ink : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(AppColors.onInk),
      side: const BorderSide(color: AppColors.ink, width: 1.5),
    ),
    radioTheme: const RadioThemeData(fillColor: WidgetStatePropertyAll(AppColors.ink)),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.ink,
      selectionColor: AppColors.line,
      selectionHandleColor: AppColors.ink,
    ),
  );
}
