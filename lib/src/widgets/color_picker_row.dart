import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_picker_trigger.dart';
import 'color_inputs.dart';
import 'gradient_alpha_input.dart';
import '../models/paint_data.dart';

/// A horizontal color picker row with swatch and inline text inputs.
///
/// This widget provides a compact inline UI for color editing, similar to
/// design tools like common design and graphics tools. It includes:
/// - Clickable color swatch (opens popup picker)
/// - Hex color input field
/// - RGB numeric inputs (0-255)
/// - Optional alpha/opacity input
///
/// ## Usage:
///
/// **Simple solid color:**
/// ```dart
/// ColorPickerRow(
///   color: Colors.blue,
///   onColorChanged: (color) {
///     setState(() => myColor = color);
///   },
/// )
/// ```
///
/// **With alpha channel:**
/// ```dart
/// ColorPickerRow(
///   color: myColor,
///   onColorChanged: (color) => setState(() => myColor = color),
///   showAlpha: true,
/// )
/// ```
///
/// **Compact mode (hex only):**
/// ```dart
/// ColorPickerRow(
///   color: myColor,
///   onColorChanged: (color) => setState(() => myColor = color),
///   showRGB: false,
/// )
/// ```
class ColorPickerRow extends StatefulWidget {
  /// Current color value.
  final Color color;

  /// Called when color changes from any input (swatch, hex, RGB, alpha).
  final ValueChanged<Color>? onColorChanged;

  /// Called when user starts interacting.
  final VoidCallback? onColorChangeStart;

  /// Called when user finishes interacting.
  final VoidCallback? onColorChangeEnd;

  /// Show RGB numeric inputs.
  final bool showRGB;

  /// Show alpha/opacity input (0-255).
  final bool showAlpha;

  /// Show opacity percentage display (0-100%).
  final bool showOpacity;

  /// Show labels above inputs (HEX, R, G, B, A, Opacity).
  final bool showLabels;

  /// Show outline border on inputs (always visible, not just on focus).
  final bool showOutline;

  /// Size of the color swatch. Defaults to 24 if not provided.
  final double? swatchSize;

  /// Border radius of the color swatch.
  final double swatchBorderRadius;

  /// Spacing between elements.
  final double spacing;

  /// Read-only mode (disables all inputs).
  final bool readOnly;

  /// Enable/disable opacity controls in popup picker.
  final bool allowOpacity;

  /// Show recent colors in popup picker.
  final bool showRecentColors;

  /// Show color presets in popup picker.
  final bool showPresets;

  /// Show preset library in popup picker.
  final bool showPresetLibrary;

  /// Custom text style for input labels.
  final TextStyle? labelStyle;

  /// Custom text style for input values.
  final TextStyle? inputStyle;

  /// Popup width for the color picker.
  final double popupWidth;

  /// Minimum height for popup.
  final double popupMinHeight;

  /// Maximum height for popup.
  final double popupMaxHeight;

  const ColorPickerRow({
    super.key,
    required this.color,
    this.onColorChanged,
    this.onColorChangeStart,
    this.onColorChangeEnd,
    this.showRGB = false,
    this.showAlpha = false,
    this.showOpacity = false,
    this.showLabels = false,
    this.showOutline = false,
    this.swatchSize,
    this.swatchBorderRadius = 4,
    this.spacing = 8,
    this.readOnly = false,
    this.allowOpacity = true,
    this.showRecentColors = true,
    this.showPresets = true,
    this.showPresetLibrary = true,
    this.labelStyle,
    this.inputStyle,
    this.popupWidth = 300,
    this.popupMinHeight = 200,
    this.popupMaxHeight = 650,
  });

  @override
  State<ColorPickerRow> createState() => _ColorPickerRowState();
}

