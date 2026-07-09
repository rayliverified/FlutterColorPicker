import 'package:flutter/material.dart';

import 'color_picker.dart';
import 'paint_type_dropdown.dart';
import 'blend_mode_dropdown.dart';
import 'recent_colors_view.dart';
import 'color_tile.dart';
import 'gradient_editor.dart';
import '../models/blend_mode_type.dart';
import '../models/color_stop.dart';
import '../models/paint_swatch.dart';
import '../models/paint_state.dart';
import '../utils/default_preset_library.dart';

// Constants matching main app
const EdgeInsets _kPresetLibraryPadding = EdgeInsets.fromLTRB(
  12, // left
  8, // top (reduced from 16)
  12, // right
  16, // bottom
);

/// Simplified color picker panel with a clean layout:
/// - Toolbar (mode, blend mode, preset library icon, close button)
/// - Scrollable color picker section
class ColorPickerPanel extends StatefulWidget {
  /// Initial color value.
  final Color color;

  /// Called when color changes (during drag).
  final ValueChanged<Color> onColorChanged;

  /// Called when user starts interacting.
  final VoidCallback? onColorChangeStart;

  /// Called when user finishes interacting.
  final VoidCallback? onColorChangeEnd;

  /// Enable/disable opacity controls.
  final bool allowOpacity;

  /// Padding around hex/alpha inputs.
  final EdgeInsets? inputsPadding;

  /// Padding around sliders.
  final EdgeInsets? slidersPadding;

  /// Padding around the entire content area (editing controls), excluding the toolbar.
  final EdgeInsets? contentPadding;

  /// Fixed height for palette (null = expand to fill).
  final double? paletteHeight;

  /// Read-only mode.
  final bool readOnly;

  /// Maximum width constraint.
  final double? maxWidth;

  /// Currently selected paint type.
  final PaintType? paintType;

  /// Called when paint type changes.
  final ValueChanged<PaintType>? onPaintTypeChanged;

  /// Supported paint types (default: Solid, Linear, Radial, Angular, Image).
  final List<PaintType> supportedTypes;

  /// Show blend mode dropdown.
  final bool showBlendMode;

  /// Currently selected blend mode.
  final BlendModeType? blendMode;

  /// Called when blend mode changes.
  final ValueChanged<BlendModeType>? onBlendModeChanged;

  /// Show page switcher (Library/Editor toggle).
  final bool showPageSwitcher;

  /// Initial page index (0 = Editor, 1 = Library).
  final int initialPageIndex;

  /// Called when page changes.
  final ValueChanged<int>? onPageChanged;

  /// Whether to show close button.
  final bool showCloseButton;

  /// Called when close button is pressed.
  final VoidCallback? onClose;

  /// Title bar padding.
  final EdgeInsets titleBarPadding;

  /// Title text to display in header (default: null, shows paint type dropdown).
  final String? title;

  /// Whether to show divider after title bar.
  final bool showDivider;

  /// Called when header drag starts (for draggable popup support).
  final ValueChanged<Offset>? onHeaderDragStart;

  /// Called when header drag updates (for draggable popup support).
  final ValueChanged<Offset>? onHeaderDragUpdate;

  /// Called when header drag ends (for draggable popup support).
  final VoidCallback? onHeaderDragEnd;

  /// Show recent colors section below picker.
  final bool showRecentColors;

  /// Custom recent paint swatches (colors or gradients).
  final List<PaintSwatch>? recentSwatches;

  /// Called when user adds the current paint swatch to recent list.
  /// The callback receives the current swatch (solid color or gradient).
  final ValueChanged<PaintSwatch>? onRecentSwatchAdd;

  /// Called when a paint swatch is selected from recent colors.
  final ValueChanged<PaintSwatch>? onRecentSwatchSelected;

  /// Show color presets section below picker.
  final bool showPresets;

