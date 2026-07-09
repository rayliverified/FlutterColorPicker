import 'package:flutter/material.dart';

/// Alpha/opacity input widget with drag support.
/// 
/// This widget provides a numeric input field (0-100%) with horizontal drag support
/// for adjusting opacity values. It's used for both regular color opacity and global
/// gradient opacity.
class GradientAlphaInput extends StatefulWidget {
  /// Current color value (opacity is read from color.a).
  final Color color;
  
  /// Called when value updates (on commit).
  final ValueChanged<Color>? onValueUpdate;
  
  /// Called during drag.
  final ValueChanged<Color>? onDragUpdate;
  
  /// Called when drag ends.
  final VoidCallback? onDragEnd;
  
  /// Whether the input is read-only.
  final bool readOnly;
  
  /// Label text displayed above the input.
  final String label;
  
  /// Label text alignment.
  final TextAlign labelAlignment;
  
  /// Optional focus node for controlling focus.
  final FocusNode? focus;

  /// Show label above input.
  final bool showLabel;

  /// Show outline border (always visible, not just on focus).
  final bool showOutline;

  const GradientAlphaInput({
    super.key,
    required this.color,
    this.onValueUpdate,
    this.onDragUpdate,
    this.onDragEnd,
    this.readOnly = false,
    this.label = 'Opacity',
    this.labelAlignment = TextAlign.left,
    this.focus,
    this.showLabel = true,
    this.showOutline = true,
  });

  @override
  State<GradientAlphaInput> createState() => _GradientAlphaInputState();
}

class _GradientAlphaInputState extends State<GradientAlphaInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isDragging = false;
  double _dragStartValue = 0.0;
  Offset? _dragStartPosition;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focus ?? FocusNode();
    final opacityPercent = (widget.color.a * 100).round();
    _controller = TextEditingController(text: '$opacityPercent%');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(GradientAlphaInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focus != oldWidget.focus) {
      oldWidget.focus?.removeListener(_onFocusChange);
      if (oldWidget.focus == null) _focusNode.dispose();
      _focusNode = widget.focus ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
    if (widget.color.a != oldWidget.color.a &&
        !_focusNode.hasFocus &&
        !_isDragging) {
      final int newPercent = (widget.color.a * 100).round();
      final String currentText = _controller.text;
      final int? currentPercent =
          int.tryParse(currentText.replaceAll('%', '').trim());
      if (currentPercent != newPercent) {
        _controller.text = '$newPercent%';
      }
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Select all text when focused (minus the % sign)
      final textWithoutPercent = _controller.text.replaceAll('%', '');
      _controller.text = textWithoutPercent;
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textWithoutPercent.length,
      );
    } else if (!_isDragging) {
      // Validate and update value when focus is lost
      final text = _controller.text.trim().replaceAll('%', '');
      if (text.isEmpty) {
        final opacityPercent = (widget.color.a * 100).round();
        _controller.text = '$opacityPercent%';
        return;
      }
      final numValue = num.tryParse(text);
      if (numValue != null) {
        // Clamp to valid range (0-100)
        final clampedValue = numValue.clamp(0, 100);
        final newOpacity = (clampedValue / 100).clamp(0.0, 1.0);
        
        // Update text field with clamped value and % sign
        _controller.text = '${clampedValue.round()}%';
        
        widget.onValueUpdate?.call(widget.color.withValues(alpha: newOpacity));
      } else {
        final opacityPercent = (widget.color.a * 100).round();
        _controller.text = '$opacityPercent%';
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    if (widget.focus == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final opacity = widget.color.a;

    // Modern border colors following style guide
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.1);
    
    final focusBorderColor = colorScheme.primary;
    
    final hoverBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.15);
    
    // Background colors for skeumorphic effect
    final backgroundColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.5);

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: widget.labelAlignment == TextAlign.right
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        spacing: 0,
        children: [
        if (widget.showLabel)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text(
              widget.label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 1.0,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ),
        MouseRegion(
          cursor: _isDragging
              ? SystemMouseCursors.resizeLeftRight
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.readOnly
                ? null
                : () {
                    if (!_focusNode.hasFocus) _focusNode.requestFocus();
                  },
            onHorizontalDragStart: widget.readOnly
                ? null
                : (DragStartDetails details) {
                    if (_focusNode.hasFocus) _focusNode.unfocus();
                    setState(() {
                      _isDragging = true;
                      _dragStartValue = opacity;
                      _dragStartPosition = details.globalPosition;
                    });
                  },
            onHorizontalDragUpdate: widget.readOnly
                ? null
                : (DragUpdateDetails details) {
                    if (_dragStartPosition == null) return;
                    final delta = (details.globalPosition.dx - _dragStartPosition!.dx) * 0.01;
                    final newOpacity = (_dragStartValue + delta).clamp(0.0, 1.0);
                    widget.onDragUpdate?.call(widget.color.withValues(alpha: newOpacity));
                    final opacityPercent = (newOpacity * 100).round();
                    _controller.text = '$opacityPercent%';
                  },
            onHorizontalDragEnd: widget.readOnly
                ? null
                : (DragEndDetails details) {
                    setState(() {
                      _isDragging = false;
                      _dragStartPosition = null;
                    });
                    widget.onDragEnd?.call();
                  },
            child: SizedBox(
              width: 78,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: widget.showOutline || _focusNode.hasFocus || _isDragging
                      ? backgroundColor
                      : null,
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? focusBorderColor
                        : (_isDragging
                            ? hoverBorderColor
                            : (widget.showOutline
                                ? borderColor
                                : Colors.transparent)),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: widget.showOutline || _focusNode.hasFocus || _isDragging
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
                          if (!_isDragging && !_focusNode.hasFocus)
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: IgnorePointer(
                    ignoring: _isDragging || !_focusNode.hasFocus,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      readOnly: widget.readOnly,
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (value) {
                        final cleanValue = value.trim().replaceAll('%', '');
                        final numValue = num.tryParse(cleanValue);
                        if (numValue != null) {
                          // Clamp to valid range (0-100)
                          final clampedValue = numValue.clamp(0, 100);
                          final newOpacity = (clampedValue / 100).clamp(0.0, 1.0);
                          
                          // Update text field with clamped value and % sign
                          _controller.text = '${clampedValue.round()}%';
                          
                          widget.onValueUpdate?.call(
                            widget.color.withValues(alpha: newOpacity),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

