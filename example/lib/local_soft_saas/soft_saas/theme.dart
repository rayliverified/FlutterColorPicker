// ignore_for_file: dangling_library_doc_comments

/// Minimal theme configuration used by the standalone color picker example.

import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'typography.dart';

class SoftSaaSTheme {
  SoftSaaSTheme._();

  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final primary = SoftSaaSTokens.primaryColor(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: SoftSaaSTokens.fontFamilyBase,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        error: SoftSaaSTokens.errorColor(brightness),
        surface: SoftSaaSTokens.primaryBackground(brightness),
        outline: SoftSaaSTokens.primaryBorder(brightness),
      ),
      scaffoldBackgroundColor: SoftSaaSTokens.secondaryBackground(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: SoftSaaSTokens.primaryBackground(brightness),
        foregroundColor: SoftSaaSTokens.primaryText(brightness),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: SoftSaaSTypography.heading4(brightness),
      ),
      cardTheme: CardThemeData(
        color: SoftSaaSTokens.primaryBackground(brightness),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          side: BorderSide(color: SoftSaaSTokens.primaryBorder(brightness)),
        ),
      ),
      textTheme: SoftSaaSTypography.getTextTheme(brightness),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SoftSaaSTokens.primaryBackground(brightness),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: SoftSaaSTypography.bodyMediumTertiary(brightness),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
          ),
          padding: SoftSaaSTokens.buttonPaddingMedium,
          textStyle: SoftSaaSTypography.buttonMedium(Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SoftSaaSTokens.primaryText(brightness),
          side: BorderSide(color: SoftSaaSTokens.primaryBorder(brightness)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
          ),
          padding: SoftSaaSTokens.buttonPaddingMedium,
          textStyle: SoftSaaSTypography.buttonMedium(
            SoftSaaSTokens.primaryText(brightness),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
          ),
          padding: SoftSaaSTokens.buttonPaddingMedium,
          textStyle: SoftSaaSTypography.buttonMedium(primary),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: SoftSaaSTokens.secondaryText(brightness),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SoftSaaSTokens.tertiaryBackground(brightness),
        deleteIconColor: SoftSaaSTokens.secondaryText(brightness),
        disabledColor: SoftSaaSTokens.tertiaryBackground(
          brightness,
        ).withValues(alpha: 0.5),
        selectedColor: primary,
        secondarySelectedColor: primary.withValues(alpha: 0.1),
        padding: SoftSaaSTokens.badgePaddingMedium,
        labelStyle: SoftSaaSTypography.badgeMedium(
          SoftSaaSTokens.primaryText(brightness),
        ),
        secondaryLabelStyle: SoftSaaSTypography.badgeMedium(Colors.white),
        brightness: brightness,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusMedium),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: SoftSaaSTokens.primaryBorder(brightness),
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SoftSaaSTokens.primaryBackground(brightness),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radius2XLarge),
        ),
        titleTextStyle: SoftSaaSTypography.heading3(brightness),
        contentTextStyle: SoftSaaSTypography.bodyMedium(brightness),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: brightness == Brightness.light
              ? SoftSaaSTokens.gray800
              : SoftSaaSTokens.gray700,
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
        ),
        textStyle: SoftSaaSTypography.bodySmall(Brightness.dark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
