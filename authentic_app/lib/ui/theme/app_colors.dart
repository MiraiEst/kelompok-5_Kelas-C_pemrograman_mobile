import 'package:flutter/material.dart';

/// Every colour used by the app. The wireframe is grayscale; swap these
/// values for the brand palette later without touching any widget.
abstract final class AppColors {
  /// Primary ink: text, filled buttons, selected states.
  static const ink = Color(0xFF1F1F1F);

  /// Secondary text (captions, meta rows).
  static const muted = Color(0xFF6B6B6B);

  /// Body text that is a little softer than [ink] (notification bodies).
  static const body = Color(0xFF4A4A4A);

  /// Hairlines, card borders, dividers.
  static const line = Color(0xFFD9D9D9);

  /// Text field borders.
  static const inputBorder = Color(0xFFBDBDBD);

  /// Grey strips, summary boxes, unread rows.
  static const surface = Color(0xFFF3F3F3);

  /// Soft pills.
  static const soft = Color(0xFFE6E6E6);

  /// Screen background.
  static const background = Color(0xFFFFFFFF);

  /// Image placeholder / skeleton.
  static const placeholder = Color(0xFFEDEDED);

  /// Text and icons on top of [ink].
  static const onInk = Color(0xFFFFFFFF);

  /// Dims the screen behind bottom sheets.
  static const scrim = Color(0x8A000000);

  /// Darkens a photo under an upload spinner.
  static const photoOverlay = Color(0x73000000);

  /// Full-screen photo viewer background.
  static const photoViewer = Color(0xFF000000);

  static const shadow = Color(0x42000000);

  /// Validation errors.
  static const error = Color(0xFFB3261E);

  // Authentic brand palette (home redesign).

  /// Deep teal: section titles, selected chip, active tab icon.
  static const brand = Color(0xFF036786);

  /// Bright cyan: countdown badges, active tab indicator.
  static const brandBright = Color(0xFF00ACEB);

  /// Light cyan for icons sitting on [brandTint].
  static const brandIcon = Color(0xFF1DC3FF);

  /// Pale cyan header background.
  static const brandTint = Color(0xFFDEFAFF);

  /// Primary call to action (the Sell button).
  static const action = Color(0xFF1991EA);

  /// Outlines of the search box and unselected chips.
  static const outlineSoft = Color(0xFFCCCCCC);

  /// Unselected tab icons.
  static const navInactive = Color(0xFF999999);
}
