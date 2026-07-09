import 'package:flutter/material.dart';

import 'color_tile.dart';
import '../models/paint_swatch.dart';
import '../utils/color_picker_storage.dart';

/// Represents a color preset with optional label.
/// Uses PaintSwatch to support solid colors and all gradient types.
class ColorPreset {
  /// The paint swatch (solid color or gradient).
  final PaintSwatch swatch;

  /// Optional label for the preset.
  final String? label;

  const ColorPreset({required this.swatch, this.label});

  /// Creates a solid color preset.
  factory ColorPreset.solid({required Color color, String? label}) {
    return ColorPreset(swatch: PaintSwatch.fromColor(color), label: label);
  }

  /// Creates a gradient preset.
  factory ColorPreset.gradient({required PaintSwatch swatch, String? label}) {
    return ColorPreset(swatch: swatch, label: label);
  }
}

/// Display grid of preset colors.
class ColorPresetsView extends StatefulWidget {
  /// List of preset colors to display.
  final List<ColorPreset> presets;

  /// Currently selected swatch (for highlighting).
  final PaintSwatch? currentSwatch;

  /// Called when a preset is selected.
  final ValueChanged<PaintSwatch> onSelected;

  /// Called when "add new" button is tapped (optional).
  final VoidCallback? onCreateNew;

  /// Read-only mode.
  final bool readOnly;

  /// Grid cross-axis count (columns).
  final int crossAxisCount;

  /// Spacing between color tiles.
  final double spacing;

  /// Size of each color tile.
  final double tileSize;

  /// Preset library entries for dropdown selector.
  final List<PresetLibraryEntry>? presetLibrary;

  /// Called when a preset library entry is selected from dropdown.
  final ValueChanged<PaintSwatch>? onPresetLibrarySelected;

  /// Preset library name selected by the parent.
  ///
  /// When provided, the inline presets dropdown follows this selection. This is
  /// used when a swatch is chosen from the library page and the panel returns to
  /// the editor view.
  final String? selectedPresetLibraryName;

  /// Called when the inline presets dropdown changes library.
  final ValueChanged<PresetLibraryEntry>? onPresetLibraryChanged;

  /// Whether to apply component-owned outer padding.
  ///
  /// Set to false when the parent already provides padding.
  final bool applyPadding;

  /// Component-owned outer padding when [applyPadding] is true.
  final EdgeInsets padding;

  /// Whether to show the inline presets label/dropdown above the swatches.
  ///
  /// Set to false when embedded in a titled container such as SoftSaaSPanel.
  final bool showLabel;

  const ColorPresetsView({
    super.key,
    required this.presets,
    required this.onSelected,
    this.currentSwatch,
    this.onCreateNew,
    this.readOnly = false,
    this.crossAxisCount = 9,
    this.spacing = 5,
    this.tileSize = 20,
    this.presetLibrary,
    this.onPresetLibrarySelected,
    this.selectedPresetLibraryName,
    this.onPresetLibraryChanged,
    this.applyPadding = true,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 8),
    this.showLabel = true,
  });

  @override
  State<ColorPresetsView> createState() => _ColorPresetsViewState();
}

