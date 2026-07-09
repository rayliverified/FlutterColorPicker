import 'package:flutter/material.dart';

import 'color_picker_panel.dart';
import '../models/paint_swatch.dart';
import 'recent_colors_view.dart';
import '../utils/recent_colors_manager.dart';

/// Convenience function to show color picker in a dialog.
///
/// Returns the selected color, or null if cancelled.
Future<Color?> showColorPickerDialog({
  required BuildContext context,
  required Color initialColor,
  String title = 'Select Color',
  bool allowOpacity = true,
  bool showRecentColors = true,
  bool showPresets = true,
  bool showPresetLibrary = true,
  List<ColorPreset>? presets,
  List<PresetLibraryEntry>? presetLibrary,
  List<PaintSwatch>? recentSwatches,
  ValueChanged<PaintSwatch>? onRecentSwatchAdd,
  VoidCallback? onCreatePreset,
  ValueChanged<Color>? onPresetLibrarySelected,
}) async {
  return showDialog<Color>(
    context: context,
    builder: (BuildContext context) => ColorPickerDialog(
      initialColor: initialColor,
      title: title,
      allowOpacity: allowOpacity,
      showRecentColors: showRecentColors,
      showPresets: showPresets,
      showPresetLibrary: showPresetLibrary,
      presets: presets,
      presetLibrary: presetLibrary,
      recentSwatches: recentSwatches,
      onRecentSwatchAdd: onRecentSwatchAdd,
      onCreatePreset: onCreatePreset,
      onPresetLibrarySelected: onPresetLibrarySelected,
    ),
  );
}

/// Complete dialog wrapper for color picker.
class ColorPickerDialog extends StatefulWidget {
  /// Initial color value.
  final Color initialColor;

  /// Dialog title.
  final String title;

  /// Enable/disable opacity controls.
  final bool allowOpacity;

  /// Show recent colors section.
  final bool showRecentColors;

  /// Show presets section.
  final bool showPresets;

  /// Show preset library section.
  final bool showPresetLibrary;

  /// Custom preset colors.
  final List<ColorPreset>? presets;

  /// Preset library entries (style sheets).
  final List<PresetLibraryEntry>? presetLibrary;

  /// Custom recent paint swatches (colors or gradients).
  final List<PaintSwatch>? recentSwatches;

  /// Called when user adds paint swatch to recent list.
  final ValueChanged<PaintSwatch>? onRecentSwatchAdd;

  /// Called when user wants to create new preset.
  final VoidCallback? onCreatePreset;

  /// Called when a preset library entry is selected.
  final ValueChanged<Color>? onPresetLibrarySelected;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    this.title = 'Select Color',
    this.allowOpacity = true,
    this.showRecentColors = true,
    this.showPresets = true,
    this.showPresetLibrary = true,
    this.presets,
    this.presetLibrary,
    this.recentSwatches,
    this.onRecentSwatchAdd,
    this.onCreatePreset,
    this.onPresetLibrarySelected,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color selectedColor;
  late Color _initialColor;

