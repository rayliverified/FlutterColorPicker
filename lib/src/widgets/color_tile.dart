import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../models/paint_swatch.dart';
import 'color_picker.dart' show PaintType;
import 'checkerboard_painter.dart';

/// Individual color tile widget for displaying colors in grids.
///
/// This widget can display either a solid color or a gradient. It's commonly
/// used in:
/// - Recent colors grids
/// - Color preset grids
/// - Preset library swatch displays
///
/// The tile supports:
/// - Solid colors with optional transparency (checkerboard background)
/// - Linear, radial, and angular gradients
/// - Selection state with visual feedback
/// - Customizable size, border, and styling
///
/// Example:
/// ```dart
/// // Solid color tile
/// ColorTile(
///   color: Colors.blue,
///   onTap: () => selectColor(Colors.blue),
///   isSelected: selectedColor == Colors.blue,
/// )
///
/// // Gradient tile
/// ColorTile.fromSwatch(
///   paintSwatch: gradientSwatch,
///   onTap: () => selectGradient(gradientSwatch),
/// )
/// ```
class ColorTile extends StatelessWidget {
  /// Color to display (for solid colors or as fallback).
  final Color color;
  
  /// Called when tapped.
  final VoidCallback? onTap;
  
  /// Size of the tile.
  final double size;
  
  /// Tooltip text (defaults to hex color or gradient info).
  final String? tooltip;
  
  /// Whether this tile is selected.
  final bool isSelected;
  
  /// Optional paint swatch (for gradient support).
  /// If provided, this will be used instead of just the color.
  final PaintSwatch? paintSwatch;

  /// Border radius (default: 6).
  final double borderRadius;

  /// Border width (default: 1.5 for normal, 2.5 for selected).
  final double? borderWidth;

  /// Border color (defaults to theme-based colors).
  final Color? borderColor;

  /// Whether to show checkerboard background for transparency (default: true).
  final bool showCheckerboard;

  const ColorTile({
    super.key,
    required this.color,
    this.onTap,
    this.size = 24,
    this.tooltip,
    this.isSelected = false,
    this.paintSwatch,
    this.borderRadius = 6,
    this.borderWidth,
    this.borderColor,
    this.showCheckerboard = true,
  });

  /// Creates a ColorTile from a PaintSwatch.
  factory ColorTile.fromSwatch({
    required PaintSwatch paintSwatch,
    VoidCallback? onTap,
    double? size,
    String? tooltip,
    bool isSelected = false,
    double borderRadius = 6,
    double? borderWidth,
    Color? borderColor,
    bool showCheckerboard = true,
  }) {
    return ColorTile(
      color: paintSwatch.color,
      paintSwatch: paintSwatch,
      onTap: onTap,
      size: size ?? 24,
      tooltip: tooltip,
      isSelected: isSelected,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      borderColor: borderColor,
      showCheckerboard: showCheckerboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveSwatch = paintSwatch ?? PaintSwatch.fromColor(color);
    final isGradient = effectiveSwatch.isGradient;
    
    // Check if color has transparency (for checkerboard display)
    final hasTransparency = color.a < 1.0 || 
        (effectiveSwatch.gradientOpacity != null && 
         effectiveSwatch.gradientOpacity! < 1.0);
    
    String getTooltipMessage() {
      if (tooltip != null) return tooltip!;
      if (isGradient) {
        return 'Gradient (${effectiveSwatch.paintType.prettify})';
      }
      return colorToHex(color, withHashtag: true);
    }
    
    // Checkerboard colors
    final checkerboardColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.15);
    final backgroundColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);
    
    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        color: isGradient ? null : color,
        gradient: isGradient ? _buildGradient(effectiveSwatch) : null,
        border: Border.all(
          color: borderColor ??
              (isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.15)),
          width: borderWidth ?? (isSelected ? 2.5 : 1.5),
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
    );
    
    // Wrap with checkerboard if enabled and color has transparency
    if (showCheckerboard && hasTransparency) {
      content = SizedBox.square(
        dimension: size,
        child: CustomPaint(
          size: Size(size, size),
          painter: CheckerboardPainter(
            effectiveBorderRadius.bottomLeft,
            color: checkerboardColor,
            backgroundColor: backgroundColor,
          ),
          child: content,
        ),
      );
    }
    
    return Tooltip(
      message: getTooltipMessage(),
      waitDuration: const Duration(milliseconds: 300),
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
  
  Gradient? _buildGradient(PaintSwatch swatch) {
    if (!swatch.isGradient || swatch.gradientStops == null) return null;
    
    final sortedStops = [...swatch.gradientStops!]
      ..sort((a, b) => a.position.compareTo(b.position));
    
    final colors = sortedStops.map((stop) {
      if (swatch.gradientOpacity != null && swatch.gradientOpacity! < 1.0) {
        return stop.color.withValues(
          alpha: stop.color.a * swatch.gradientOpacity!,
        );
      }
      return stop.color;
    }).toList();
    
    final stops = sortedStops.map((stop) => stop.position).toList();
    
    switch (swatch.paintType) {
      case PaintType.gradientLinear:
        return LinearGradient(
          colors: colors,
          stops: stops,
          transform: swatch.gradientAngle != null
              ? GradientRotation(swatch.gradientAngle! * math.pi / 180.0)
              : null,
        );
      case PaintType.gradientRadial:
        return RadialGradient(
          colors: colors,
          stops: stops,
        );
      case PaintType.gradientAngular:
        return SweepGradient(
          colors: colors,
          stops: stops,
          transform: swatch.gradientAngle != null
              ? GradientRotation(swatch.gradientAngle! * math.pi / 180.0)
              : null,
        );
      default:
        return LinearGradient(colors: colors, stops: stops);
    }
  }
}