class _ColorPickerRowState extends State<ColorPickerRow> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.color;
  }

  @override
  void didUpdateWidget(ColorPickerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.color != oldWidget.color) {
      _currentColor = widget.color;
    }
  }

  void _handleColorChanged(Color color) {
    if (color != _currentColor) {
      setState(() => _currentColor = color);
      widget.onColorChanged?.call(color);
    }
  }

  void _handlePaintChanged(PaintData paint) {
    _handleColorChanged(paint.color);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color swatch trigger
        ColorPickerTrigger(
          color: _currentColor,
          onPaintChanged: _handlePaintChanged,
          onPaintChangeStart: widget.onColorChangeStart,
          onPaintChangeEnd: widget.onColorChangeEnd,
          size: widget.swatchSize ?? 24,
          borderRadius: widget.swatchBorderRadius,
          borderWidth: 1,
          readOnly: widget.readOnly,
          allowOpacity: widget.allowOpacity,
          showRecentColors: widget.showRecentColors,
          showPresets: widget.showPresets,
          showPresetLibrary: widget.showPresetLibrary,
          popupWidth: widget.popupWidth,
          minHeight: widget.popupMinHeight,
          maxHeight: widget.popupMaxHeight,
        ),
        SizedBox(width: widget.spacing / 2),

        // Hex input
        ColorHexInput(
          color: _currentColor,
          onColorChanged: _handleColorChanged,
          readOnly: widget.readOnly,
          textStyle: widget.inputStyle,
          showLabel: widget.showLabels,
          showOutline: widget.showOutline,
        ),

        if (widget.showRGB) ...[
          SizedBox(width: widget.spacing),

          // R input
          _ColorChannelInput(
            label: widget.showLabels ? 'R' : '',
            value: (_currentColor.r * 255).round().toString(),
            width: 50,
            showOutline: widget.showOutline,
            labelStyle: widget.labelStyle,
            inputStyle: widget.inputStyle,
            readOnly: widget.readOnly,
            onChanged: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null && intValue >= 0 && intValue <= 255) {
                _handleColorChanged(
                  _currentColor.withValues(red: intValue / 255.0),
                );
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _RangeInputFormatter(min: 0, max: 255),
            ],
            keyboardType: TextInputType.number,
          ),
          SizedBox(width: widget.spacing),

          // G input
          _ColorChannelInput(
            label: widget.showLabels ? 'G' : '',
            value: (_currentColor.g * 255).round().toString(),
            width: 50,
            showOutline: widget.showOutline,
            labelStyle: widget.labelStyle,
            inputStyle: widget.inputStyle,
            readOnly: widget.readOnly,
            onChanged: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null && intValue >= 0 && intValue <= 255) {
                _handleColorChanged(
                  _currentColor.withValues(green: intValue / 255.0),
                );
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _RangeInputFormatter(min: 0, max: 255),
            ],
            keyboardType: TextInputType.number,
          ),
          SizedBox(width: widget.spacing),

          // B input
          _ColorChannelInput(
            label: widget.showLabels ? 'B' : '',
            value: (_currentColor.b * 255).round().toString(),
            width: 50,
            showOutline: widget.showOutline,
            labelStyle: widget.labelStyle,
            inputStyle: widget.inputStyle,
            readOnly: widget.readOnly,
            onChanged: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null && intValue >= 0 && intValue <= 255) {
                _handleColorChanged(
                  _currentColor.withValues(blue: intValue / 255.0),
                );
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _RangeInputFormatter(min: 0, max: 255),
            ],
            keyboardType: TextInputType.number,
          ),
        ],

        if (widget.showAlpha) ...[
          SizedBox(width: widget.spacing),

          // A (Alpha) input
          _ColorChannelInput(
            label: widget.showLabels ? 'A' : '',
            value: (_currentColor.a * 255).round().toString(),
            width: 50,
            showOutline: widget.showOutline,
            labelStyle: widget.labelStyle,
            inputStyle: widget.inputStyle,
            readOnly: widget.readOnly,
            onChanged: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null && intValue >= 0 && intValue <= 255) {
                _handleColorChanged(
                  _currentColor.withValues(alpha: intValue / 255.0),
                );
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _RangeInputFormatter(min: 0, max: 255),
            ],
            keyboardType: TextInputType.number,
          ),
        ],

        if (widget.showOpacity) ...[
          SizedBox(width: widget.spacing),

          // Opacity percentage display (0-100%)
          SizedBox(
            width: 80,
            child: GradientAlphaInput(
              color: _currentColor,
              onValueUpdate: _handleColorChanged,
              onDragUpdate: _handleColorChanged,
              onDragEnd: () {},
              readOnly: widget.readOnly,
              label: 'Opacity',
              labelAlignment: TextAlign.left,
              showLabel: widget.showLabels,
              showOutline: widget.showOutline,
            ),
          ),
        ],
      ],
    );
  }
}

/// Individual color channel input field with inline-edit behavior.
/// Shows as text, becomes editable when clicked.
/// Supports horizontal drag to adjust value (0-255 range).
class _ColorChannelInput extends StatefulWidget {
  final String label;
  final String value;
  final double width;
  final bool showOutline;
  final TextStyle? labelStyle;
  final TextStyle? inputStyle;
  final bool readOnly;
  final ValueChanged<String> onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;