  /// Custom preset colors.
  ///
  /// If null, the library will use default presets from DefaultPresetLibrary.
  /// If an empty list [] is provided, no presets will be shown.
  final List<ColorPreset>? presets;

  /// Called when user wants to create new preset.
  final VoidCallback? onCreatePreset;

  /// Show preset library (style sheets) section.
  final bool showPresetLibrary;

  /// List of preset library entries (style sheets).
  final List<PresetLibraryEntry>? presetLibrary;

  /// Called when a preset library entry is selected.
  final ValueChanged<Color>? onPresetLibrarySelected;

  // Gradient-related properties
  /// Current gradient stops (for gradient modes).
  final List<ColorStop>? gradientStops;

  /// Called when gradient stops change.
  final ValueChanged<List<ColorStop>>? onGradientStopsChanged;

  /// Currently selected gradient stop index.
  final int? selectedStopIndex;

  /// Called when a gradient stop is selected.
  final ValueChanged<int>? onStopSelected;

  /// Current gradient angle in degrees (for linear and angular gradients).
  final double? gradientAngle;

  /// Called when gradient angle changes.
  final ValueChanged<double>? onGradientAngleChanged;

  /// Global opacity for gradients.
  final double? gradientOpacity;

  /// Called when gradient opacity changes.
  final ValueChanged<double>? onGradientOpacityChanged;

  const ColorPickerPanel({
    super.key,
    this.color = Colors.white,
    required this.onColorChanged,
    this.onColorChangeStart,
    this.onColorChangeEnd,
    this.allowOpacity = true,
    this.inputsPadding,
    this.slidersPadding,
    this.contentPadding,
    this.paletteHeight,
    this.readOnly = false,
    this.maxWidth = 300.0,
    this.paintType,
    this.onPaintTypeChanged,
    this.supportedTypes = const [
      PaintType.solid,
      PaintType.gradientLinear,
      PaintType.gradientRadial,
      PaintType.gradientAngular,
      PaintType.image,
    ],
    this.showBlendMode = false,
    this.blendMode,
    this.onBlendModeChanged,
    this.showPageSwitcher = false,
    this.initialPageIndex = 0,
    this.onPageChanged,
    this.showCloseButton = false,
    this.onClose,
    this.titleBarPadding = const EdgeInsets.only(left: 8, top: 8, right: 8),
    this.title,
    this.showDivider = true,
    this.onHeaderDragStart,
    this.onHeaderDragUpdate,
    this.onHeaderDragEnd,
    this.showRecentColors = true,
    this.recentSwatches,
    this.onRecentSwatchAdd,
    this.onRecentSwatchSelected,
    this.showPresets = true,
    this.presets,
    this.onCreatePreset,
    this.showPresetLibrary = false,
    this.presetLibrary,
    this.onPresetLibrarySelected,
    this.gradientStops,
    this.onGradientStopsChanged,
    this.selectedStopIndex,
    this.onStopSelected,
    this.gradientAngle,
    this.onGradientAngleChanged,
    this.gradientOpacity,
    this.onGradientOpacityChanged,
  });

  @override
  State<ColorPickerPanel> createState() => _ColorPickerPanelState();
}

class _ColorPickerPanelState extends State<ColorPickerPanel> {
  late PaintState _paintState;
  late int _currentPageIndex;
  int? _localSelectedStopIndex;

  /// Creates a PaintState from current widget properties.
  PaintState _createPaintStateFromWidget() {
    // Initialize paint type - use provided paintType, or infer from gradientStops,
    // or default to first supported type
    PaintType paintType;
    if (widget.paintType != null) {
      paintType = widget.paintType!;
    } else if (widget.gradientStops != null &&
        widget.gradientStops!.isNotEmpty) {
      // If gradientStops exist but paintType is null, default to linear gradient
      paintType = PaintType.gradientLinear;
    } else {
      paintType = widget.supportedTypes.first;
    }

    return PaintState(
      color: widget.color,
      paintType: paintType,
      blendMode: widget.blendMode ?? BlendModeType.normal,
      gradientStops: widget.gradientStops,
      selectedStopIndex: widget.selectedStopIndex,
      gradientAngle: widget.gradientAngle,
      gradientOpacity: widget.gradientOpacity,
    );
  }

