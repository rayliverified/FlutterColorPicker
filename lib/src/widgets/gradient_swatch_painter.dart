import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/color_stop.dart';
import 'color_picker.dart' show PaintType;

/// Painter for gradient swatch display.
class GradientSwatchPainter extends CustomPainter {
  final Color color;
  final PaintType paintType;
  final List<ColorStop>? gradientStops;
  final double? gradientAngle;
  final double? gradientOpacity;

  GradientSwatchPainter({
    required this.color,
    required this.paintType,
    this.gradientStops,
    this.gradientAngle,
    this.gradientOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Use gradient stops if available, otherwise create default gradient
    List<Color> colors;
    List<double>? stops;
    
    if (gradientStops != null && gradientStops!.isNotEmpty) {
      // Sort stops by position
      final sortedStops = [...gradientStops!]
        ..sort((a, b) => a.position.compareTo(b.position));
      
      colors = sortedStops.map((stop) {
        // Apply global opacity if set
        if (gradientOpacity != null && gradientOpacity! < 1.0) {
          return stop.color.withValues(
            alpha: stop.color.a * gradientOpacity!,
          );
        }
        return stop.color;
      }).toList();
      stops = sortedStops.map((stop) => stop.position).toList();
    } else {
      // Fallback to simple gradient
      colors = [color, color.withValues(alpha: 0.3)];
      stops = null;
    }

    // Create gradient based on paint type
    Gradient gradient;
    switch (paintType) {
      case PaintType.gradientLinear:
        gradient = LinearGradient(
          colors: colors,
          stops: stops,
          transform: gradientAngle != null
              ? GradientRotation(gradientAngle! * math.pi / 180.0)
              : null,
        );
        break;
      case PaintType.gradientRadial:
        gradient = RadialGradient(
          colors: colors,
          stops: stops,
        );
        break;
      case PaintType.gradientAngular:
        gradient = SweepGradient(
          colors: colors,
          stops: stops,
          transform: gradientAngle != null
              ? GradientRotation(gradientAngle! * math.pi / 180.0)
              : null,
        );
        break;
      default:
        gradient = LinearGradient(colors: colors, stops: stops);
    }

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(GradientSwatchPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.paintType != paintType ||
        oldDelegate.gradientStops != gradientStops ||
        oldDelegate.gradientAngle != gradientAngle ||
        oldDelegate.gradientOpacity != gradientOpacity;
  }
}
