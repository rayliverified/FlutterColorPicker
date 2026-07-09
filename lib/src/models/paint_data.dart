import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'color_stop.dart';
import 'blend_mode_type.dart';
import '../widgets/color_picker.dart' show PaintType;

/// Unified paint model representing all paint types (solid, gradients).
///
/// This immutable value object encapsulates all paint-related properties
/// with built-in equality, making state management, undo/redo, and
/// persistence straightforward.
///
/// Example:
/// ```dart
/// // Solid color
/// final solidPaint = Paint.solid(color: Colors.blue);
///
/// // Linear gradient
/// final gradientPaint = Paint.gradient(
///   type: PaintType.gradientLinear,
///   stops: [
///     ColorStop(position: 0.0, color: Colors.red),
///     ColorStop(position: 1.0, color: Colors.blue),
///   ],
///   angle: 45,
/// );
///
/// // Check equality
/// if (oldPaint != newPaint) {
///   print('Paint changed!');
/// }
///
/// // Immutable updates
/// final updatedPaint = paint.copyWith(opacity: 0.5);
/// ```
@immutable
class PaintData {
  /// The paint type (solid or gradient variant).
  final PaintType type;

  /// Primary color for solid paints, or base color for gradients.
  final Color color;

  /// Gradient stops (required for gradient types, null for solid).
  final List<ColorStop>? gradientStops;

  /// Currently selected gradient stop index (for editing).
  final int? selectedStopIndex;

  /// Gradient angle in degrees (for linear and angular gradients).
  final double? gradientAngle;

  /// Global opacity for gradients (0.0 to 1.0).
  final double? gradientOpacity;

  /// Blend mode for compositing.
  final BlendModeType? blendMode;

  /// Creates a paint with explicit parameters.
  const PaintData({
    required this.type,
    required this.color,
    this.gradientStops,
    this.selectedStopIndex,
    this.gradientAngle,
    this.gradientOpacity,
    this.blendMode,
  });

  /// Creates a solid color paint.
  const PaintData.solid({required this.color, this.blendMode})
    : type = PaintType.solid,
      gradientStops = null,
      selectedStopIndex = null,
      gradientAngle = null,
      gradientOpacity = null;

  /// Creates a gradient paint.
  PaintData.gradient({
    required this.type,
    required List<ColorStop> stops,
    this.selectedStopIndex,
    this.gradientAngle,
    this.gradientOpacity,
    this.blendMode,
    Color? color,
  }) : assert(
         type == PaintType.gradientLinear ||
             type == PaintType.gradientRadial ||
             type == PaintType.gradientAngular,
         'Paint type must be a gradient type',
       ),
       assert(stops.length >= 2, 'Gradients require at least 2 stops'),
       color = color ?? (stops.isNotEmpty ? stops.first.color : Colors.white),
       gradientStops = stops;

  /// Creates a linear gradient paint.
  PaintData.linearGradient({
    required List<ColorStop> stops,
    double? angle,
    int? selectedStopIndex,
    double? opacity,
    BlendModeType? blendMode,
    Color? color,
  }) : this.gradient(
         type: PaintType.gradientLinear,
         stops: stops,
         gradientAngle: angle,
         selectedStopIndex: selectedStopIndex,
         gradientOpacity: opacity,
         blendMode: blendMode,
         color: color,
       );

  /// Creates a radial gradient paint.
  PaintData.radialGradient({
    required List<ColorStop> stops,
    int? selectedStopIndex,
    double? opacity,
    BlendModeType? blendMode,
    Color? color,
  }) : this.gradient(
         type: PaintType.gradientRadial,
         stops: stops,
         selectedStopIndex: selectedStopIndex,
         gradientOpacity: opacity,
         blendMode: blendMode,
         color: color,
       );

  /// Creates an angular gradient paint.
  PaintData.angularGradient({
    required List<ColorStop> stops,
    double? angle,
    int? selectedStopIndex,
    double? opacity,
    BlendModeType? blendMode,
    Color? color,
  }) : this.gradient(
         type: PaintType.gradientAngular,
         stops: stops,
         gradientAngle: angle,
         selectedStopIndex: selectedStopIndex,
         gradientOpacity: opacity,
         blendMode: blendMode,
         color: color,
       );