  @override
  void initState() {
    super.initState();
    _paintState = _createPaintStateFromWidget();
    _currentPageIndex = widget.initialPageIndex;
    _localSelectedStopIndex = widget.selectedStopIndex;

    // If in gradient mode and no stops exist, create default stops
    if (_paintState.isGradientMode &&
        (_paintState.gradientStops == null ||
            _paintState.gradientStops!.isEmpty)) {
      final defaultStops = [
        ColorStop(position: 0.0, color: _paintState.color),
        ColorStop(
          position: 1.0,
          color: _paintState.color.withValues(alpha: 0.3),
        ),
      ];
      _paintState = _paintState.copyWith(gradientStops: defaultStops);
      // Check if we need to initialize the selection before setting it
      final shouldNotifySelection =
          widget.selectedStopIndex == null && _localSelectedStopIndex == null;
      _localSelectedStopIndex ??= 0;
      // Notify parent of default stops
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onGradientStopsChanged?.call(defaultStops);
        if (shouldNotifySelection) {
          widget.onStopSelected?.call(0);
        }
      });
    }

    // Initialize angle for linear and angular gradients if not already set
    if ((_paintState.paintType == PaintType.gradientLinear ||
            _paintState.paintType == PaintType.gradientAngular) &&
        _paintState.gradientAngle == null &&
        widget.gradientAngle == null) {
      _paintState = _paintState.copyWith(gradientAngle: 0.0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onGradientAngleChanged?.call(0.0);
      });
    }
  }

  @override
  void didUpdateWidget(covariant ColorPickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newPaintState = _createPaintStateFromWidget();

    // Check if paint state changed using simplified didChange method
    if (newPaintState.didChange(_paintState)) {
      final oldPaintState = _paintState;

      setState(() {
        // Only update color if we're in solid mode
        // In gradient mode, color changes come from gradient stops
        if (!newPaintState.isGradientMode && widget.color != oldWidget.color) {
          _paintState = _paintState.copyWith(color: widget.color);
        }

        // Update paint type if explicitly provided and changed
        if (widget.paintType != null &&
            widget.paintType != oldPaintState.paintType) {
          _paintState = _paintState.copyWith(paintType: widget.paintType);

          // If switching to gradient mode and no stops exist, create default stops
          if (newPaintState.isGradientMode &&
              (widget.gradientStops == null || widget.gradientStops!.isEmpty)) {
            final defaultStops = [
              ColorStop(position: 0.0, color: _paintState.color),
              ColorStop(
                position: 1.0,
                color: _paintState.color.withValues(alpha: 0.3),
              ),
            ];
            _paintState = _paintState.copyWith(gradientStops: defaultStops);
            // Check if we need to initialize the selection before setting it
            final shouldNotifySelection =
                widget.selectedStopIndex == null &&
                _localSelectedStopIndex == null;
            _localSelectedStopIndex ??= 0;
            widget.onGradientStopsChanged?.call(defaultStops);
            if (shouldNotifySelection) {
              widget.onStopSelected?.call(0);
            }
          }

          // Reset blend mode to Normal when switching to gradient types
          if (newPaintState.isGradientMode &&
              oldPaintState.blendMode != BlendModeType.normal) {
            _paintState = _paintState.copyWith(blendMode: BlendModeType.normal);
            widget.onBlendModeChanged?.call(BlendModeType.normal);
          }

          // Initialize angle for linear and angular gradients if not already set
          if ((widget.paintType == PaintType.gradientLinear ||
                  widget.paintType == PaintType.gradientAngular) &&
              _paintState.gradientAngle == null &&
              widget.gradientAngle == null) {
            _paintState = _paintState.copyWith(gradientAngle: 0.0);
            widget.onGradientAngleChanged?.call(0.0);
          }
        }

        // Update blend mode if changed
        if (widget.blendMode != null &&
            widget.blendMode != oldPaintState.blendMode) {
          _paintState = _paintState.copyWith(blendMode: widget.blendMode);
        }

        // Update gradient stops if changed
        if (widget.gradientStops != null &&
            widget.gradientStops != oldPaintState.gradientStops) {
          _paintState = _paintState.copyWith(
            gradientStops: widget.gradientStops,
          );
        }

        // Update gradient angle if changed
        if (widget.gradientAngle != null &&
            widget.gradientAngle != oldPaintState.gradientAngle) {
          _paintState = _paintState.copyWith(
            gradientAngle: widget.gradientAngle,
          );
        }
      });
    }

    // Update page index if changed
    if (widget.initialPageIndex != oldWidget.initialPageIndex &&
        widget.initialPageIndex != _currentPageIndex) {
      _currentPageIndex = widget.initialPageIndex;
    }

    // Update selected stop index only if the parent's value actually changed
    // (not just because it differs from our local value)
    if (widget.selectedStopIndex != oldWidget.selectedStopIndex) {
      _localSelectedStopIndex = widget.selectedStopIndex;
    }
  }

  void _changePage(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    widget.onPageChanged?.call(index);
  }

  /// Gets the effective presets (provided, default library presets, or empty list).
  List<ColorPreset> get _effectivePresets {
    // If presets are explicitly provided, use them (overrides defaults)
    if (widget.presets != null) {
      return widget.presets!;
    }

    // Otherwise, use default presets from the library
    // Get the first/default preset library entry (Codelessly)
    final defaultLibrary =
        DefaultPresetLibrary.getByName('Codelessly') ??
        (DefaultPresetLibrary.all.isNotEmpty
            ? DefaultPresetLibrary.all.first
            : null);

    if (defaultLibrary != null) {
      // Convert PaintSwatch objects to ColorPreset objects
      return defaultLibrary.swatches
          .map((swatch) => ColorPreset(swatch: swatch))
          .toList();
    }

    // Fallback to empty list if no defaults available
    return [];
  }

  /// Gets the effective preset library (provided or default library).
  /// When null, uses DefaultPresetLibrary.all. When empty list [], shows nothing.
  List<PresetLibraryEntry>? get _effectivePresetLibrary {
    // If explicitly provided (even if empty), use it
    if (widget.presetLibrary != null) {
      return widget.presetLibrary;
    }

    // If null, use default preset library
    return DefaultPresetLibrary.all;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check if we should show preset library page
    final bool shouldShowPageView =
        widget.showPageSwitcher &&
        _currentPageIndex == 1 &&
        (_paintState.paintType == PaintType.solid ||
            _paintState.paintType == PaintType.gradientLinear ||
            _paintState.paintType == PaintType.gradientRadial ||
            _paintState.paintType == PaintType.gradientAngular);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar with mode, blend mode, preset library icon, and close button
        // Wrap header with GestureDetector for dragging support
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: widget.onHeaderDragStart != null
              ? (DragStartDetails details) {
                  widget.onHeaderDragStart!.call(details.globalPosition);
                }
              : null,
          onPanUpdate: widget.onHeaderDragUpdate != null
              ? (DragUpdateDetails details) {
                  widget.onHeaderDragUpdate!.call(details.delta);
                }
              : null,
          onPanEnd: widget.onHeaderDragEnd != null
              ? (_) {
                  widget.onHeaderDragEnd!.call();
                }
              : null,
          child: MouseRegion(
            cursor: widget.onHeaderDragStart != null
                ? SystemMouseCursors.move
                : SystemMouseCursors.basic,
            child: Container(
              padding: widget.titleBarPadding.copyWith(
                left: 8,
                top: 4,
                right: 4,
                bottom: 4,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title widget (custom title text or paint type + blend mode)
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )
                  else ...[
                    // Paint type dropdown
                    if (widget.readOnly)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        child: Text(
                          _paintState.paintType.prettify,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      PaintTypeDropdown(
                        value: _paintState.paintType,
                        items: widget.supportedTypes,
                        onChanged: (PaintType? value) {
                          if (value != null && value != _paintState.paintType) {
                            final isNewGradientMode =
                                value == PaintType.gradientLinear ||
                                value == PaintType.gradientRadial ||
                                value == PaintType.gradientAngular;

                            setState(() {
                              _paintState = _paintState.copyWith(
                                paintType: value,
                              );
                            });

                            // If switching to gradient mode and no stops exist, create default stops
                            if (isNewGradientMode &&
                                (widget.gradientStops == null ||
                                    widget.gradientStops!.isEmpty)) {
                              final defaultStops = [
                                ColorStop(
                                  position: 0.0,
                                  color: _paintState.color,
                                ),
                                ColorStop(
                                  position: 1.0,
                                  color: _paintState.color.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ];
                              _paintState = _paintState.copyWith(
                                gradientStops: defaultStops,
                              );
                              // Check if we need to initialize the selection before setting it
                              final shouldNotifySelection =
                                  widget.selectedStopIndex == null &&
                                  _localSelectedStopIndex == null;
                              _localSelectedStopIndex ??= 0;
                              widget.onGradientStopsChanged?.call(defaultStops);
                              if (shouldNotifySelection) {
                                widget.onStopSelected?.call(0);
                              }
                            }

                            // Reset blend mode to Normal when switching to gradient types
                            if (isNewGradientMode &&
                                _paintState.blendMode != BlendModeType.normal) {
                              setState(() {
                                _paintState = _paintState.copyWith(
                                  blendMode: BlendModeType.normal,
                                );
                              });
                              widget.onBlendModeChanged?.call(
                                BlendModeType.normal,
                              );
                            }

                            // Initialize angle for linear and angular gradients if not already set
                            if ((value == PaintType.gradientLinear ||
                                    value == PaintType.gradientAngular) &&
                                _paintState.gradientAngle == null &&
                                widget.gradientAngle == null) {
                              _paintState = _paintState.copyWith(
                                gradientAngle: 0.0,
                              );
                              widget.onGradientAngleChanged?.call(0.0);
                            }

                            widget.onPaintTypeChanged?.call(value);
                          }
                        },
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                    // Blend mode dropdown (only when not using custom title)
                    if (widget.showBlendMode && widget.title == null) ...[
                      const SizedBox(width: 8),
                      if (widget.readOnly)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          child: Text(
                            _paintState.blendMode?.label ??
                                BlendModeType.normal.label,
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      else
                        BlendModeDropdown(
                          value: _paintState.blendMode ?? BlendModeType.normal,
                          items: BlendModeType.values,
                          onChanged: (BlendModeType? value) {
                            if (value != null &&
                                value != _paintState.blendMode) {
                              setState(() {
                                _paintState = _paintState.copyWith(
                                  blendMode: value,
                                );
                              });
                              widget.onBlendModeChanged?.call(value);
                            }
                          },
                          theme: theme,
                          colorScheme: colorScheme,
                        ),
                    ],
                  ],
                  const Spacer(),
                  // Preset library icon (page switcher)
                  if (widget.showPageSwitcher &&
                      (_paintState.paintType == PaintType.solid ||
                          _paintState.paintType == PaintType.gradientLinear ||
                          _paintState.paintType == PaintType.gradientRadial ||
                          _paintState.paintType == PaintType.gradientAngular))
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Tooltip(
                        message: _currentPageIndex == 0 ? 'Library' : 'Editor',
                        waitDuration: const Duration(seconds: 1),
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: widget.readOnly
                                ? null
                                : () =>
                                      _changePage((_currentPageIndex + 1) % 2),
                            child: Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                _currentPageIndex == 0
                                    ? Icons.book
                                    : Icons.gps_not_fixed,
                                size: 14,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Close button
                  if (widget.showCloseButton)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: widget.readOnly
                              ? null
                              : () {
                                  widget.onClose?.call();
                                },
                          child: Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
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
        // Divider after toolbar
        if (widget.showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        // Scrollable color picker section
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              child: widget.contentPadding != null
                  ? Padding(
                      padding: widget.contentPadding!,
                      child: shouldShowPageView
                          ? _buildPresetLibraryContent(theme, colorScheme)
                          : _buildEditorContent(),
                    )
                  : (shouldShowPageView
                        ? _buildPresetLibraryContent(theme, colorScheme)
                        : _buildEditorContent()),
            ),
          ),
        ),
      ],
    );

    Widget result = content;

    // Apply width constraint
    if (widget.maxWidth != null) {
      result = SizedBox(width: widget.maxWidth, child: result);
    }

    return result;
  }

  /// Builds the editor content (color picker, recent colors, presets).
  Widget _buildEditorContent() {
    // Get gradient stops - use paint state or create defaults from current color
    List<ColorStop>? effectiveGradientStops = _paintState.gradientStops;
    if (_paintState.isGradientMode &&
        (effectiveGradientStops == null || effectiveGradientStops.isEmpty)) {
      // Create default stops from current color
      effectiveGradientStops = [
        ColorStop(position: 0.0, color: _paintState.color),
        ColorStop(
          position: 1.0,
          color: _paintState.color.withValues(alpha: 0.3),
        ),
      ];
      // Update local state and notify parent
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if we need to initialize the selection before updating state
        final shouldNotifySelection =
            widget.selectedStopIndex == null && _localSelectedStopIndex == null;

        setState(() {
          _paintState = _paintState.copyWith(
            gradientStops: effectiveGradientStops,
          );
          _localSelectedStopIndex ??= 0;
        });
        widget.onGradientStopsChanged?.call(effectiveGradientStops!);

        // Only notify parent of selection if we don't already have a selection
        if (shouldNotifySelection) {
          widget.onStopSelected?.call(0);
        }
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Solid mode: color picker
        if (!_paintState.isGradientMode) ...[
          ColorPicker(
            color: _paintState.color,
            onColorChanged: (Color color) {
              setState(() {
                _paintState = _paintState.copyWith(color: color);
              });
              widget.onColorChanged(color);
            },
            onColorChangeStart: widget.onColorChangeStart,
            onColorChangeEnd: widget.onColorChangeEnd,
            allowOpacity: widget.allowOpacity,
            inputsPadding: widget.inputsPadding,
            slidersPadding: widget.slidersPadding,
            paletteHeight: widget.paletteHeight,
            readOnly: widget.readOnly,
            showTitleBar: false,
            showToolbar:
                true, // Show toolbar inside ColorPicker for hex/opacity inputs
            showDivider: false,
            maxWidth: null,
            showRecentColors: false,
            showPresets: false,
            showPresetLibrary: false,
          ),
        ],
        // Gradient mode: gradient editor
        if (_paintState.isGradientMode && effectiveGradientStops != null) ...[
          GradientEditor(
            stops: effectiveGradientStops,
            onStopsChanged: (stops) {
              setState(() {
                _paintState = _paintState.copyWith(gradientStops: stops);
              });
              widget.onGradientStopsChanged?.call(stops);
            },
            selectedStopIndex: _localSelectedStopIndex ?? 0,
            onStopSelected: (index) {
              setState(() {
                _localSelectedStopIndex = index;
              });
              widget.onStopSelected?.call(index);
            },
            onChangeStart: widget.onColorChangeStart,
            onChangeEnd: widget.onColorChangeEnd,
            readOnly: widget.readOnly,
            paintType: _paintState.paintType,
            gradientAngle: _paintState.gradientAngle ?? widget.gradientAngle,
            onGradientAngleChanged: (double angle) {
              setState(() {
                _paintState = _paintState.copyWith(gradientAngle: angle);
              });
              widget.onGradientAngleChanged?.call(angle);
            },
            onAngleChangeEnd: widget.onColorChangeEnd,
            gradientOpacity: widget.gradientOpacity,
            onGradientOpacityChanged: widget.onGradientOpacityChanged,
            globalControls: null, // Toolbar is now outside scrollable
            stopControls: _buildStopColorPicker(effectiveGradientStops),
          ),
        ],
        // Recent colors (with spacing)
        if (widget.showRecentColors && widget.recentSwatches != null) ...[
          const SizedBox(height: 8),
          RecentColorsView(
            swatches: widget.recentSwatches!,
            currentSwatch: _getCurrentSwatch(),
            onAddCurrent: widget.onRecentSwatchAdd,
            onSelected: (PaintSwatch swatch) {
              if (widget.onRecentSwatchSelected != null) {
                widget.onRecentSwatchSelected!(swatch);
              }
              _applySwatch(swatch);
            },
            readOnly: widget.readOnly,
            // Disable padding if parent provides contentPadding
            applyPadding: widget.contentPadding == null,
          ),
        ],
        // Spacing before presets/preset library
        if (widget.showPresets) const SizedBox(height: 12),
        // Presets
        if (widget.showPresets) ...[
          ColorPresetsView(
            presets: _effectivePresets,
            currentSwatch: _getCurrentSwatch(),
            onSelected: _applySwatch,
            onCreateNew: widget.onCreatePreset,
            readOnly: widget.readOnly,
            presetLibrary: widget.showPresetLibrary
                ? _effectivePresetLibrary
                : null,
            onPresetLibrarySelected:
                widget.showPresetLibrary && _effectivePresetLibrary != null
                ? (PaintSwatch swatch) =>
                      _applySwatch(swatch, notifyPresetLibrary: true)
                : null,
            // Disable padding if parent provides contentPadding
            applyPadding: widget.contentPadding == null,
          ),
          const SizedBox(height: 8), // Padding below presets
        ],
      ],
    );
  }

  /// Builds the color picker for editing a selected gradient stop's color.
  Widget? _buildStopColorPicker(List<ColorStop> effectiveStops) {
    final selectedIndex = _localSelectedStopIndex ?? 0;
    if (selectedIndex < 0 || selectedIndex >= effectiveStops.length) {
      return null;
    }

    final selectedStop = effectiveStops[selectedIndex];

    return ColorPicker(
      key: ValueKey('stop_color_picker_$selectedIndex'),
      color: selectedStop.color,
      paintType: PaintType.solid, // Stop color picker is always in solid mode
      onColorChanged: (Color color) {
        // Update the selected stop's color in paint state
        final currentStops = _paintState.gradientStops ?? effectiveStops;
        if (selectedIndex >= 0 && selectedIndex < currentStops.length) {
          final newStops = [...currentStops];
          newStops[selectedIndex] = ColorStop(
            position: newStops[selectedIndex].position,
            color: color,
          );
          setState(() {
            _paintState = _paintState.copyWith(gradientStops: newStops);
          });
          widget.onGradientStopsChanged?.call(newStops);
        }
      },
      onColorChangeStart: widget.onColorChangeStart,
      onColorChangeEnd: widget.onColorChangeEnd,
      allowOpacity: widget.allowOpacity,
      paletteHeight: 210,
      showTitleBar: false,
      showRecentColors: false,
      showPresets: false,
      showPresetLibrary: false,
      readOnly: widget.readOnly,
      inputsPadding: widget.inputsPadding,
      slidersPadding:
          widget.slidersPadding ??
          const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      showToolbar: true,
      showDivider: false,
      maxWidth: null,
    );
  }

  /// Gets the current paint swatch from the current state.
  PaintSwatch _getCurrentSwatch() {
    if (_paintState.isGradientMode &&
        _paintState.gradientStops != null &&
        _paintState.gradientStops!.isNotEmpty) {
      return PaintSwatch.fromGradient(
        paintType: _paintState.paintType,
        gradientStops: _paintState.gradientStops!,
        gradientAngle: _paintState.gradientAngle,
        gradientOpacity: _paintState.gradientOpacity,
      );
    }
    return PaintSwatch.fromColor(_paintState.color);
  }

  /// Applies a swatch (gradient or solid color) to the current paint state.
  void _applySwatch(PaintSwatch swatch, {bool notifyPresetLibrary = false}) {
    if (swatch.isGradient) {
      // Apply the full gradient
      setState(() {
        _paintState = _paintState.copyWith(
          paintType: swatch.paintType,
          gradientStops: swatch.gradientStops,
          gradientAngle: swatch.gradientAngle,
          gradientOpacity: swatch.gradientOpacity,
          color: swatch.color,
        );
        // Initialize selected stop index if not set
        if (_localSelectedStopIndex == null ||
            _localSelectedStopIndex! >= (swatch.gradientStops?.length ?? 0)) {
          _localSelectedStopIndex = 0;
        }
      });
      widget.onPaintTypeChanged?.call(swatch.paintType);
      widget.onGradientStopsChanged?.call(swatch.gradientStops!);
      if (swatch.gradientAngle != null) {
        widget.onGradientAngleChanged?.call(swatch.gradientAngle!);
      }
      if (swatch.gradientOpacity != null) {
        widget.onGradientOpacityChanged?.call(swatch.gradientOpacity!);
      }
      // Notify parent of stop selection if needed
      if (widget.selectedStopIndex == null) {
        widget.onStopSelected?.call(_localSelectedStopIndex ?? 0);
      }
      widget.onColorChanged(swatch.color);
      if (notifyPresetLibrary) {
        widget.onPresetLibrarySelected?.call(swatch.color);
      }
      widget.onColorChangeEnd?.call();
    } else {
      // Solid color
      if (_paintState.isGradientMode) {
        // In gradient mode, update the selected stop's color
        if (_paintState.gradientStops != null &&
            _paintState.gradientStops!.isNotEmpty) {
          final selectedIndex = _localSelectedStopIndex ?? 0;
          if (selectedIndex >= 0 &&
              selectedIndex < _paintState.gradientStops!.length) {
            final newStops = [..._paintState.gradientStops!];
            newStops[selectedIndex] = ColorStop(
              position: newStops[selectedIndex].position,
              color: swatch.color,
            );
            setState(() {
              _paintState = _paintState.copyWith(gradientStops: newStops);
            });
            widget.onGradientStopsChanged?.call(newStops);
            if (notifyPresetLibrary) {
              widget.onPresetLibrarySelected?.call(swatch.color);
            }
            widget.onColorChangeEnd?.call();
          }
        }
      } else {
        setState(() {
          _paintState = _paintState.copyWith(color: swatch.color);
        });
        widget.onColorChanged(swatch.color);
        if (notifyPresetLibrary) {
          widget.onPresetLibrarySelected?.call(swatch.color);
        }
        widget.onColorChangeEnd?.call();
      }
    }
  }

  /// Builds the preset library page content.
  Widget _buildPresetLibraryContent(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: _kPresetLibraryPadding,
      child: _effectivePresetLibrary == null || _effectivePresetLibrary!.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No preset library entries available.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Display each preset library collection with its name and colors
                ..._effectivePresetLibrary!.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Collection name - matching presets style
                        Text(
                          entry.name,
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Collection swatches - matching presets style
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            for (final swatch in entry.swatches)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: ColorTile.fromSwatch(
                                  paintSwatch: swatch,
                                  size: 20,
                                  isSelected: _getCurrentSwatch() == swatch,
                                  onTap: widget.readOnly
                                      ? null
                                      : () => _applySwatch(
                                          swatch,
                                          notifyPresetLibrary: true,
                                        ),
                                  showCheckerboard:
                                      false, // Disable for small tiles in grid
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
