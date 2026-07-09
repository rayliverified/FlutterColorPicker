import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/layer_data.dart';
import 'color_picker.dart';
import 'checkerboard_painter.dart';

/// Default opacity for fallback gradients.
const double _defaultGradientOpacity = 0.3;

/// Widget that renders a preview of multiple layers composited together.
///
/// This widget displays all visible layers stacked with their blend modes applied,
/// showing the final composited result.
class LayersPreview extends StatelessWidget {
  /// List of layers to render (from bottom to top).
  final List<LayerData> layers;

  /// Size of the preview (square).
  final double size;

  /// Border radius of the preview.
  final double borderRadius;

  /// Border width.
  final double borderWidth;

  const LayersPreview({
    super.key,
    required this.layers,
    this.size = 200,
    this.borderRadius = 8,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final checkerboardColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.15);
    final backgroundColor = isDark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFFFFFFF);
    final borderColor = colorScheme.outline.withValues(alpha: 0.5);

    // Filter to only visible layers
    final visibleLayers = layers.where((layer) => layer.visible).toList();

    if (visibleLayers.isEmpty) {
      // Show checkerboard background when no layers are visible
      return SizedBox.square(
        dimension: size,
        child: CustomPaint(
          size: Size(size, size),
          painter: CheckerboardPainter(
            Radius.circular(borderRadius),
            color: checkerboardColor,
            backgroundColor: backgroundColor,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
          ),
        ),
      );
    }

    // Build layers from bottom to top
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Checkerboard background
            CustomPaint(
              size: Size(size, size),
              painter: CheckerboardPainter(
                Radius.zero,
                color: checkerboardColor,
                backgroundColor: backgroundColor,
              ),
            ),
            // Render layers from bottom to top
            ...visibleLayers.reversed.map(
              (layer) => _buildLayer(layer, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayer(LayerData layer, BuildContext context) {
    final blendMode = layer.blendMode.flutterBlendMode;
    final layerWidget = _createLayerWidget(layer, context);

    // Apply blend mode if needed
    if (blendMode != BlendMode.srcOver) {
      return _BlendModeLayer(blendMode: blendMode, child: layerWidget);
    }

    return layerWidget;
  }

  Widget _createLayerWidget(LayerData layer, BuildContext context) {
    switch (layer.paintType) {
      case PaintType.solid:
        return Container(width: size, height: size, color: layer.color);
      case PaintType.gradientLinear:
      case PaintType.gradientRadial:
      case PaintType.gradientAngular:
        return _buildGradientLayer(layer);
      case PaintType.image:
        return _buildImageLayer(layer, context);
    }
  }

  Widget _buildImageLayer(LayerData layer, BuildContext context) {
    if (layer.imageBytes != null) {
      return Image.memory(
        layer.imageBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    // Placeholder for image
    return Container(
      width: size,
      height: size,
      color: layer.color,
      child: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        size: size * 0.3,
      ),
    );
  }

  Widget _buildGradientLayer(LayerData layer) {
    // Use gradient stops if available, otherwise create default gradient
    List<Color> colors;
    List<double>? stops;

    if (layer.gradientStops != null && layer.gradientStops!.isNotEmpty) {
      // Sort stops by position
      final sortedStops = [...layer.gradientStops!]
        ..sort((a, b) => a.position.compareTo(b.position));

      colors = sortedStops.map((stop) {
        // Apply global opacity if set
        if (layer.gradientOpacity != null && layer.gradientOpacity! < 1.0) {
          return stop.color.withValues(
            alpha: stop.color.a * layer.gradientOpacity!,
          );
        }
        return stop.color;
      }).toList();
      stops = sortedStops.map((stop) => stop.position).toList();
    } else {
      // Fallback to simple gradient using layer color
      colors = [
        layer.color,
        layer.color.withValues(alpha: _defaultGradientOpacity),
      ];
      stops = null;
    }

    // Create gradient based on paint type
    final gradient = _createGradient(
      layer.paintType,
      colors,
      stops,
      layer.gradientAngle,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: gradient),
    );
  }

  Gradient _createGradient(
    PaintType paintType,
    List<Color> colors,
    List<double>? stops,
    double? angle,
  ) {
    switch (paintType) {
      case PaintType.gradientLinear:
        return LinearGradient(
          colors: colors,
          stops: stops,
          transform: angle != null
              ? GradientRotation(angle * math.pi / 180.0)
              : null,
        );
      case PaintType.gradientRadial:
        return RadialGradient(colors: colors, stops: stops);
      case PaintType.gradientAngular:
        return SweepGradient(
          colors: colors,
          stops: stops,
          transform: angle != null
              ? GradientRotation(angle * math.pi / 180.0)
              : null,
        );
      default:
        return LinearGradient(colors: colors, stops: stops);
    }
  }
}

/// Widget that applies a blend mode to its child.
class _BlendModeLayer extends SingleChildRenderObjectWidget {
  final BlendMode blendMode;

  const _BlendModeLayer({required this.blendMode, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBlendModeLayer(blendMode);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderBlendModeLayer renderObject,
  ) {
    renderObject.blendMode = blendMode;
  }
}

/// Render object that applies blend mode using saveLayer.
class _RenderBlendModeLayer extends RenderProxyBox {
  BlendMode _blendMode;
  final Paint _paint;

  _RenderBlendModeLayer(this._blendMode)
    : _paint = Paint()..blendMode = _blendMode;

  BlendMode get blendMode => _blendMode;

  set blendMode(BlendMode value) {
    if (_blendMode == value) return;
    _blendMode = value;
    _paint.blendMode = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (blendMode != BlendMode.srcOver && child != null) {
      context.canvas.saveLayer(offset & size, _paint);
      context.paintChild(child!, offset);
      context.canvas.restore();
    } else {
      context.paintChild(child!, offset);
    }
  }
}
