import 'package:flutter/material.dart';

import 'alpha_slider.dart';
import 'color_inputs.dart';
import 'gradient_alpha_input.dart';
import 'palette.dart';
import 'parent_switcher.dart';
import 'rainbow_slider.dart';
import 'recent_colors_view.dart';
import '../models/paint_swatch.dart';

// Default horizontal padding for color picker components
const double _kDefaultHorizontalPadding = 12.0;

/// Paint type enum for color picker mode selection.
enum PaintType {
  solid,
  gradientLinear,
  gradientRadial,
  gradientAngular,
  image;

  String get prettify {
    switch (this) {
      case PaintType.solid:
        return 'Solid';
      case PaintType.gradientLinear:
        return 'Linear';
      case PaintType.gradientRadial:
        return 'Radial';
      case PaintType.gradientAngular:
        return 'Angular';
      case PaintType.image:
        return 'Image';
    }
  }
}

/// Main color picker widget with all components.
///
/// This widget provides a complete color picking solution with:
/// - Title bar with dropdown for paint type selection
/// - 2D color palette for saturation/brightness
/// - Rainbow/hue slider
/// - Alpha/opacity slider
/// - Hex color input
/// - Alpha input
/// - Optional recent colors and presets
/// - Optional preset library (style sheets)
class ColorPicker extends StatefulWidget {
  /// Initial color value.
  final Color color;

  /// Called when color changes (during drag).
  final ValueChanged<Color> onColorChanged;

  /// Called when user starts interacting.
  final VoidCallback? onColorChangeStart;

  /// Called when user finishes interacting.
  final VoidCallback? onColorChangeEnd;

  /// Called when palette position changes (optional).
  final ValueChanged<Offset>? onPalettePositionChanged;

  /// Enable/disable opacity controls.
  final bool allowOpacity;

  /// Padding around hex/alpha inputs.
  final EdgeInsets? inputsPadding;

  /// Padding around sliders.
  final EdgeInsets? slidersPadding;

  /// Fixed height for palette (null = expand to fill).
  final double? paletteHeight;

  /// Read-only mode.
  final bool readOnly;

  /// Throttle duration for onColorChanged (optional performance optimization).
  final Duration? throttleDuration;

  /// Show recent colors section below picker.
  final bool showRecentColors;

  /// Custom recent paint swatches (colors or gradients).
  final List<PaintSwatch>? recentSwatches;

  /// Called when user adds the current paint swatch to recent list.
  /// The callback receives the current swatch (solid color).
  final ValueChanged<PaintSwatch>? onRecentSwatchAdd;

  /// Show color presets section below picker.
  final bool showPresets;

  /// Custom preset colors (if null, uses empty list).
  final List<ColorPreset>? presets;

  /// Called when user wants to create new preset.
  final VoidCallback? onCreatePreset;

  /// Show preset library (style sheets) section.
  final bool showPresetLibrary;

  /// List of preset library entries (style sheets).
  final List<PresetLibraryEntry>? presetLibrary;

  /// Called when a preset library entry is selected.
  final ValueChanged<Color>? onPresetLibrarySelected;

  /// Currently selected paint type.
  final PaintType? paintType;

  /// Called when paint type changes.
  final ValueChanged<PaintType>? onPaintTypeChanged;

  /// Supported paint types (default: Solid, Linear, Radial, Angular, Image).
  final List<PaintType> supportedTypes;

  /// Title bar padding.
  final EdgeInsets titleBarPadding;

  /// Whether to show divider after title bar.
  final bool showDivider;

  /// Whether to show title bar with dropdown (hidden when used in ColorPickerPanel).
  final bool showTitleBar;

  /// Whether to show toolbar (hex/opacity inputs) inside ColorPicker (hidden when used in ColorPickerPanel).
  final bool showToolbar;

  /// Maximum width constraint.
  final double? maxWidth;

