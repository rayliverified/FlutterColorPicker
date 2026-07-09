import 'package:flutter/material.dart';

/// Blend mode enum for color panel layer controls.
///
/// This enum provides a simplified interface to Flutter's [BlendMode] with
/// human-readable labels. It maps directly to Flutter's blend modes and is
/// used throughout the color picker for layer compositing.
///
/// Example:
/// ```dart
/// // Get a blend mode
/// final blendMode = BlendModeType.multiply;
///
/// // Convert to Flutter's BlendMode
/// final flutterBlendMode = blendMode.flutterBlendMode;
///
/// // Get human-readable label
/// final label = blendMode.label; // "Multiply"
/// ```
enum BlendModeType {
  normal,
  multiply,
  screen,
  overlay,
  darken,
  lighten,
  colorDodge,
  colorBurn,
  hardLight,
  softLight,
  difference,
  exclusion,
  hue,
  saturation,
  color,
  luminosity,
  clear,
  src,
  dst,
  srcOver,
  dstOver,
  srcIn,
  dstIn,
  srcOut,
  dstOut,
  srcATop,
  dstATop,
  xor,
  plus,
  modulate;

  String get label {
    switch (this) {
      case BlendModeType.normal:
        return 'Normal';
      case BlendModeType.multiply:
        return 'Multiply';
      case BlendModeType.screen:
        return 'Screen';
      case BlendModeType.overlay:
        return 'Overlay';
      case BlendModeType.darken:
        return 'Darken';
      case BlendModeType.lighten:
        return 'Lighten';
      case BlendModeType.colorDodge:
        return 'Color Dodge';
      case BlendModeType.colorBurn:
        return 'Color Burn';
      case BlendModeType.hardLight:
        return 'Hard Light';
      case BlendModeType.softLight:
        return 'Soft Light';
      case BlendModeType.difference:
        return 'Difference';
      case BlendModeType.exclusion:
        return 'Exclusion';
      case BlendModeType.hue:
        return 'Hue';
      case BlendModeType.saturation:
        return 'Saturation';
      case BlendModeType.color:
        return 'Color';
      case BlendModeType.luminosity:
        return 'Luminosity';
      case BlendModeType.clear:
        return 'Clear';
      case BlendModeType.src:
        return 'Source';
      case BlendModeType.dst:
        return 'Destination';
      case BlendModeType.srcOver:
        return 'Source Over';
      case BlendModeType.dstOver:
        return 'Destination Over';
      case BlendModeType.srcIn:
        return 'Source In';
      case BlendModeType.dstIn:
        return 'Destination In';
      case BlendModeType.srcOut:
        return 'Source Out';
      case BlendModeType.dstOut:
        return 'Destination Out';
      case BlendModeType.srcATop:
        return 'Source Atop';
      case BlendModeType.dstATop:
        return 'Destination Atop';
      case BlendModeType.xor:
        return 'XOR';
      case BlendModeType.plus:
        return 'Plus';
      case BlendModeType.modulate:
        return 'Modulate';
    }
  }

  /// Converts this blend mode to Flutter's [BlendMode].
  ///
  /// This is used when applying the blend mode to Flutter's painting operations.
  BlendMode get flutterBlendMode {
    switch (this) {
      case BlendModeType.normal:
      case BlendModeType.srcOver:
        return BlendMode.srcOver;
      case BlendModeType.multiply:
        return BlendMode.multiply;
      case BlendModeType.screen:
        return BlendMode.screen;
      case BlendModeType.overlay:
        return BlendMode.overlay;
      case BlendModeType.darken:
        return BlendMode.darken;
      case BlendModeType.lighten:
        return BlendMode.lighten;
      case BlendModeType.colorDodge:
        return BlendMode.colorDodge;
      case BlendModeType.colorBurn:
        return BlendMode.colorBurn;
      case BlendModeType.hardLight:
        return BlendMode.hardLight;
      case BlendModeType.softLight:
        return BlendMode.softLight;
      case BlendModeType.difference:
        return BlendMode.difference;
      case BlendModeType.exclusion:
        return BlendMode.exclusion;
      case BlendModeType.hue:
        return BlendMode.hue;
      case BlendModeType.saturation:
        return BlendMode.saturation;
      case BlendModeType.color:
        return BlendMode.color;
      case BlendModeType.luminosity:
        return BlendMode.luminosity;
      case BlendModeType.clear:
        return BlendMode.clear;
      case BlendModeType.src:
        return BlendMode.src;
      case BlendModeType.dst:
        return BlendMode.dst;
      case BlendModeType.dstOver:
        return BlendMode.dstOver;
      case BlendModeType.srcIn:
        return BlendMode.srcIn;
      case BlendModeType.dstIn:
        return BlendMode.dstIn;
      case BlendModeType.srcOut:
        return BlendMode.srcOut;
      case BlendModeType.dstOut:
        return BlendMode.dstOut;
      case BlendModeType.srcATop:
        return BlendMode.srcATop;
      case BlendModeType.dstATop:
        return BlendMode.dstATop;
      case BlendModeType.xor:
        return BlendMode.xor;
      case BlendModeType.plus:
        return BlendMode.plus;
      case BlendModeType.modulate:
        return BlendMode.modulate;
    }
  }
}

