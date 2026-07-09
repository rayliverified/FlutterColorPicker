import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../widgets/color_picker.dart';
import 'blend_mode_type.dart';
import 'color_stop.dart';
import 'paint_data.dart' as paint_model;

/// Data model representing a paint layer with color, blend mode, and paint type.
///
/// This model is used by [LayersList] and [LayerInfoPanel] to display
/// and manage multiple layers.
class LayerData {
  /// Unique identifier for the layer.
  final String id;

  /// Display name of the layer.
  final String name;

  /// Paint type (solid, gradient, image, etc.).
  final PaintType paintType;

  /// Color value for the layer.
  /// For solid paint types, this is the primary color.
  /// For gradients, this may represent the first stop color.
  final Color color;

  /// Blend mode for layer compositing.
  final BlendModeType blendMode;

  /// Image bytes (for image paint type).
  final Uint8List? imageBytes;

  /// Image name/filename (for image paint type).
  final String? imageName;

  /// Whether this layer is visible.
  final bool visible;

  /// Gradient stops (for gradient paint types).
  final List<ColorStop>? gradientStops;

  /// Currently selected gradient stop index.
  final int? selectedStopIndex;

  /// Gradient angle in degrees (for linear and angular gradients).
  final double? gradientAngle;

  /// Global opacity for gradients.
  final double? gradientOpacity;

  const LayerData({
    required this.id,
    required this.name,
    required this.paintType,
    required this.color,
    required this.blendMode,
    this.imageBytes,
    this.imageName,
    this.visible = true,
    this.gradientStops,
    this.selectedStopIndex,
    this.gradientAngle,
    this.gradientOpacity,
  });

  /// Creates a copy of this layer with the given fields replaced with new values.
  LayerData copyWith({
    String? id,
    String? name,
    PaintType? paintType,
    Color? color,
    BlendModeType? blendMode,
    Uint8List? imageBytes,
    String? imageName,
    bool? visible,
    List<ColorStop>? gradientStops,
    int? selectedStopIndex,
    double? gradientAngle,
    double? gradientOpacity,
  }) {
    return LayerData(
      id: id ?? this.id,
      name: name ?? this.name,
      paintType: paintType ?? this.paintType,
      color: color ?? this.color,
      blendMode: blendMode ?? this.blendMode,
      imageBytes: imageBytes ?? this.imageBytes,
      imageName: imageName ?? this.imageName,
      visible: visible ?? this.visible,
      gradientStops: gradientStops ?? this.gradientStops,
      selectedStopIndex: selectedStopIndex ?? this.selectedStopIndex,
      gradientAngle: gradientAngle ?? this.gradientAngle,
      gradientOpacity: gradientOpacity ?? this.gradientOpacity,
    );
  }

  /// Converts this LayerData to a Paint object.
  paint_model.PaintData toPaint() {
    return paint_model.PaintData(
      type: paintType,
      color: color,
      blendMode: blendMode,
      gradientStops: gradientStops,
      selectedStopIndex: selectedStopIndex,
      gradientAngle: gradientAngle,
      gradientOpacity: gradientOpacity,
    );
  }

  /// Creates a new LayerData from a Paint object, preserving layer-specific properties.
  LayerData withPaint(paint_model.PaintData paint) {
    return copyWith(
      paintType: paint.type,
      color: paint.color,
      blendMode: paint.blendMode,
      gradientStops: paint.gradientStops,
      selectedStopIndex: paint.selectedStopIndex,
      gradientAngle: paint.gradientAngle,
      gradientOpacity: paint.gradientOpacity,
    );
  }

  /// Value equality - compares all properties.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayerData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          paintType == other.paintType &&
          color == other.color &&
          blendMode == other.blendMode &&
          _listEquals(imageBytes, other.imageBytes) &&
          imageName == other.imageName &&
          visible == other.visible &&
          _listEquals(gradientStops, other.gradientStops) &&
          selectedStopIndex == other.selectedStopIndex &&
          gradientAngle == other.gradientAngle &&
          gradientOpacity == other.gradientOpacity;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    paintType,
    color,
    blendMode,
    Object.hashAll(imageBytes ?? []),
    imageName,
    visible,
    Object.hashAll(gradientStops ?? []),
    selectedStopIndex,
    gradientAngle,
    gradientOpacity,
  );

  /// Compares two lists of bytes.
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
