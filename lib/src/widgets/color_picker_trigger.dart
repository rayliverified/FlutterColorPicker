import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'color_tile.dart';
import 'color_picker.dart';
import 'color_picker_panel.dart';
import '../models/blend_mode_type.dart';
import '../models/paint_data.dart' as paint_model;
import '../models/paint_state.dart';
import 'recent_colors_view.dart';
import '../models/color_stop.dart';
import '../models/paint_swatch.dart';
import 'popup_resize_handle.dart';
import '../utils/popup_positioning_utils.dart';
import '../utils/popup_constants.dart';
import '../utils/recent_colors_manager.dart';
import '../utils/default_preset_library.dart';

/// A clickable widget that opens a color picker popup.
///
/// This widget displays a color swatch and opens a popup with ColorPickerPanel
/// when clicked, similar to the main app's ColorPickerField behavior.
///
/// **Simplified API:** Uses the unified [Paint] model with a single callback.
///
/// ## Usage:
///
/// **Simple solid color:**
/// ```dart
/// ColorPickerTrigger(
///   color: Colors.blue,
///   onPaintChanged: (newPaint) {
///     setState(() => myColor = newPaint.color);
///   },
/// )
/// ```
///
/// **Advanced (gradients, blend modes):**
/// ```dart
/// ColorPickerTrigger(
///   paint: myPaint,
///   onPaintChanged: (newPaint) {
///     setState(() => myPaint = newPaint);
///   },
/// )
/// ```
///
/// If a [child] widget is provided, it will be used as the tap target instead
/// of the built-in color swatch. This allows you to wrap any custom widget.
class ColorPickerTrigger extends StatefulWidget {
  /// Current paint (solid color or gradient).
  ///
  /// Either [paint] or [color] must be provided, but not both.
  /// Use [color] for simple solid color picking, or [paint] for advanced features.
  final paint_model.PaintData? paint;

  /// Convenience parameter for simple solid color picking.
  ///
  /// Either [color] or [paint] must be provided, but not both.
  /// When [color] is provided, it's internally converted to a solid Paint.
  final Color? color;

  /// Optional custom child widget to use as the tap target.
  ///
  /// If provided, this widget will be used instead of the built-in color swatch.
  /// If null, the default color swatch will be displayed.
  final Widget? child;

  /// Called when paint changes (consolidated callback for all modifications).
  ///
  /// This single callback handles:
  /// - Color changes
  /// - Paint type changes (solid ↔ gradient)
  /// - Blend mode changes
  /// - Gradient stops modifications
  /// - Gradient angle/opacity changes
  final ValueChanged<paint_model.PaintData>? onPaintChanged;

  /// Called when user starts interacting.
  final VoidCallback? onPaintChangeStart;

  /// Called when user finishes interacting.
  final VoidCallback? onPaintChangeEnd;

  /// Size of the color swatch. Defaults to 24 if not provided.
  final double? size;

  /// Border radius of the color swatch.
  final double borderRadius;

  /// Border width of the color swatch.
  final double borderWidth;

  /// Enable/disable opacity controls in picker.
  final bool allowOpacity;

  /// Show recent colors in picker.
  final bool showRecentColors;

  /// Custom recent paint swatches (colors or gradients).
  final List<PaintSwatch>? recentSwatches;

  /// Called when user adds a paint swatch to recent list.
  /// The callback receives the swatch (solid color or gradient).
  /// Automatically called on popup close if changes were made.
  final ValueChanged<PaintSwatch>? onRecentSwatchAdd;

  /// Called when a paint swatch is selected from recent colors.
  /// The callback receives the swatch (solid color or gradient).
  final ValueChanged<PaintSwatch>? onRecentSwatchSelected;

  /// Show color presets in picker.
  final bool showPresets;

  /// Custom preset colors.
  ///
  /// If null (default when not provided), the library will use default presets
  /// from DefaultPresetLibrary. If an empty list [] is explicitly provided,
  /// no presets will be shown.
  final List<ColorPreset>? presets;

  /// Called when user wants to create new preset.
  final VoidCallback? onCreatePreset;

  /// Show preset library in picker.
  final bool showPresetLibrary;

  /// List of preset library entries.
  final List<PresetLibraryEntry>? presetLibrary;

  /// Called when a preset library entry is selected.
  final ValueChanged<Color>? onPresetLibrarySelected;

