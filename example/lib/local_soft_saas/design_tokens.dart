// ignore_for_file: dangling_library_doc_comments

/// Minimal design tokens used by the standalone color picker example.

import 'package:flutter/material.dart';

class SoftSaaSTokens {
  SoftSaaSTokens._();

  static const lightPrimaryBackground = Color(0xFFFFFFFF);
  static const lightSecondaryBackground = Color(0xFFF9FAFB);
  static const lightTertiaryBackground = Color(0xFFF3F4F6);
  static const lightPrimaryText = Color(0xFF111827);
  static const lightSecondaryText = Color(0xFF4B5563);
  static const lightTertiaryText = Color(0xFF9CA3AF);
  static const lightPrimaryBorder = Color(0xFFE5E7EB);
  static const lightSecondaryBorder = Color(0xFFD1D5DB);

  static const darkPrimaryBackground = Color(0xFF141414);
  static const darkSecondaryBackground = Color(0xFF1C1C1C);
  static const darkTertiaryBackground = Color(0xFF383838);
  static const darkPrimaryText = Color(0xFFFFFFFF);
  static const darkSecondaryText = Color(0x99FFFFFF);
  static const darkTertiaryText = Color(0x66FFFFFF);
  static const darkPrimaryBorder = Color(0xFF383838);
  static const darkSecondaryBorder = Color(0xFF4A4A4A);

  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF3B82F6);
  static const error = Color(0xFFDC2626);
  static const errorDark = Color(0xFFEF4444);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);

  static const radiusSmall = 2.0;
  static const radiusMedium = 6.0;
  static const radiusLarge = 8.0;
  static const radiusXLarge = 12.0;
  static const radius2XLarge = 16.0;

  static const spacing2 = 8.0;

  static const String? fontFamilyBase = null;
  static const fontSize3XL = 30.0;
  static const fontSize2XL = 24.0;
  static const fontSizeLG = 18.0;
  static const fontSizeMD = 16.0;
  static const fontSizeSM = 14.0;
  static const fontSizeXS = 12.0;
  static const fontWeightNormal = FontWeight.w400;
  static const fontWeightMedium = FontWeight.w500;
  static const fontWeightSemibold = FontWeight.w600;
  static const fontWeightBold = FontWeight.w700;

  static const transitionDuration = Duration(milliseconds: 200);
  static const transitionCurve = Curves.easeInOut;
  static const opacityDisabled = 0.5;
  static const opacityHoverLight = 0.05;
  static const opacityHoverDark = 0.10;

  static const iconSizeSmall = 14.0;
  static const iconSizeMedium = 16.0;
  static const iconSizeLarge = 18.0;
  static const iconSizeXL = 24.0;

  static const buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static const buttonPaddingMedium = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const badgePaddingMedium = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 2,
  );

  static Color primaryBackground(Brightness brightness) =>
      brightness == Brightness.light
      ? lightPrimaryBackground
      : darkPrimaryBackground;

  static Color secondaryBackground(Brightness brightness) =>
      brightness == Brightness.light
      ? lightSecondaryBackground
      : darkSecondaryBackground;

  static Color tertiaryBackground(Brightness brightness) =>
      brightness == Brightness.light
      ? lightTertiaryBackground
      : darkTertiaryBackground;

  static Color primaryText(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimaryText : darkPrimaryText;

  static Color secondaryText(Brightness brightness) =>
      brightness == Brightness.light ? lightSecondaryText : darkSecondaryText;

  static Color tertiaryText(Brightness brightness) =>
      brightness == Brightness.light ? lightTertiaryText : darkTertiaryText;

  static Color primaryBorder(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimaryBorder : darkPrimaryBorder;

  static Color secondaryBorder(Brightness brightness) =>
      brightness == Brightness.light
      ? lightSecondaryBorder
      : darkSecondaryBorder;

  static Color primaryColor(Brightness brightness) =>
      brightness == Brightness.light ? primary : primaryDark;

  static Color errorColor(Brightness brightness) =>
      brightness == Brightness.light ? error : errorDark;
}