  const _ColorChannelInput({
    required this.label,
    required this.value,
    required this.width,
    required this.onChanged,
    this.showOutline = false,
    this.labelStyle,
    this.inputStyle,
    this.readOnly = false,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_ColorChannelInput> createState() => _ColorChannelInputState();
}

class _ColorChannelInputState extends State<_ColorChannelInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _lastCommittedValue = '';
  bool _isEditing = false;
  bool _isDragging = false;
  int _dragStartValue = 0;
  Offset? _dragStartPosition;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _lastCommittedValue = widget.value;
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(_ColorChannelInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if not editing, not dragging, and value changed externally
    if (!_isEditing && !_isDragging && widget.value != oldWidget.value) {
      _controller.text = widget.value;
      _lastCommittedValue = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // Select all text on focus
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    } else {
      // Commit value on blur and exit edit mode
      final text = _controller.text.trim();
      if (text.isNotEmpty && text != _lastCommittedValue) {
        _lastCommittedValue = text;
        widget.onChanged(text);
      } else if (text.isEmpty) {
        // Restore last valid value if empty
        _controller.text = _lastCommittedValue;
      }
      setState(() => _isEditing = false);
    }
  }

  void _enterEditMode() {
    if (widget.readOnly) return;
    setState(() => _isEditing = true);
    // Delay focus to ensure widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // Border and background colors
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.1);
    final focusBorderColor = colorScheme.primary;
    final hoverBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.15);
    final backgroundColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.5);

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 0,
        children: [
          // Label (only show if not empty)
          if (widget.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 4),
              child: Text(
                widget.label,
                style: (widget.labelStyle ?? theme.textTheme.bodySmall)
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      height: 1.0,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.7),
                    ),
              ),
            ),

          // Value display (inline-edit pattern with drag support)
          MouseRegion(
            cursor: _isDragging
                ? SystemMouseCursors.resizeLeftRight
                : (widget.readOnly
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click),
            child: GestureDetector(
              onTap: _isEditing || _isDragging ? null : _enterEditMode,
              onHorizontalDragStart: widget.readOnly || _isEditing
                  ? null
                  : (DragStartDetails details) {
                      final currentValue = int.tryParse(widget.value) ?? 0;
                      setState(() {
                        _isDragging = true;
                        _dragStartValue = currentValue;
                        _dragStartPosition = details.globalPosition;
                      });
                    },
              onHorizontalDragUpdate: widget.readOnly || _isEditing
                  ? null
                  : (DragUpdateDetails details) {
                      if (_dragStartPosition == null) return;
                      final dx =
                          details.globalPosition.dx - _dragStartPosition!.dx;
                      // Scale factor for drag sensitivity (2.55 = 255 range / 100 pixels)
                      final delta = dx * 2.55;
                      final newValue = (_dragStartValue + delta.round()).clamp(
                        0,
                        255,
                      );
                      _controller.text = newValue.toString();
                      widget.onChanged(newValue.toString());
                    },
              onHorizontalDragEnd: widget.readOnly || _isEditing
                  ? null
                  : (DragEndDetails details) {
                      setState(() {
                        _isDragging = false;
                        _dragStartPosition = null;
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: widget.showOutline || _isEditing || _isDragging
                      ? backgroundColor
                      : null,
                  border: Border.all(
                    color: _isEditing
                        ? focusBorderColor
                        : (_isDragging
                              ? hoverBorderColor
                              : (widget.showOutline
                                    ? borderColor
                                    : Colors.transparent)),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: widget.showOutline || _isEditing || _isDragging
                      ? [
                          // Outer shadow for depth
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                          // Inner highlight for skeumorphic effect
                          if (!_isEditing && !_isDragging)
                            BoxShadow(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.white.withValues(alpha: 0.5),
                              blurRadius: 1,
                              offset: const Offset(0, -1),
                            ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: IgnorePointer(
                    ignoring: _isDragging,
                    child: _isEditing
                        ? TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            textAlign: TextAlign.left,
                            readOnly: widget.readOnly,
                            keyboardType: widget.keyboardType,
                            inputFormatters: widget.inputFormatters,
                            style:
                                (widget.inputStyle ??
                                        theme.textTheme.bodyMedium)
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                            cursorColor: theme.colorScheme.primary,
                            cursorWidth: 1.5,
                            cursorRadius: const Radius.circular(1),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) {
                              _lastCommittedValue = value.trim();
                              widget.onChanged(_lastCommittedValue);
                              _focusNode.unfocus();
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.value,
                              textAlign: TextAlign.left,
                              style:
                                  (widget.inputStyle ??
                                          theme.textTheme.bodyMedium)
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Input formatter that restricts numeric input to a range.
class _RangeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _RangeInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final intValue = int.tryParse(newValue.text);
    if (intValue == null) {
      return oldValue;
    }

    // Allow typing in progress (e.g., "2" before "25")
    if (intValue > max) {
      // If value exceeds max, check if we're still typing
      final String text = newValue.text;
      // If the user is typing and value is over max, only allow if it could
      // become valid (e.g., typing "2" for "25" when max is 255)
      if (text.length == 1 && intValue <= (max ~/ 10)) {
        return newValue;
      }
      return oldValue;
    }

    return newValue;
  }
}
