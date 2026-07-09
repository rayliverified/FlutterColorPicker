import 'package:flutter/material.dart';

/// Default box shadow for color picker popup.
/// Matches main app's cardShadow style: blurRadius: 6, offset: Offset(0, 4)
/// with shadow color at ~10% opacity (0x1A000000).
/// 
/// This provides a visible drop shadow that matches the main app's design.
/// Can be customized by passing a different `popupBoxShadow` to ColorPickerTrigger.
const List<BoxShadow> defaultColorPickerPopupShadow = [
  BoxShadow(
    color: Color(0x1A000000), // shadow color from main app (26/255 = ~10% opacity)
    blurRadius: 6,
    offset: Offset(0, 4),
    spreadRadius: 0,
  ),
];