  /// Whether this is a solid color paint.
  bool get isSolid => type == PaintType.solid;

  /// Whether this is a gradient paint.
  bool get isGradient =>
      type == PaintType.gradientLinear ||
      type == PaintType.gradientRadial ||
      type == PaintType.gradientAngular;

  /// Whether this is an image paint.
  bool get isImage => type == PaintType.image;

  /// Gets the primary color with global gradient opacity applied.
  Color get effectiveColor {
    if (isSolid || gradientOpacity == null) {
      return color;
    }
    return color.withValues(alpha: color.a * gradientOpacity!);
  }

  /// Creates a copy of this paint with the given fields replaced.
  PaintData copyWith({
    PaintType? type,
    Color? color,
    List<ColorStop>? gradientStops,
    int? selectedStopIndex,
    double? gradientAngle,
    double? gradientOpacity,
    BlendModeType? blendMode,
  }) {
    return PaintData(
      type: type ?? this.type,
      color: color ?? this.color,
      gradientStops: gradientStops ?? this.gradientStops,
      selectedStopIndex: selectedStopIndex ?? this.selectedStopIndex,
      gradientAngle: gradientAngle ?? this.gradientAngle,
      gradientOpacity: gradientOpacity ?? this.gradientOpacity,
      blendMode: blendMode ?? this.blendMode,
    );
  }

  /// Value equality - compares all properties.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaintData &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color &&
          _listEquals(gradientStops, other.gradientStops) &&
          selectedStopIndex == other.selectedStopIndex &&
          gradientAngle == other.gradientAngle &&
          gradientOpacity == other.gradientOpacity &&
          blendMode == other.blendMode;

  @override
  int get hashCode => Object.hash(
    type,
    color,
    Object.hashAll(gradientStops ?? []),
    selectedStopIndex,
    gradientAngle,
    gradientOpacity,
    blendMode,
  );

  /// Compares two lists of gradient stops.
  static bool _listEquals(List<ColorStop>? a, List<ColorStop>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    // Use listEquals from foundation for better performance
    return listEquals(a, b);
  }

  /// Converts this paint to JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'color': color.toARGB32(),
      if (gradientStops != null)
        'gradientStops': gradientStops!
            .map(
              (stop) => {
                'position': stop.position,
                'color': stop.color.toARGB32(),
              },
            )
            .toList(),
      if (selectedStopIndex != null) 'selectedStopIndex': selectedStopIndex,
      if (gradientAngle != null) 'gradientAngle': gradientAngle,
      if (gradientOpacity != null) 'gradientOpacity': gradientOpacity,
      if (blendMode != null) 'blendMode': blendMode!.index,
    };
  }

  /// Creates a paint from JSON.
  factory PaintData.fromJson(Map<String, dynamic> json) {
    final type = PaintType.values[json['type'] as int];
    final color = Color(json['color'] as int);

    List<ColorStop>? gradientStops;
    if (json['gradientStops'] != null) {
      gradientStops = (json['gradientStops'] as List)
          .map(
            (stop) => ColorStop(
              position: stop['position'] as double,
              color: Color(stop['color'] as int),
            ),
          )
          .toList();
    }

    return PaintData(
      type: type,
      color: color,
      gradientStops: gradientStops,
      selectedStopIndex: json['selectedStopIndex'] as int?,
      gradientAngle: json['gradientAngle'] as double?,
      gradientOpacity: json['gradientOpacity'] as double?,
      blendMode: json['blendMode'] != null
          ? BlendModeType.values[json['blendMode'] as int]
          : null,
    );
  }

  @override
  String toString() {
    if (isSolid) {
      return 'Paint.solid(color: $color, blendMode: $blendMode)';
    } else if (isGradient) {
      return 'Paint.gradient('
          'type: $type, '
          'stops: ${gradientStops?.length ?? 0}, '
          'angle: $gradientAngle, '
          'opacity: $gradientOpacity, '
          'blendMode: $blendMode'
          ')';
    } else {
      return 'Paint(type: $type)';
    }
  }
}