  const ColorPicker({
    super.key,
    this.color = Colors.white,
    required this.onColorChanged,
    this.onColorChangeStart,
    this.onColorChangeEnd,
    this.onPalettePositionChanged,
    this.allowOpacity = true,
    this.inputsPadding,
    this.slidersPadding,
    this.paletteHeight,
    this.readOnly = false,
    this.throttleDuration,
    this.showRecentColors = true,
    this.recentSwatches,
    this.onRecentSwatchAdd,
    this.showPresets = true,
    this.presets,
    this.onCreatePreset,
    this.showPresetLibrary = false,
    this.presetLibrary,
    this.onPresetLibrarySelected,
    this.paintType,
    this.onPaintTypeChanged,
    this.supportedTypes = const [
      PaintType.solid,
      PaintType.gradientLinear,
      PaintType.gradientRadial,
      PaintType.gradientAngular,
      PaintType.image,
    ],
    this.titleBarPadding = const EdgeInsets.fromLTRB(4, 8, 8, 6),
    this.showDivider = true,
    this.showTitleBar = true,
    this.showToolbar = true,
    this.maxWidth = 300,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  /// Active color picker color.
  late Color color;

  /// Independent opacity value.
  late double opacity;

  /// Base color value.
  late Color rainbowColor;

  /// Base color position on rainbow slider.
  late double rainbowPosition;

  /// Independent palette position.
  late Offset palettePosition;

  /// Hover flag to enable dragging value selection.
  bool inputHover = false;
  bool hasFocus = false;
  bool inputHasFocus = false;

  final FocusNode alphaFocusNode = FocusNode();
  // Drag-tick notifier. Incrementing this rebuilds only the subtrees wrapped
  // in a ListenableBuilder — not the entire picker column. Used as a
  // repaint/rebuild signal during drags so we can avoid parent setState.
  final ValueNotifier<int> _dragTick = ValueNotifier<int>(0);

  late PaintType _selectedPaintType;

  @override
  void initState() {
    super.initState();
    color = widget.color;
    opacity = widget.allowOpacity ? color.a : 1;
    palettePosition = Palette.getPosition(color);
    rainbowPosition = RainbowSlider.getPosition(color);
    rainbowColor = RainbowSlider.getColor(rainbowPosition);
    _selectedPaintType = widget.paintType ?? widget.supportedTypes.first;
  }

  @override
  void didUpdateWidget(covariant ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (color != widget.color) {
      setState(() {
        color = widget.color;
        opacity = widget.allowOpacity ? widget.color.a : 1;
        palettePosition = Palette.getPosition(color);
        rainbowPosition = RainbowSlider.getPosition(color);
        rainbowColor = RainbowSlider.getColor(rainbowPosition);
      });
    }
    if (widget.paintType != null && widget.paintType != _selectedPaintType) {
      setState(() {
        _selectedPaintType = widget.paintType!;
      });
    }
  }

  @override
  void dispose() {
    alphaFocusNode.dispose();
    _dragTick.dispose();
    super.dispose();
  }

  // Ping dependents without a full parent rebuild.
  void _tick() => _dragTick.value = _dragTick.value + 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final columnContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Title bar with dropdown (only shown if showTitleBar is true)
        if (widget.showTitleBar) ...[
          Padding(
            padding: widget.titleBarPadding,
            child: Row(
              children: <Widget>[
                if (widget.readOnly)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    child: Text(
                      _selectedPaintType.prettify,
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                else
                  _PaintTypeDropdown(
                    value: _selectedPaintType,
                    items: widget.supportedTypes,
                    onChanged: (PaintType? value) {
                      if (value != null && value != _selectedPaintType) {
                        setState(() {
                          _selectedPaintType = value;
                        });
                        widget.onPaintTypeChanged?.call(value);
                      }
                    },
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
              ],
            ),
          ),
          if (widget.showDivider)
            Container(
              height: 1,
              color: colorScheme.onSurface.withValues(alpha: 0.08),
            ),
        ],
        // Color picker content (show for solid and gradient paint types)
        // Gradients use the color picker to select colors for gradient stops
        if (_selectedPaintType == PaintType.solid ||
            _selectedPaintType == PaintType.gradientLinear ||
            _selectedPaintType == PaintType.gradientRadial ||
            _selectedPaintType == PaintType.gradientAngular) ...[
          // Toolbar (hex/opacity inputs) - shown when showToolbar is true
          if (widget.showToolbar)
            Padding(
              padding: widget.inputsPadding ??
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListenableBuilder(
                listenable: _dragTick,
                builder: (BuildContext context, Widget? _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Show hex input only for solid mode
                      if (_selectedPaintType == PaintType.solid) ...[
                        Expanded(
                          child: ColorHexInput(
                            color: color,
                            readOnly: widget.readOnly,
                            allowAlpha: false,
                            onColorChanged: (Color value) {
                              setState(() {
                                color = value.withValues(alpha: opacity);
                                rainbowPosition =
                                    RainbowSlider.getPosition(color);
                                rainbowColor =
                                    RainbowSlider.getColor(rainbowPosition);
                                palettePosition = Palette.getPosition(color);
                              });
                              widget.onColorChanged(color);
                              widget.onColorChangeEnd?.call();
                            },
                            onFocusChanged: (bool value) {
                              inputHasFocus = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      // Show opacity input for all modes
                      // In gradient mode, expand to fill available width
                      if (_selectedPaintType != PaintType.solid)
                        Expanded(
                          child: GradientAlphaInput(
                            focus: alphaFocusNode,
                            color: color,
                            readOnly: widget.readOnly || !widget.allowOpacity,
                            label: 'Global Opacity',
                            onValueUpdate: (Color value) =>
                                _commitColor(value, fireEnd: true),
                            onDragUpdate: (Color value) => _liveColor(value),
                            onDragEnd: widget.onColorChangeEnd,
                          ),
                        )
                      else
                        GradientAlphaInput(
                          focus: alphaFocusNode,
                          color: color,
                          readOnly: widget.readOnly || !widget.allowOpacity,
                          label: 'Opacity',
                          onValueUpdate: (Color value) =>
                              _commitColor(value, fireEnd: true),
                          onDragUpdate: (Color value) => _liveColor(value),
                          onDragEnd: widget.onColorChangeEnd,
                        ),
                    ],
                  );
                },
              ),
            ),
          ParentSwitcher(
            wrap: widget.paletteHeight == null,
            builder: (BuildContext context, Widget child) =>
                Flexible(fit: FlexFit.loose, child: child),
            child: ClipRect(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 20,
                  maxHeight: widget.paletteHeight ?? 200,
                ),
                child: SizedBox(
                  height: widget.paletteHeight,
                  child: TextFieldTapRegion(
                    enabled: !widget.readOnly,
                    child: ListenableBuilder(
                      listenable: _dragTick,
                      builder: (BuildContext context, Widget? _) {
                        return Palette(
                          readOnly: widget.readOnly,
                          baseColor: rainbowColor,
                          position: palettePosition,
                          thumbSize: 15,
                          onPanStart: widget.onColorChangeStart ?? () {},
                          onPositionChanged:
                              (Offset position, Color paletteColor) {
                            // Add opacity to changed color.
                            color = paletteColor.withValues(alpha: opacity);
                            // Save the color palette position.
                            palettePosition = position;
                            _tick();
                            widget.onColorChanged(color);
                            widget.onPalettePositionChanged?.call(position);
                          },
                          onPanEnd: (Color previousColor, Color updatedColor) {
                            widget.onColorChangeEnd?.call();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: widget.slidersPadding?.top ?? 12),
          Padding(
            padding: EdgeInsets.only(
              left: widget.slidersPadding?.left ?? _kDefaultHorizontalPadding,
              right: widget.slidersPadding?.right ?? _kDefaultHorizontalPadding,
            ),
            child: SizedBox(
              height: 15,
              child: ListenableBuilder(
                listenable: _dragTick,
                builder: (BuildContext context, Widget? _) {
                  return RainbowSlider(
                    readOnly: widget.readOnly,
                    position: rainbowPosition,
                    trackHeight: 15,
                    onPanStart: (Color previousColor, Color updatedColor) {
                      widget.onColorChangeStart?.call();
                    },
                    onPositionChanged: (double position, Color rainbow) {
                      // Update separate rainbow color and position.
                      rainbowColor = rainbow;
                      rainbowPosition = position;
                      // Calculate updated color from rainbow base, palette, and opacity.
                      color = Palette.getColor(rainbow, palettePosition)
                          .withValues(alpha: opacity);
                      _tick();
                      widget.onColorChanged(color);
                    },
                    onPanEnd: (Color previousColor, Color updatedColor) {
                      widget.onColorChangeEnd?.call();
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: widget.slidersPadding?.bottom ?? 12),
          Padding(
            padding: EdgeInsets.only(
              left: widget.slidersPadding?.left ?? _kDefaultHorizontalPadding,
              right: widget.slidersPadding?.right ?? _kDefaultHorizontalPadding,
            ),
            child: MouseRegion(
              cursor: widget.allowOpacity
                  ? MouseCursor.defer
                  : SystemMouseCursors.forbidden,
              child: SizedBox(
                height: 15,
                child: ListenableBuilder(
                  listenable: _dragTick,
                  builder: (BuildContext context, Widget? _) {
                    return AlphaSlider(
                      readOnly: widget.readOnly || !widget.allowOpacity,
                      color: color,
                      alpha: opacity,
                      trackHeight: 15,
                      onValueUpdate: (double value) {
                        // Update separate opacity value.
                        opacity = value;
                        // Update color with opacity.
                        color = color.withValues(alpha: value);
                        _tick();
                        widget.onColorChanged(color);
                      },
                      onDragEnd: (double previous, double updated) {
                        widget.onColorChangeEnd?.call();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          if (widget.showRecentColors && widget.recentSwatches != null) ...[
            const SizedBox(height: 8),
            RecentColorsView(
              swatches: widget.recentSwatches!,
              currentSwatch: PaintSwatch.fromColor(color),
              onAddCurrent: widget.onRecentSwatchAdd,
              onSelected: (PaintSwatch swatch) => _pickSwatch(swatch),
              readOnly: widget.readOnly,
            ),
          ],
          if (widget.showPresets) ...[
            const SizedBox(height: 12),
            ColorPresetsView(
              presets: widget.presets ?? [],
              currentSwatch: PaintSwatch.fromColor(color),
              onSelected: (PaintSwatch swatch) => _pickSwatch(swatch),
              onCreateNew: widget.onCreatePreset,
              readOnly: widget.readOnly,
            ),
          ],
          if (widget.showPresetLibrary && widget.presetLibrary != null) ...[
            const SizedBox(height: 12),
            PresetLibraryView(
              entries: widget.presetLibrary!,
              currentSwatch: PaintSwatch.fromColor(color),
              onSelected: (PaintSwatch swatch) {
                _pickSwatch(swatch);
                widget.onPresetLibrarySelected?.call(swatch.color);
              },
              readOnly: widget.readOnly,
            ),
          ],
        ],
      ],
    );

    // Apply max width constraint
    Widget result = columnContent;
    if (widget.maxWidth != null) {
      result = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth!),
        child: result,
      );
    }

    return result;
  }

  // Live color update during drag — updates state fields and pings drag-tick
  // listeners without triggering a full parent setState.
  void _liveColor(Color value) {
    // Changing the alpha changes the color.
    color = value;
    // Update the separate opacity value.
    opacity = color.a;
    rainbowPosition = RainbowSlider.getPosition(color);
    rainbowColor = RainbowSlider.getColor(rainbowPosition);
    palettePosition = Palette.getPosition(color);
    _tick();
    widget.onColorChanged(color);
  }

  // Committed color update (text input / drag end) — triggers a full setState
  // so all dependents (recent colors, presets, etc.) also update.
  void _commitColor(Color value, {bool fireEnd = false}) {
    setState(() {
      // Changing the alpha changes the color.
      color = value;
      // Update the separate opacity value.
      opacity = color.a;
      rainbowPosition = RainbowSlider.getPosition(color);
      rainbowColor = RainbowSlider.getColor(rainbowPosition);
      palettePosition = Palette.getPosition(color);
    });
    widget.onColorChanged(color);
    if (fireEnd) widget.onColorChangeEnd?.call();
  }

  void _pickSwatch(PaintSwatch swatch) {
    final selectedColor = swatch.color;
    setState(() {
      color = selectedColor;
      opacity = selectedColor.a;
      palettePosition = Palette.getPosition(selectedColor);
      rainbowPosition = RainbowSlider.getPosition(selectedColor);
      rainbowColor = RainbowSlider.getColor(rainbowPosition);
    });
    widget.onColorChanged(selectedColor);
    widget.onColorChangeEnd?.call();
  }
}

/// Custom dropdown widget using MenuAnchor to fix z-index issues in popups.
class _PaintTypeDropdown extends StatelessWidget {
  final PaintType value;
  final List<PaintType> items;
  final ValueChanged<PaintType?> onChanged;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _PaintTypeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: items.map((PaintType type) {
        return MenuItemButton(
          onPressed: () => onChanged(type),
          child: Text(
            type.prettify,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
        );
      }).toList(),
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
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
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    value.prettify,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