  /// Show blend mode dropdown.
  final bool showBlendMode;

  /// Show page switcher (Library/Editor toggle).
  final bool showPageSwitcher;

  /// Currently selected image bytes (for image mode).
  final Uint8List? imageBytes;

  /// Name of the currently selected image.
  final String? imageName;

  /// Called when user wants to pick an image.
  final VoidCallback? onPickImage;

  /// Called when user wants to clear the selected image.
  final VoidCallback? onClearImage;

  /// Custom builder for image picker.
  final Widget Function(BuildContext context)? imagePickerBuilder;

  /// Read-only mode.
  final bool readOnly;

  /// Fixed width for the popup (required, always known).
  final double popupWidth;

  /// Estimated height for initial positioning (used to calculate vertical position).
  final double estimatedHeight;

  /// Minimum height for the popup (default: 200).
  final double minHeight;

  /// Maximum height for the popup (default: 650).
  final double maxHeight;

  /// Key for persisting popup height (if null, height is not persisted).
  final String? heightPersistenceKey;

  /// Custom box shadow for popup (defaults to modern shadow if null).
  final List<BoxShadow>? popupBoxShadow;

  const ColorPickerTrigger({
    super.key,
    this.paint,
    this.color,
    this.child,
    this.onPaintChanged,
    this.onPaintChangeStart,
    this.onPaintChangeEnd,
    this.size,
    this.borderRadius = 4,
    this.borderWidth = 0,
    this.allowOpacity = true,
    this.showRecentColors = true,
    this.recentSwatches,
    this.onRecentSwatchAdd,
    this.onRecentSwatchSelected,
    this.showPresets = true,
    this.presets,
    this.onCreatePreset,
    this.showPresetLibrary = true,
    this.presetLibrary,
    this.onPresetLibrarySelected,
    this.showBlendMode = false,
    this.showPageSwitcher = false,
    this.imageBytes,
    this.imageName,
    this.onPickImage,
    this.onClearImage,
    this.imagePickerBuilder,
    this.readOnly = false,
    this.popupWidth = 300,
    this.estimatedHeight = 560,
    this.minHeight = 200,
    this.maxHeight = 650,
    this.heightPersistenceKey,
    this.popupBoxShadow,
  }) : assert(
         paint != null || color != null,
         'Either paint or color must be provided',
       ),
       assert(
         paint == null || color == null,
         'Cannot provide both paint and color. Use paint for advanced features '
         'or color for simple solid color picking.',
       );

  @override
  State<ColorPickerTrigger> createState() => _ColorPickerTriggerState();
}

