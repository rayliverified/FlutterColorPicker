import 'package:flutter/material.dart';

import '../models/layer_data.dart';
import '../models/paint_data.dart' as paint_model;
import '../models/paint_swatch.dart';
import '../utils/color_utils.dart';
import 'color_picker.dart';
import 'color_picker_trigger.dart';
import 'recent_colors_view.dart';

/// Widget that displays information about a selected layer.
///
/// Shows layer properties including paint type, blend mode, and color.
/// Includes an interactive color swatch that opens a color picker popup.
///
/// ## Usage
///
/// ```dart
/// LayerInfoPanel(
///   layer: selectedLayer,
///   onPaintChanged: (paint) {
///     // Update layer paint
///   },
///   recentColors: recentColorsList,
///   presets: presetList,
/// )
/// ```
class LayerInfoPanel extends StatelessWidget {
  /// The layer to display information for.
  final LayerData layer;

  /// Called when the layer paint is changed via color picker (unified callback).
  final ValueChanged<paint_model.PaintData>? onPaintChanged;

  /// Recent paint swatches (colors or gradients) for color picker.
  final List<PaintSwatch>? recentSwatches;

  /// Color presets for color picker.
  final List<ColorPreset>? presets;

  /// Called when user wants to add a paint swatch to recent list.
  final ValueChanged<PaintSwatch>? onRecentSwatchAdd;

  /// Custom decoration for the container.
  final BoxDecoration? decoration;

  /// Padding for the container.
  final EdgeInsets padding;

  /// Title text for the panel.
  final String title;

  const LayerInfoPanel({
    super.key,
    required this.layer,
    this.onPaintChanged,
    this.recentSwatches,
    this.presets,
    this.onRecentSwatchAdd,
    this.decoration,
    this.padding = const EdgeInsets.all(20),
    this.title = 'Layer Info',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration:
          decoration ??
          BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(
              10,
            ), // Match main app cardBorderRadius
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildLayerInfo(context, layer),
        ],
      ),
    );
  }

  Widget _buildLayerInfo(BuildContext context, LayerData layer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(context, 'Paint Type', layer.paintType.prettify),
        _buildInfoRow(context, 'Blend Mode', layer.blendMode.label),
        if (layer.paintType == PaintType.solid ||
            layer.paintType == PaintType.gradientLinear ||
            layer.paintType == PaintType.gradientRadial ||
            layer.paintType == PaintType.gradientAngular)
          _buildColorRow(context, layer),
        if (layer.paintType == PaintType.image)
          _buildInfoRow(
            context,
            'Image',
            layer.imageName ?? 'No image selected',
          ),
      ],
    );
  }

  Widget _buildColorRow(BuildContext context, LayerData layer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              'Color',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Color swatch
                ColorPickerTrigger(
                  paint: layer.toPaint(),
                  onPaintChanged: onPaintChanged,
                  size: 24,
                  borderRadius: 4,
                  popupWidth: 300,
                  maxHeight: 650,
                  estimatedHeight: 560,
                  showBlendMode: true,
                  showPageSwitcher: true,
                  showRecentColors: recentSwatches != null,
                  recentSwatches: recentSwatches,
                  onRecentSwatchAdd: onRecentSwatchAdd,
                  showPresets: presets != null,
                  presets: presets,
                ),
                const SizedBox(width: 8),
                // Color hex value
                Expanded(
                  child: Text(
                    colorToHex(layer.color, withHashtag: true),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
