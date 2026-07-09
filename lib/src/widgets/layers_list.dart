import 'package:flutter/material.dart';

import '../models/layer_data.dart';
import 'color_picker.dart';
import 'color_picker_trigger.dart';
import 'recent_colors_view.dart';

/// Consolidated callback that returns the entire updated layers list.
/// This simplifies state management by having a single callback for all modifications.
typedef LayersChangedCallback = void Function(List<LayerData> updatedLayers);

/// Widget that displays a list of selectable and rearrangeable layers.
///
/// This widget provides a complete layers list UI with:
/// - Drag handles for reordering
/// - Layer icons based on paint type
/// - Color swatches that open color picker popups
/// - Paint type badges
/// - Selection highlighting
///
/// ## Simplified Usage
///
/// ```dart
/// LayersList(
///   layers: myLayers,
///   onLayersChanged: (updatedLayers) {
///     setState(() => myLayers = updatedLayers);
///   },
///   selectedIndex: selectedIndex,
///   onLayerSelected: (index) => setState(() => selectedIndex = index),
///   enableReorder: true,
///   enableVisibility: true,
///   enableColorPicker: true,
/// )
/// ```
class LayersList extends StatefulWidget {
  /// List of layers to display.
  final List<LayerData> layers;

  /// Consolidated callback for all layer data modifications.
  /// Returns the complete updated layers list.
  ///
  /// This single callback handles:
  /// - Reordering
  /// - Color changes
  /// - Visibility toggles
  /// - Paint type changes
  /// - Gradient modifications
  /// - Blend mode changes
  final LayersChangedCallback onLayersChanged;

  /// Currently selected layer index.
  final int? selectedIndex;

  /// Called when a layer is tapped/selected (functional callback).
  /// If the same layer is tapped again, it will be deselected (index = null).
  ///
  /// This is kept separate because it's about UI state, not data modification.
  final ValueChanged<int?>? onLayerSelected;

  // Feature toggles

  /// Enable drag-to-reorder functionality.
  final bool enableReorder;

  /// Enable visibility toggle button (eye icon).
  final bool enableVisibility;

  /// Enable color picker for layers (clicking color swatch opens popup).
  final bool enableColorPicker;

  /// Enable layer selection highlighting.
  final bool enableSelection;

  // Color picker integration

  /// Show recent colors in color pickers (auto-managed with SharedPreferences).
  final bool showRecentColors;

  /// Color presets for color pickers.
  final List<ColorPreset>? presets;

  /// Preset library entries (style sheets) for color pickers.
  final List<PresetLibraryEntry>? presetLibrary;

  // Styling

  /// Custom decoration for the container.
  final BoxDecoration? decoration;

  /// Padding for each layer item.
  final EdgeInsets itemPadding;

  const LayersList({
    super.key,
    required this.layers,
    required this.onLayersChanged,
    this.selectedIndex,
    this.onLayerSelected,
    this.enableReorder = true,
    this.enableVisibility = true,
    this.enableColorPicker = true,
    this.enableSelection = true,
    this.showRecentColors = true,
    this.presets,
    this.presetLibrary,
    this.decoration,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
  });

  @override
  State<LayersList> createState() => _LayersListState();
}

class _LayersListState extends State<LayersList> {
  /// Updates a single layer and calls the consolidated callback.
  void _updateLayer(int index, LayerData updatedLayer) {
    final updatedLayers = List<LayerData>.from(widget.layers);
    updatedLayers[index] = updatedLayer;
    widget.onLayersChanged(updatedLayers);
  }

