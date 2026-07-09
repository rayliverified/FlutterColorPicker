import 'package:flutter/material.dart';

import '../widgets/color_picker.dart';
import 'blend_mode_type.dart';
import 'color_stop.dart';
import 'paint_data.dart' as paint_model;

/// Encapsulates all paint-related state for a color picker.
///
/// **Note:** This is a backward compatibility wrapper around [Paint].
/// New code should use [Paint] directly for simpler APIs.
///
/// This class consolidates color, paint type, blend mode, and gradient properties
/// to simplify change detection and state management in color picker components.
class PaintState {
  /// The underlying paint object.
  final paint_model.PaintData paint;

  /// Creates a paint state by wrapping a Paint object.
  const PaintState._(this.paint);

  // Convenience getters that delegate to Paint for backward compatibility

  /// The primary color value.
  Color get color => paint.color;

  /// The paint type (solid, gradient, image, etc.).
  PaintType get paintType => paint.type;

  /// The blend mode for compositing.
  BlendModeType? get blendMode => paint.blendMode;

  /// Gradient stops (for gradient paint types).
  List<ColorStop>? get gradientStops => paint.gradientStops;

  /// Currently selected gradient stop index.
  int? get selectedStopIndex => paint.selectedStopIndex;

  /// Gradient angle in degrees (for linear and angular gradients).
  double? get gradientAngle => paint.gradientAngle;

  /// Global opacity for gradients.
  double? get gradientOpacity => paint.gradientOpacity;

  /// Creates a paint state from individual properties (backward compatibility).
  PaintState({
    required Color color,
    required PaintType paintType,
    BlendModeType? blendMode,
    List<ColorStop>? gradientStops,
    int? selectedStopIndex,
    double? gradientAngle,
    double? gradientOpacity,
  }) : this._(
         paint_model.PaintData(
           type: paintType,
           color: color,
           gradientStops: gradientStops,
           selectedStopIndex: selectedStopIndex,
           gradientAngle: gradientAngle,
           gradientOpacity: gradientOpacity,
           blendMode: blendMode,
         ),
       );

  /// Creates a paint state from a Paint object.
  factory PaintState.fromPaint(paint_model.PaintData paint) {
    return PaintState._(paint);
  }

  /// Converts this state to a Paint object.
  paint_model.PaintData toPaint() => paint;

  /// Creates a copy of this state with the given fields replaced.
  PaintState copyWith({
    Color? color,
    PaintType? paintType,
    BlendModeType? blendMode,
    List<ColorStop>? gradientStops,
    int? selectedStopIndex,
    double? gradientAngle,
    double? gradientOpacity,
  }) {
    return PaintState._(
      paint.copyWith(
        color: color,
        type: paintType,
        blendMode: blendMode,
        gradientStops: gradientStops,
        selectedStopIndex: selectedStopIndex,
        gradientAngle: gradientAngle,
        gradientOpacity: gradientOpacity,
      ),
    );
  }

  /// Whether this paint type is a gradient mode.
  bool get isGradientMode => paint.isGradient;

  /// Checks if this state is different from another state.
  ///
  /// Returns true if any relevant property has changed.
  /// Delegates to Paint's equality operator.
  bool didChange(PaintState? other) {
    if (other == null) return true;
    return paint != other.paint;
  }

  /// Value equality based on underlying Paint.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaintState) return false;
    return paint == other.paint;
  }

  @override
  int get hashCode => paint.hashCode;

  @override
  String toString() {
    return 'PaintState(paint: $paint)';
  }
}
