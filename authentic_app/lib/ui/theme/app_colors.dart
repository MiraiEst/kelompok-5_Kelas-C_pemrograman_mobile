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

  /// Light cyan: page titles, summary boxes, icons sitting on [brandTint].
  static const brandIcon = Color(0xFF1DC3FF);

  /// Soft teal-grey borders of cards and stat boxes; also the "won" pill.
  static const cardBorder = Color(0xFFCDE1E7);

  /// Pale cyan header background.
  static const brandTint = Color(0xFFDEFAFF);

  /// Primary call to action (the Sell button).
  static const action = Color(0xFF1991EA);

  /// Ocean blue: titles and primary buttons on detail screens (checkout,
  /// order, bid sheet, listing price card).
  static const ocean = Color(0xFF0082B1);

  /// Pale ocean: back arrow, "How it works" box, rating card border.
  static const oceanLight = Color(0xFF99CDE0);

  /// Outline of text fields in the new forms (sign in, register, sell).
  static const fieldBorder = Color(0xFF3DA0C4);

  /// Mid ocean: outlines of the bid step buttons.
  static const oceanMid = Color(0xFF66B4D0);

  /// Cyan outline of the "Won for" card at checkout.
  static const cyanSoft = Color(0xFF66CDF3);

  /// Faded cyan for upcoming order steps.
  static const cyanFaded = Color(0xFF99DEF7);

  /// Grey fill of soft secondary buttons ("Cancel").
  static const softButton = Color(0xFFF0F0F0);

  /// Outlines of the search box and unselected chips.
  static const outlineSoft = Color(0xFFCCCCCC);

  /// Unselected tab icons.
  static const navInactive = Color(0xFF999999);
}