  /// Reorders layers and calls the consolidated callback.
  void _reorderLayers(int oldIndex, int newIndex) {
    final updatedLayers = List<LayerData>.from(widget.layers);
    final layer = updatedLayers.removeAt(oldIndex);
    updatedLayers.insert(newIndex, layer);
    widget.onLayersChanged(updatedLayers);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.02)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          padding: EdgeInsets.zero,
          // ignore: deprecated_member_use
          onReorder: widget.enableReorder
              ? (oldIndex, newIndex) {
                  int adjustedNewIndex = newIndex;
                  if (newIndex > oldIndex) {
                    adjustedNewIndex = newIndex - 1;
                  }
                  _reorderLayers(oldIndex, adjustedNewIndex);
                }
              : (_, _) {},
          children: widget.layers.asMap().entries.map((entry) {
            final index = entry.key;
            final layer = entry.value;
            final isSelected =
                widget.enableSelection && widget.selectedIndex == index;

            return _LayerListItem(
              key: ValueKey(layer.id),
              layer: layer,
              index: index,
              isSelected: isSelected,
              enableReorder: widget.enableReorder,
              enableVisibility: widget.enableVisibility,
              enableColorPicker: widget.enableColorPicker,
              enableSelection: widget.enableSelection,
              onTap: widget.enableSelection && widget.onLayerSelected != null
                  ? () {
                      // Toggle selection: if already selected, deselect it
                      if (isSelected) {
                        widget.onLayerSelected!(null);
                      } else {
                        widget.onLayerSelected!(index);
                      }
                    }
                  : null,
              onLayerUpdated: (updatedLayer) =>
                  _updateLayer(index, updatedLayer),
              showRecentColors: widget.showRecentColors,
              presets: widget.presets,
              presetLibrary: widget.presetLibrary,
              itemPadding: widget.itemPadding,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LayerListItem extends StatefulWidget {
  final LayerData layer;
  final int index;
  final bool isSelected;
  final bool enableReorder;
  final bool enableVisibility;
  final bool enableColorPicker;
  final bool enableSelection;
  final VoidCallback? onTap;
  final ValueChanged<LayerData> onLayerUpdated;
  final bool showRecentColors;
  final List<ColorPreset>? presets;
  final List<PresetLibraryEntry>? presetLibrary;
  final EdgeInsets itemPadding;

  const _LayerListItem({
    required this.layer,
    required this.index,
    required this.isSelected,
    required this.enableReorder,
    required this.enableVisibility,
    required this.enableColorPicker,
    required this.enableSelection,
    required this.onTap,
    required this.onLayerUpdated,
    required this.showRecentColors,
    this.presets,
    this.presetLibrary,
    required this.itemPadding,
    super.key,
  });

  @override
  State<_LayerListItem> createState() => _LayerListItemState();
}

class _LayerListItemState extends State<_LayerListItem> {
  /// Returns background color matching modern storybook style.
  Color? _getBackgroundColor(BuildContext context) {
    if (widget.isSelected) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
    }
    return Theme.of(context).colorScheme.surface;
  }

  /// Returns text color matching modern storybook style.
  Color? _getTextColor(BuildContext context) {
    if (widget.isSelected) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final canShowColorSwatch =
        widget.enableColorPicker &&
        (widget.layer.paintType == PaintType.solid ||
            widget.layer.paintType == PaintType.gradientLinear ||
            widget.layer.paintType == PaintType.gradientRadial ||
            widget.layer.paintType == PaintType.gradientAngular);

    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(7),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            height: 44,
            padding: widget.itemPadding,
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                // Drag handle (only if reorder is enabled)
                if (widget.enableReorder) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ReorderableDragStartListener(
                      index: widget.index,
                      child: Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Color swatch (for solid and gradient layers)
                if (canShowColorSwatch) ...[
                  ColorPickerTrigger(
                    paint: widget.layer.toPaint(),
                    onPaintChanged: (paint) {
                      widget.onLayerUpdated(widget.layer.withPaint(paint));
                    },
                    showBlendMode: true,
                    showPageSwitcher: true,
                    showRecentColors: widget.showRecentColors,
                    presets: widget.presets,
                    showPresetLibrary: widget.presetLibrary != null,
                    presetLibrary: widget.presetLibrary,
                  ),
                  const SizedBox(width: 8),
                ],
                // Layer name
                Expanded(
                  child: Text(
                    widget.layer.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getTextColor(context),
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Visibility toggle button (only if enabled)
                if (widget.enableVisibility)
                  Padding(
                    padding: const EdgeInsets.only(right: 4, left: 8),
                    child: Tooltip(
                      message: widget.layer.visible ? 'Hide' : 'Show',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          widget.onLayerUpdated(
                            widget.layer.copyWith(
                              visible: !widget.layer.visible,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            widget.layer.visible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: widget.layer.visible
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.5)
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
