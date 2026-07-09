import 'package:flutter/material.dart';

/// A position-color pair representing a gradient stop.
///
/// Gradient stops define the colors and their positions along a gradient axis.
/// The position is a value between 0.0 and 1.0, where 0.0 represents the start
/// of the gradient and 1.0 represents the end.
///
/// Example:
/// ```dart
/// // Create a stop at the beginning (red)
/// final startStop = ColorStop(position: 0.0, color: Colors.red);
///
/// // Create a stop at the end (blue)
/// final endStop = ColorStop(position: 1.0, color: Colors.blue);
///
/// // Create a stop in the middle (green)
/// final middleStop = ColorStop(position: 0.5, color: Colors.green);
///
/// // Update a stop
/// final updatedStop = startStop.copyWith(color: Colors.orange);
/// ```
class ColorStop {
  /// Value between 0.0 and 1.0 representing position along gradient axis.
  ///
  /// - 0.0 = start of gradient
  /// - 1.0 = end of gradient
  /// - 0.5 = middle of gradient
  final double position;

  /// Color attached to the corresponding position.
  final Color color;

  /// Creates a gradient stop with the given position and color.
  const ColorStop({
    required this.position,
    required this.color,
  });

  /// Creates a copy of this stop with the given fields replaced.
  ///
  /// Any field that is not provided will use the current value.
  ColorStop copyWith({
    double? position,
    Color? color,
  }) =>
      ColorStop(
        position: position ?? this.position,
        color: color ?? this.color,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorStop &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          color == other.color;

  @override
  int get hashCode => position.hashCode ^ color.hashCode;

  @override
  String toString() => 'ColorStop(position: $position, color: $color)';
}