class _ColorPickerTriggerState extends State<ColorPickerTrigger> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _popupKey = GlobalKey();
  PaintState? _currentPopupState; // Track current paint state in popup
  PaintState? _initialPopupState; // Track initial paint state when popup opened
  Offset? _popupPosition; // Track popup position for dragging
  double? _popupHeight; // Track popup height (for resize)

  // Auto-load recent colors if not provided
  RecentColorsManager? _recentColorsManager;
  List<PaintSwatch>? _loadedRecentSwatches;

  void _onRecentColorsChanged() {
    if (mounted) {
      setState(() {
        _loadedRecentSwatches = _recentColorsManager!.swatches;
      });
    }
  }

  /// Gets the effective paint (from [paint] parameter or converted from [color]).
  paint_model.PaintData get _effectivePaint {
    if (widget.paint != null) {
      return widget.paint!;
    }
    // Convert color to solid paint
    return paint_model.PaintData.solid(color: widget.color!);
  }

  @override
  void initState() {
    super.initState();
    // Auto-load recent colors if not provided and showRecentColors is enabled.
    // Use the shared singleton so all triggers stay in sync.
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

  /// Creates a PaintState from current widget Paint.
  PaintState _createPaintState() {
    final paint = _effectivePaint;
    return PaintState(
      color: paint.color,
      paintType: paint.type,
      blendMode: paint.blendMode,
      gradientStops: paint.gradientStops,
      selectedStopIndex: paint.selectedStopIndex,
      gradientAngle: paint.gradientAngle,
      gradientOpacity: paint.gradientOpacity,
    );
  }

  /// Converts a PaintState to a Paint object and calls onPaintChanged.
  void _notifyPaintChanged(PaintState state) {
    final newPaint = paint_model.PaintData(
      color: state.color,
      type: state.paintType,
      blendMode: state.blendMode,
      gradientStops: state.gradientStops,
      selectedStopIndex: state.selectedStopIndex,
      gradientAngle: state.gradientAngle,
      gradientOpacity: state.gradientOpacity,
    );
    widget.onPaintChanged?.call(newPaint);
  }

  /// Gets the effective recent swatches (provided or auto-loaded).
  List<PaintSwatch>? get _effectiveRecentSwatches {
    if (widget.recentSwatches != null) {
      return widget.recentSwatches;
    }
    // Return loaded swatches (may be empty list, which is fine)
    return _loadedRecentSwatches;
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

  /// Calculates estimated height based on what sections are shown.
  double _calculateEstimatedHeight() {
    double baseHeight = 378.0; // Base color picker height

    final bool hasRecentColors =
        widget.showRecentColors &&
        _effectiveRecentSwatches != null &&
        _effectiveRecentSwatches!.isNotEmpty;
    final bool hasPresets = widget.showPresets && _effectivePresets.isNotEmpty;

    // Add height for recent colors section (if shown)
    if (hasRecentColors) {
      // 8px spacing before + ~60px for recent colors view
      baseHeight += 68.0;
    }

    // Add height for presets section (if shown)
    if (hasPresets) {
      // 12px spacing before (if recent colors shown) or 0px + ~56px for presets + 8px padding below
      final spacingBefore = hasRecentColors ? 12.0 : 0.0;
      baseHeight +=
          spacingBefore + 56.0 + 8.0; // spacing + presets + padding below
    }

    // Add compensation for base height reduction (only once, when any section is shown)
    if (hasRecentColors || hasPresets) {
      baseHeight +=
          22.0; // Compensation for base height reduction from 400 to 378
    }

    // Add height for preset library (if shown)
    if (widget.showPresetLibrary && widget.presetLibrary != null) {
      baseHeight += 20.0; // Additional spacing
    }

    // Remove extra bottom padding when only recent colors are shown (no presets)
    if (hasRecentColors &&
        !hasPresets &&
        !(widget.showPresetLibrary && widget.presetLibrary != null)) {
      baseHeight -= 12.0; // Remove extra bottom padding (was 20px, now 12px)
    }

    return baseHeight.clamp(widget.minHeight, widget.maxHeight);
  }

  @override
  void didUpdateWidget(ColorPickerTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mark overlay for rebuild if it exists and relevant properties changed
    if (_overlayEntry != null) {
      // Check if any properties that affect the overlay content have changed
      if (widget.recentSwatches != oldWidget.recentSwatches ||
          widget.presets != oldWidget.presets ||
          widget.presetLibrary != oldWidget.presetLibrary ||
          widget.paint != oldWidget.paint ||
          widget.color != oldWidget.color) {
        // Schedule the rebuild for after the current build phase to avoid
        // "setState() or markNeedsBuild() called during build" errors
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _overlayEntry?.markNeedsBuild();
        });
      }
    }
  }

  /// Builds the popup content with ColorPickerPanel and resize handle.
  Widget _buildPopupContent(BuildContext overlayContext) {
    // Use current state or fall back to widget props
    final currentState = _currentPopupState ?? _createPaintState();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ColorPickerPanel(
            color: _effectivePaint.color,
            onColorChanged: (Color color) {
              // Get the latest state for checking gradient mode
              final latestState = _currentPopupState ?? _createPaintState();
              // Only track and forward color changes if we're in solid mode
              // In gradient mode, color changes are handled via gradient stops
              if (!latestState.isGradientMode) {
                setState(() {
                  _currentPopupState = latestState.copyWith(color: color);
                });
                _notifyPaintChanged(latestState.copyWith(color: color));
              }
            },
            onColorChangeStart: widget.onPaintChangeStart,
            onColorChangeEnd: () {
              widget.onPaintChangeEnd?.call();
            },
            allowOpacity: widget.allowOpacity,
            readOnly: widget.readOnly,
            maxWidth: widget.popupWidth,
            showRecentColors: widget.showRecentColors,
            recentSwatches: _effectiveRecentSwatches,
            onRecentSwatchAdd:
                widget.onRecentSwatchAdd ??
                (swatch) {
                  _recentColorsManager?.addSwatch(swatch).then((_) {
                    if (mounted) {
                      setState(() {
                        _loadedRecentSwatches = _recentColorsManager?.swatches;
                      });
                      // Mark overlay for rebuild to update recent colors UI
                      _overlayEntry?.markNeedsBuild();
                    }
                  });
                },
            onRecentSwatchSelected: (PaintSwatch swatch) {
              // When a swatch is selected from recent colors, update all
              // relevant state
              final newState = PaintState(
                color: swatch.color,
                paintType: swatch.paintType,
                blendMode:
                    _currentPopupState?.blendMode ?? _effectivePaint.blendMode,
                gradientStops: swatch.gradientStops,
                selectedStopIndex: 0,
                gradientAngle: swatch.gradientAngle,
                gradientOpacity: swatch.gradientOpacity,
              );
              setState(() {
                _currentPopupState = newState;
              });
              _notifyPaintChanged(newState);
              widget.onRecentSwatchSelected?.call(swatch);
            },
            showPresets: widget.showPresets,
            presets: widget.presets,
            onCreatePreset: widget.onCreatePreset,
            showPresetLibrary: widget.showPresetLibrary,
            presetLibrary: widget.presetLibrary,
            onPresetLibrarySelected: widget.onPresetLibrarySelected,
            showBlendMode: widget.showBlendMode,
            blendMode: currentState.blendMode ?? _effectivePaint.blendMode,
            onBlendModeChanged: (BlendModeType blendMode) {
              final latestState = _currentPopupState ?? _createPaintState();
              final updatedState = latestState.copyWith(blendMode: blendMode);
              setState(() {
                _currentPopupState = updatedState;
              });
              _notifyPaintChanged(updatedState);
            },
            showPageSwitcher: widget.showPageSwitcher,
            showCloseButton: true,
            onClose: _hidePopup,
            paintType: currentState.paintType,
            onPaintTypeChanged: (PaintType paintType) {
              final latestState = _currentPopupState ?? _createPaintState();
              final updatedState = latestState.copyWith(paintType: paintType);
              setState(() {
                _currentPopupState = updatedState;
              });
              _notifyPaintChanged(updatedState);
            },
            gradientStops:
                currentState.gradientStops ??
                _getGradientStops(currentState.paintType),
            onGradientStopsChanged: (List<ColorStop> stops) {
              final latestState = _currentPopupState ?? _createPaintState();
              final updatedState = latestState.copyWith(gradientStops: stops);
              setState(() {
                _currentPopupState = updatedState;
              });
              _notifyPaintChanged(updatedState);
            },
            selectedStopIndex: currentState.selectedStopIndex,
            onStopSelected: (int index) {
              final latestState = _currentPopupState ?? _createPaintState();
              final updatedState = latestState.copyWith(
                selectedStopIndex: index,
              );
              setState(() {
                _currentPopupState = updatedState;
              });
              _notifyPaintChanged(updatedState);
            },
            gradientAngle:
                currentState.gradientAngle ?? _effectivePaint.gradientAngle,
            onGradientAngleChanged: (double angle) {
              final latestState = _currentPopupState ?? _createPaintState();
              final updatedState = latestState.copyWith(gradientAngle: angle);
              setState(() {
                _currentPopupState = updatedState;
              });
              _notifyPaintChanged(updatedState);
            },
            gradientOpacity: currentState.gradientOpacity,
            onGradientOpacityChanged: (double opacity) {
              final latestState = _currentPopupState ?? _createPaintState();
              final updatedState = latestState.copyWith(
                gradientOpacity: opacity,
              );
              setState(() {
                _currentPopupState = updatedState;
              });
              _notifyPaintChanged(updatedState);
            },
            onHeaderDragStart: (_) {
              // Drag started, position tracking initialized
            },
            onHeaderDragUpdate: (Offset delta) {
              if (_popupPosition != null && _popupHeight != null) {
                setState(() {
                  final MediaQueryData mediaQuery = MediaQuery.of(context);
                  final Size screenSize = mediaQuery.size;

                  _popupPosition = Offset(
                    (_popupPosition!.dx + delta.dx).clamp(
                      0.0,
                      screenSize.width - widget.popupWidth,
                    ),
                    (_popupPosition!.dy + delta.dy).clamp(
                      0.0,
                      screenSize.height - _popupHeight!,
                    ),
                  );
                });
                _overlayEntry?.markNeedsBuild();
              }
            },
            onHeaderDragEnd: () {
              // Drag ended, no additional action needed
            },
          ),
        ),
        // Resize handle at bottom
        PopupResizeHandle(
          onResize: (double deltaHeight) {
            if (_popupHeight != null && _popupPosition != null) {
              setState(() {
                final double newHeight = (_popupHeight! + deltaHeight).clamp(
                  widget.minHeight,
                  widget.maxHeight,
                );
                _popupHeight = newHeight;
                // Persist height immediately on resize
                PopupPositioningUtils.savePersistedHeight(
                  widget.heightPersistenceKey,
                  newHeight,
                );

                // Keep the current position but adjust if it would go off-screen
                final MediaQueryData mediaQuery = MediaQuery.of(context);
                final Size screenSize = mediaQuery.size;

                // Clamp position to ensure popup stays on screen with new height
                _popupPosition = Offset(
                  _clampSafe(
                    _popupPosition!.dx,
                    0.0,
                    screenSize.width - widget.popupWidth,
                  ),
                  _clampSafe(
                    _popupPosition!.dy,
                    0.0,
                    screenSize.height - _popupHeight!,
                  ),
                );
              });
              _overlayEntry?.markNeedsBuild();
            }
          },
        ),
      ],
    );
  }

  /// Safely clamps a value between min and max, handling cases where min > max.
  double _clampSafe(double value, double min, double max) {
    if (min > max) {
      // If min > max, just ensure value is within screen bounds
      return value.clamp(0.0, double.infinity);
    }
    return value.clamp(min, max);
  }

  /// Gets gradient stops for gradient modes, or returns null for non-gradient modes.
  /// If no stops are provided but paint type is gradient, creates default stops.
  List<ColorStop>? _getGradientStops(PaintType? paintType) {
    final isGradientMode =
        paintType == PaintType.gradientLinear ||
        paintType == PaintType.gradientRadial ||
        paintType == PaintType.gradientAngular;

    if (!isGradientMode) {
      return null;
    }

    // If stops are provided, use them
    if (_effectivePaint.gradientStops != null &&
        _effectivePaint.gradientStops!.isNotEmpty) {
      return _effectivePaint.gradientStops;
    }

    // Otherwise, create default stops from the current color
    // Use tracked popup state color if available, otherwise widget paint color
    final color = _currentPopupState?.color ?? _effectivePaint.color;
    return [
      ColorStop(position: 0.0, color: color),
      ColorStop(position: 1.0, color: color.withValues(alpha: 0.3)),
    ];
  }

  void _showPopup(BuildContext context) {
    if (_overlayEntry != null) {
      _hidePopup();
      return;
    }

    // Initialize current state and track initial state for comparison on close
    _currentPopupState = _createPaintState();
    _initialPopupState = _createPaintState();

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Calculate dynamic height based on what's shown, or use persisted/estimated
    final double calculatedHeight = _calculateEstimatedHeight();
    final double initialHeight =
        PopupPositioningUtils.loadPersistedHeight(
          widget.heightPersistenceKey,
        ) ??
        calculatedHeight;
    final double requestedHeight = initialHeight.clamp(
      widget.minHeight,
      widget.maxHeight,
    );

    // Calculate position using smart positioning (may adjust height if needed)
    final result = PopupPositioningUtils.calculatePopupPosition(
      context: context,
      triggerBox: renderBox,
      popupWidth: widget.popupWidth,
      popupHeight: requestedHeight,
      minHeight: widget.minHeight,
      maxHeight: widget.maxHeight,
    );
    _popupPosition = result.position;
    _popupHeight = result.adjustedHeight;

    _overlayEntry = OverlayEntry(
      maintainState: true,
      opaque: false,
      builder: (BuildContext overlayContext) {
        final MediaQueryData mediaQuery = MediaQuery.of(overlayContext);
        final Size screenSize = mediaQuery.size;

        return Stack(
          children: <Widget>[
            // Backdrop to close on tap (matching main app)
            Positioned.fill(
              child: Listener(
                onPointerDown: (_) => _hidePopup(),
                behavior: HitTestBehavior.translucent,
              ),
            ),
            // Popup positioned absolutely (for dragging support)
            if (_popupPosition != null && _popupHeight != null)
              Positioned(
                left: _clampSafe(
                  _popupPosition!.dx,
                  0.0,
                  screenSize.width - widget.popupWidth,
                ),
                top: _clampSafe(
                  _popupPosition!.dy,
                  0.0,
                  screenSize.height - _popupHeight!,
                ),
                child: FocusScope(
                  child: Actions(
                    actions: <Type, Action<Intent>>{
                      DismissIntent: CallbackAction<DismissIntent>(
                        onInvoke: (DismissIntent intent) => _hidePopup(),
                      ),
                    },
                    child: Focus(
                      autofocus: true,
                      child: Material(
                        type: MaterialType.transparency,
                        child: GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            key: _popupKey,
                            width: widget.popupWidth,
                            height: _popupHeight,
                            constraints: BoxConstraints(
                              minWidth: widget.popupWidth,
                              maxWidth: widget.popupWidth,
                              minHeight: widget.minHeight,
                              maxHeight: widget.maxHeight,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                overlayContext,
                              ).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(overlayContext).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF383838)
                                    : const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                              boxShadow:
                                  widget.popupBoxShadow ??
                                  defaultColorPickerPopupShadow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _buildPopupContent(overlayContext),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _hidePopup() {
    // Get final state from tracked popup state or use current widget state
    final finalState = _currentPopupState ?? _createPaintState();

    // Check if any state changed using simplified didChange method
    final didChange = finalState.didChange(_initialPopupState);

    // Apply final state changes on close if anything changed
    // Use addPostFrameCallback to ensure callbacks are invoked after the widget
    // tree is unlocked, preventing setState errors during dispose
    if (didChange) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Notify paint change with unified callback
        _notifyPaintChanged(finalState);

        // Save swatch to recents on close if any state changed
        final swatch = _getSwatchFromState(finalState);
        if (widget.onRecentSwatchAdd != null) {
          widget.onRecentSwatchAdd!.call(swatch);
        } else if (_recentColorsManager != null) {
          // Auto-save to recent colors if using auto-loaded manager
          _recentColorsManager!.addSwatch(swatch).then((_) {
            if (mounted) {
              setState(() {
                _loadedRecentSwatches = _recentColorsManager!.swatches;
              });
            }
          });
        }
      });
    }

    _overlayEntry?.remove();
    _overlayEntry = null;
    _currentPopupState = null;
    _initialPopupState = null;
    _popupPosition = null;
    _popupHeight = null;
  }

  /// Gets a paint swatch from a PaintState.
  PaintSwatch _getSwatchFromState(PaintState state) {
    if (state.isGradientMode &&
        state.gradientStops != null &&
        state.gradientStops!.isNotEmpty) {
      return PaintSwatch.fromGradient(
        paintType: state.paintType,
        gradientStops: state.gradientStops!,
        gradientAngle: state.gradientAngle,
        gradientOpacity: state.gradientOpacity,
      );
    }
    return PaintSwatch.fromColor(state.color);
  }

  @override
  void dispose() {
    _recentColorsManager?.removeListener(_onRecentColorsChanged);
    _hidePopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: widget.readOnly ? null : () => _showPopup(context),
        child: MouseRegion(
          cursor: widget.readOnly
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: widget.child ?? _buildColorSwatch(context),
        ),
      ),
    );
  }

  Widget _buildColorSwatch(BuildContext context) {
    // Create PaintSwatch from effective Paint object
    final paint = _effectivePaint;
    final PaintSwatch swatch;
    if (paint.type != PaintType.solid &&
        paint.type != PaintType.image &&
        paint.gradientStops != null &&
        paint.gradientStops!.isNotEmpty) {
      swatch = PaintSwatch.gradient(
        paintType: paint.type,
        color: paint.color,
        gradientStops: paint.gradientStops!,
        gradientAngle: paint.gradientAngle,
        gradientOpacity: paint.gradientOpacity,
      );
    } else {
      swatch = PaintSwatch.fromColor(paint.color);
    }

    // Use ColorTile for both solid and gradient (consolidated swatch component)
    // Enable checkerboard for standalone usage
    return ColorTile.fromSwatch(
      paintSwatch: swatch,
      size: widget.size ?? 24,
      borderRadius: widget.borderRadius,
      borderWidth: widget.borderWidth > 0 ? widget.borderWidth : null,
      showCheckerboard: true,
    );
  }
}