class _ColorPresetsViewState extends State<ColorPresetsView> {
  PresetLibraryEntry? _selectedPresetLibrary;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadLastPresetLibrary();
  }

  @override
  void didUpdateWidget(ColorPresetsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPresetLibraryName !=
            oldWidget.selectedPresetLibraryName &&
        widget.selectedPresetLibraryName != null) {
      _selectPresetLibraryByName(widget.selectedPresetLibraryName!);
      return;
    }
    // If preset library changed, reload the last selected library
    if (widget.presetLibrary != oldWidget.presetLibrary && !_isInitialized) {
      _loadLastPresetLibrary();
    }
  }

  void _selectPresetLibraryByName(String name) {
    if (widget.presetLibrary == null || widget.presetLibrary!.isEmpty) {
      return;
    }

    final matchingLibrary = widget.presetLibrary!.firstWhere(
      (entry) => entry.name == name,
      orElse: () => widget.presetLibrary!.first,
    );

    setState(() {
      _selectedPresetLibrary = matchingLibrary;
      _isInitialized = true;
    });
  }

  Future<void> _loadLastPresetLibrary() async {
    if (widget.presetLibrary == null || widget.presetLibrary!.isEmpty) {
      return;
    }

    final lastLibraryName =
        widget.selectedPresetLibraryName ??
        await ColorPickerStorage.loadLastPresetLibrary();
    if (lastLibraryName != null && mounted) {
      final matchingLibrary = widget.presetLibrary!.firstWhere(
        (entry) => entry.name == lastLibraryName,
        orElse: () => widget.presetLibrary!.first,
      );

      setState(() {
        _selectedPresetLibrary = matchingLibrary;
        _isInitialized = true;
      });
    } else if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _savePresetLibrarySelection(PresetLibraryEntry entry) async {
    await ColorPickerStorage.saveLastPresetLibrary(entry.name);
  }

  @override
  Widget build(BuildContext context) {
    // Wait for initialization to complete before showing preset library
    // This prevents flickering from showing default text before switching to saved selection
    if (widget.presetLibrary != null &&
        widget.presetLibrary!.isNotEmpty &&
        !_isInitialized) {
      // Return a minimal widget while loading to maintain layout
      return const SizedBox.shrink();
    }

    // Determine which swatches to show - selected preset library or regular presets
    final List<PaintSwatch> swatchesToShow;
    if (_selectedPresetLibrary != null) {
      swatchesToShow = _selectedPresetLibrary!.swatches;
    } else {
      swatchesToShow = widget.presets.map((p) => p.swatch).toList();
    }

    if (swatchesToShow.isEmpty && widget.onCreateNew == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Presets label with dropdown for preset library
        if (widget.showLabel) ...[
          if (widget.presetLibrary != null && widget.presetLibrary!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: MenuAnchor(
                menuChildren: widget.presetLibrary!.map((
                  PresetLibraryEntry entry,
                ) {
                  return MenuItemButton(
                    onPressed: () {
                      setState(() {
                        _selectedPresetLibrary = entry;
                      });
                      _savePresetLibrarySelection(entry);
                      widget.onPresetLibraryChanged?.call(entry);
                      // Don't auto-select any color when switching preset library
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        entry.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  );
                }).toList(),
                builder:
                    (
                      BuildContext context,
                      MenuController controller,
                      Widget? child,
                    ) {
                      return Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: widget.applyPadding ? 2 : 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    _selectedPresetLibrary?.name ?? 'Presets',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 13,
                                      height: 1.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
              ),
            )
          else
            Text(
              'Presets',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          SizedBox(height: widget.applyPadding ? 8 : 6),
        ],
        RepaintBoundary(
          child: Wrap(
            spacing: widget.spacing,
            runSpacing: widget.spacing,
            children: [
              for (final swatch in swatchesToShow)
                SizedBox(
                  width: widget.tileSize,
                  height: widget.tileSize,
                  child: ColorTile.fromSwatch(
                    paintSwatch: swatch,
                    size: widget.tileSize,
                    isSelected:
                        widget.currentSwatch != null &&
                        _swatchesEqual(swatch, widget.currentSwatch!),
                    onTap: widget.readOnly
                        ? null
                        : () => widget.onSelected(swatch),
                    showCheckerboard: true,
                  ),
                ),
              if (widget.onCreateNew != null && !widget.readOnly)
                SizedBox(
                  width: widget.tileSize,
                  height: widget.tileSize,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onCreateNew,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: widget.tileSize * 0.6,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    // Apply padding only if requested (for standalone use)
    if (widget.applyPadding) {
      return Padding(padding: widget.padding, child: content);
    }
    return content;
  }

  bool _swatchesEqual(PaintSwatch a, PaintSwatch b) {
    return a == b;
  }
}

/// Display grid of recent colors and gradients.
class RecentColorsView extends StatelessWidget {
  /// List of paint swatches (colors or gradients) to display.
  final List<PaintSwatch> swatches;

  /// Maximum number of items to show.
  final int maxItems;

  /// Called when a paint swatch is selected.
  final ValueChanged<PaintSwatch> onSelected;

  /// Current paint swatch (for the "add" button). When provided, shows add button.
  final PaintSwatch? currentSwatch;

  /// Called when "add current" button is tapped with the current swatch.
  /// If null, the add button will not be shown.
  final ValueChanged<PaintSwatch>? onAddCurrent;

  /// Read-only mode.
  final bool readOnly;

  /// Grid cross-axis count (columns).
  final int crossAxisCount;

  /// Spacing between color tiles.
  final double spacing;

  /// Size of each color tile.
  final double tileSize;

  /// Whether to apply component-owned outer padding.
  ///
  /// Set to false when the parent already provides padding.
  final bool applyPadding;

  /// Whether to show the inline label above the swatches.
  ///
  /// Set to false when embedded in a titled container such as SoftSaaSPanel.
  final bool showLabel;

  const RecentColorsView({
    super.key,
    required this.swatches,
    required this.onSelected,
    this.currentSwatch,
    this.onAddCurrent,
    this.readOnly = false,
    this.maxItems = 18,
    this.crossAxisCount = 9,
    this.spacing = 5,
    this.tileSize = 20,
    this.applyPadding = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displaySwatches = swatches.take(maxItems).toList();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showLabel) ...[
          Text(
            'Recent colors',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: applyPadding ? 8 : 6),
        ],
        if (readOnly && displaySwatches.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No colors used recently.',
              style: TextStyle(fontSize: 13, color: colorScheme.secondary),
            ),
          ),
        if (!readOnly || displaySwatches.isNotEmpty)
          RepaintBoundary(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (int i = 0; i < displaySwatches.length; i++)
                  SizedBox(
                    width: tileSize,
                    height: tileSize,
                    child: ColorTile.fromSwatch(
                      paintSwatch: displaySwatches[i],
                      size: tileSize,
                      onTap: readOnly
                          ? null
                          : () => onSelected(displaySwatches[i]),
                      showCheckerboard: true,
                    ),
                  ),
                if (onAddCurrent != null && currentSwatch != null && !readOnly)
                  SizedBox(
                    width: tileSize,
                    height: tileSize,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onAddCurrent!(currentSwatch!),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            size: tileSize * 0.6,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );

    // Apply padding only if requested (for standalone use)
    if (applyPadding) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: content,
      );
    }
    return content;
  }
}

/// Preset library view for displaying style sheet colors.
///
/// This widget displays a grid of preset library entries (typically from style sheets)
/// with color swatches and labels. Users can select entries to apply those colors.
class PresetLibraryView extends StatelessWidget {
  /// List of preset library entries to display.
  final List<PresetLibraryEntry> entries;

  /// Currently selected swatch (for highlighting).
  final PaintSwatch? currentSwatch;

  /// Called when a preset library entry is selected.
  final ValueChanged<PaintSwatch> onSelected;

  /// Read-only mode.
  final bool readOnly;

  /// Grid cross-axis count (columns).
  final int crossAxisCount;

  /// Spacing between color tiles.
  final double spacing;

  /// Size of each color tile.
  final double tileSize;

  /// Maximum number of entries to display.
  final int? maxEntries;

  /// Title text to display above the grid.
  final String title;

  const PresetLibraryView({
    super.key,
    required this.entries,
    required this.onSelected,
    this.currentSwatch,
    this.readOnly = false,
    this.crossAxisCount = 9,
    this.spacing = 5,
    this.tileSize = 20,
    this.maxEntries = 18,
    this.title = 'Paint Styles',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayEntries = maxEntries != null
        ? entries.take(maxEntries!).toList()
        : entries;

    if (displayEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Display each preset library collection with its name and colors
          ...displayEntries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Collection name
                  Text(
                    entry.name,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Collection swatches
                  RepaintBoundary(
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final swatch in entry.swatches)
                          SizedBox(
                            width: tileSize,
                            height: tileSize,
                            child: ColorTile.fromSwatch(
                              paintSwatch: swatch,
                              size: tileSize,
                              isSelected:
                                  currentSwatch != null &&
                                  _swatchesEqual(swatch, currentSwatch!),
                              showCheckerboard: true,
                              onTap: readOnly ? null : () => onSelected(swatch),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _swatchesEqual(PaintSwatch a, PaintSwatch b) {
    return a == b;
  }
}

/// Represents a preset library entry (collection of colors or gradients).
/// Each entry is a named collection/palette containing multiple paint swatches.
class PresetLibraryEntry {
  /// Name/title of the preset collection (e.g., "Modern Blues", "Warm Reds").
  final String name;

  /// List of paint swatches (colors or gradients) in this preset collection.
  final List<PaintSwatch> swatches;

  const PresetLibraryEntry({required this.name, required this.swatches});

  /// Creates a PresetLibraryEntry from colors (convenience factory).
  factory PresetLibraryEntry.fromColors({
    required String name,
    required List<Color> colors,
  }) {
    return PresetLibraryEntry(
      name: name,
      swatches: colors.map((c) => PaintSwatch.fromColor(c)).toList(),
    );
  }
}
