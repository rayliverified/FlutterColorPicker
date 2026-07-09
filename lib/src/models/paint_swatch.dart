import 'package:flutter/material.dart';

import 'color_stop.dart';
import 'paint_data.dart' as paint_model;
import '../widgets/color_picker.dart' show PaintType;

/// A paint swatch for display in recent colors, presets, and libraries.
///
/// PaintSwatch wraps a [Paint] object and adds optional metadata like labels.
/// It inherits Paint's value equality, making it easy to compare swatches and
/// detect duplicates.
///
/// This is used in:
/// - Recent colors view
/// - Color presets
/// - Preset library entries
/// - Style sheets
///
/// Example:
/// ```dart
/// final paint = Paint.solid(color: Colors.blue);
/// final swatch = PaintSwatch(paint, label: 'Ocean Blue');
///
/// // Equality works automatically
/// if (currentSwatch == selectedSwatch) { ... }
/// ```
class PaintSwatch {
  /// The underlying paint object.
  final paint_model.PaintData paint;

  /// Optional label for this swatch (e.g., "Ocean Blue", "Sunset Gradient").
  final String? label;

  /// Creates a swatch from a paint object.
  const PaintSwatch(this.paint, {this.label});

  // Convenience getters that delegate to Paint for backward compatibility

  /// Paint type (solid or gradient type).
  PaintType get paintType => paint.type;

  /// Color for solid paints, or first stop color for gradients.
  Color get color => paint.color;

  /// Gradient stops (required for gradient types, null for solid).
  List<ColorStop>? get gradientStops => paint.gradientStops;

  /// Gradient angle in degrees (for linear and angular gradients).
  double? get gradientAngle => paint.gradientAngle;

  /// Global opacity for gradients.
  double? get gradientOpacity => paint.gradientOpacity;

  /// Creates a solid color swatch (backward compatibility constructor).
  PaintSwatch.solid({required Color color, String? label})
    : this(paint_model.PaintData.solid(color: color), label: label);

  /// Creates a gradient swatch (backward compatibility constructor).
  PaintSwatch.gradient({
    required PaintType paintType,
    required List<ColorStop> gradientStops,
    Color? color,
    double? gradientAngle,
    double? gradientOpacity,
    String? label,
  }) : this(
         paint_model.PaintData.gradient(
           type: paintType,
           stops: gradientStops,
           color: color,
           gradientAngle: gradientAngle,
           gradientOpacity: gradientOpacity,
         ),
         label: label,
       );

  /// Creates a solid color swatch from a Color.
  factory PaintSwatch.fromColor(Color color, {String? label}) {
    return PaintSwatch(paint_model.PaintData.solid(color: color), label: label);
  }

  /// Creates a gradient swatch from gradient data.
  factory PaintSwatch.fromGradient({
    required PaintType paintType,
    required List<ColorStop> gradientStops,
    double? gradientAngle,
    double? gradientOpacity,
    String? label,
  }) {
    return PaintSwatch(
      paint_model.PaintData.gradient(
        type: paintType,
        stops: gradientStops,
        gradientAngle: gradientAngle,
        gradientOpacity: gradientOpacity,
      ),
      label: label,
    );
  }

  /// Creates a swatch from a Paint object.
  factory PaintSwatch.fromPaint(paint_model.PaintData paint, {String? label}) {
    return PaintSwatch(paint, label: label);
  }

  /// Whether this is a solid color swatch.
  bool get isSolid => paint.isSolid;

  /// Whether this is a gradient swatch.
  bool get isGradient => paint.isGradient;

  /// Copy this swatch with optional overrides.
  PaintSwatch copyWith({paint_model.PaintData? paint, String? label}) {
    return PaintSwatch(paint ?? this.paint, label: label ?? this.label);
  }

  /// Value equality based on paint and label.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaintSwatch &&
          runtimeType == other.runtimeType &&
          paint == other.paint &&
          label == other.label;

  @override
  int get hashCode => Object.hash(paint, label);

  @override
  String toString() {
    if (label != null) {
      return 'PaintSwatch(paint: $paint, label: "$label")';
    }
    return 'PaintSwatch(paint: $paint)';
  }
}
