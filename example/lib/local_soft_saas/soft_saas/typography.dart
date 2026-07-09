// ignore_for_file: dangling_library_doc_comments

/// Minimal typography helpers used by the standalone example theme/buttons.

import 'package:flutter/material.dart';
import 'design_tokens.dart';

class SoftSaaSTypography {
  SoftSaaSTypography._();

  static TextStyle heading3(Brightness brightness) => TextStyle(
        fontSize: SoftSaaSTokens.fontSizeLG,
        fontWeight: SoftSaaSTokens.fontWeightSemibold,
        color: SoftSaaSTokens.primaryText(brightness),
      );

  static TextStyle heading4(Brightness brightness) => TextStyle(
        fontSize: SoftSaaSTokens.fontSizeMD,
        fontWeight: SoftSaaSTokens.fontWeightSemibold,
        color: SoftSaaSTokens.primaryText(brightness),
      );

  static TextStyle bodyMedium(Brightness brightness) => TextStyle(
        fontSize: SoftSaaSTokens.fontSizeSM,
        fontWeight: SoftSaaSTokens.fontWeightNormal,
        color: SoftSaaSTokens.primaryText(brightness),
      );

  static TextStyle bodyMediumTertiary(Brightness brightness) =>
      bodyMedium(brightness).copyWith(color: SoftSaaSTokens.tertiaryText(brightness));

  static TextStyle bodySmall(Brightness brightness) => TextStyle(
        fontSize: SoftSaaSTokens.fontSizeXS,
        fontWeight: SoftSaaSTokens.fontWeightNormal,
        color: SoftSaaSTokens.primaryText(brightness),
      );

  static TextStyle buttonSmall(Color color) => _button(color, SoftSaaSTokens.fontSizeXS);
  static TextStyle buttonMedium(Color color) => _button(color, SoftSaaSTokens.fontSizeXS);
  static TextStyle buttonLarge(Color color) => _button(color, SoftSaaSTokens.fontSizeSM);

  static TextStyle badgeMedium(Color color) => TextStyle(
        fontSize: SoftSaaSTokens.fontSizeXS,
        fontWeight: SoftSaaSTokens.fontWeightMedium,
        color: color,
      );

  static TextTheme getTextTheme(Brightness brightness) => TextTheme(
        displayLarge: heading3(brightness).copyWith(fontSize: SoftSaaSTokens.fontSize3XL),
        displayMedium: heading3(brightness).copyWith(fontSize: SoftSaaSTokens.fontSize2XL),
        titleLarge: heading3(brightness),
        titleMedium: heading4(brightness),
        bodyLarge: bodyMedium(brightness).copyWith(fontSize: SoftSaaSTokens.fontSizeMD),
        bodyMedium: bodyMedium(brightness),
        bodySmall: bodySmall(brightness),
        labelLarge: buttonLarge(SoftSaaSTokens.primaryText(brightness)),
        labelMedium: buttonMedium(SoftSaaSTokens.primaryText(brightness)),
        labelSmall: buttonSmall(SoftSaaSTokens.primaryText(brightness)),
      );

  static TextStyle _button(Color color, double fontSize) => TextStyle(
        fontSize: fontSize,
        fontWeight: SoftSaaSTokens.fontWeightSemibold,
        color: color,
      );
}