  // Auto-load recent colors if not provided
  RecentColorsManager? _recentColorsManager;
  List<PaintSwatch>? _loadedRecentSwatches;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
    _initialColor = widget.initialColor;
    // Auto-load recent colors if not provided and showRecentColors is enabled.
    // Use the shared singleton so dialog and trigger share the same list.
    if (widget.recentSwatches == null && widget.showRecentColors) {
      _recentColorsManager = RecentColorsManager.shared;
      if (_recentColorsManager!.isLoaded) {
        _loadedRecentSwatches = _recentColorsManager!.swatches;
      } else {
        _recentColorsManager!.loadRecentColors().then((_) {
          if (mounted) {
            setState(() {
              _loadedRecentSwatches = _recentColorsManager!.swatches;
            });
          }
        });
      }
      _recentColorsManager!.addListener(_onRecentColorsChanged);
    }
  }

  void _onRecentColorsChanged() {
    if (mounted) {
      setState(() {
        _loadedRecentSwatches = _recentColorsManager!.swatches;
      });
    }
  }

  /// Gets the effective recent swatches (provided or auto-loaded).
  List<PaintSwatch>? get _effectiveRecentSwatches {
    if (widget.recentSwatches != null) {
      return widget.recentSwatches;
    }
    // Return loaded swatches (may be empty list, which is fine)
    return _loadedRecentSwatches;
  }

  /// Calculates estimated height based on what sections are shown.
  ///
  /// Uses the same calculation as ColorPickerTrigger (popup) with dialog-specific offsets:
  /// - Adds dialog actions bar height (+48px)
  /// - Adjusts for dialog-specific padding differences
  ///
  /// The dialog structure:
  /// - AlertDialog with contentPadding: EdgeInsets.zero
  /// - SizedBox with fixed width (320) and calculated height
  /// - Column containing:
  ///   - Expanded ColorPickerPanel (scrollable content with horizontal padding only)
  ///   - Dialog actions Container (with border and padding)
  double _calculateEstimatedHeight() {
    // Use the same calculation as ColorPickerTrigger for the panel height
    double panelHeight = 378.0; // Base color picker height

    final bool hasRecentColors =
        widget.showRecentColors &&
        _effectiveRecentSwatches != null &&
        _effectiveRecentSwatches!.isNotEmpty;
    final bool hasPresets = widget.showPresets;

    // Add height for recent colors section (if shown)
    if (hasRecentColors) {
      // 8px spacing before + ~60px for recent colors view
      panelHeight += 68.0;
    }

    // Add height for presets section (if shown)
    if (hasPresets) {
      // 12px spacing before (if recent colors shown) or 0px + ~56px for presets + 8px padding below
      final spacingBefore = hasRecentColors ? 12.0 : 0.0;
      panelHeight +=
          spacingBefore + 56.0 + 8.0; // spacing + presets + padding below
    }

    // Add compensation for base height reduction (only once, when any section is shown)
    // This matches ColorPickerTrigger calculation
    if (hasRecentColors || hasPresets) {
      panelHeight +=
          22.0; // Compensation for base height reduction from 400 to 378
    }

    // Add height for preset library (if shown)
    if (widget.showPresetLibrary) {
      panelHeight += 20.0; // Additional spacing
    }

    // Remove extra bottom padding when only recent colors are shown (no presets)
    if (hasRecentColors && !hasPresets && !widget.showPresetLibrary) {
      panelHeight -= 12.0; // Remove extra bottom padding (was 20px, now 12px)
    }

    // Add dialog-specific offsets:
    // 1. Dialog actions bar (Cancel/OK buttons): 4px top + 4px bottom + ~40px buttons = ~48px
    double dialogHeight = panelHeight + 48.0;

    // 2. Adjust for dialog-specific padding differences:
    //    - Dialog has different padding behavior than popup, so we need to compensate
    //    - Minimal (no sections): Remove 34px extra padding
    //    - Default (with sections): Remove 30px extra padding
    if (!hasRecentColors && !hasPresets) {
      // Minimal case: no sections shown
      dialogHeight -= 34.0;
    } else {
      // Default case: sections shown
      dialogHeight -= 30.0;
    }

    return dialogHeight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Theme(
      data: theme.copyWith(
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.zero,
        ),
      ),
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 320,
          height: _calculateEstimatedHeight(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use ColorPickerPanel with toolbar in header
              Expanded(
                child: ColorPickerPanel(
                  color: selectedColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  allowOpacity: widget.allowOpacity,
                  showRecentColors: widget.showRecentColors,
                  recentSwatches: _effectiveRecentSwatches,
                  onRecentSwatchAdd:
                      widget.onRecentSwatchAdd ??
                      (swatch) {
                        _recentColorsManager?.addSwatch(swatch).then((_) {
                          if (mounted) {
                            setState(() {
                              _loadedRecentSwatches =
                                  _recentColorsManager?.swatches;
                            });
                          }
                        });
                      },
                  showPresets: widget.showPresets,
                  presets: widget.presets,
                  onCreatePreset: widget.onCreatePreset,
                  showPresetLibrary: widget.showPresetLibrary,
                  presetLibrary: widget.presetLibrary,
                  onPresetLibrarySelected: widget.onPresetLibrarySelected,
                  showPageSwitcher: widget.showPresetLibrary,
                  maxWidth: 320,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  titleBarPadding: const EdgeInsets.only(
                    left: 0,
                    top: 12,
                    right: 0,
                    bottom: 12,
                  ),
                  inputsPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 0,
                  ),
                  slidersPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 0,
                  ),
                ),
              ),
              // Dialog actions
              Container(
                padding: const EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: theme.textTheme.labelMedium,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: theme.textTheme.labelMedium,
                        foregroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {
                        // Save to recent colors if color changed and no callback provided
                        if (selectedColor != _initialColor) {
                          final swatch = PaintSwatch.fromColor(selectedColor);
                          if (widget.onRecentSwatchAdd != null) {
                            widget.onRecentSwatchAdd!(swatch);
                          } else if (_recentColorsManager != null) {
                            // Auto-save to recent colors if using auto-loaded manager
                            _recentColorsManager!.addSwatch(swatch);
                          }
                        }
                        Navigator.of(context).pop(selectedColor);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recentColorsManager?.removeListener(_onRecentColorsChanged);
    super.dispose();
  }
}
