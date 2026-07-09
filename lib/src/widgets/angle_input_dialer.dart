import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget for inputting gradient rotation angle with a visual dialer.
/// 
/// This widget provides:
/// - A circular dialer that can be dragged to set angle
/// - Number input field for precise angle entry
/// - Visual representation of the current angle
/// 
/// Features modern SaaS styling with polished skeumorphic elements.
class GradientRotationInput extends StatefulWidget {
  /// Current rotation angle in degrees (0-360).
  final double rotation;
  
  /// Called when angle value is updated (e.g., from number input).
  final ValueChanged<double>? onValueUpdated;
  
  /// Called when angle is being dragged.
  final ValueChanged<double>? onDragUpdate;
  
  /// Called when drag ends.
  final VoidCallback? onDragEnd;
  
  /// Read-only mode.
  final bool readOnly;

  const GradientRotationInput({
    super.key,
    required this.rotation,
    this.onValueUpdated,
    this.onDragUpdate,
    this.onDragEnd,
    this.readOnly = false,
  });

  @override
  State<GradientRotationInput> createState() => _GradientRotationInputState();
}

class _GradientRotationInputState extends State<GradientRotationInput> {
  void onValueUpdated(num value) {
    // Normalize: convert from UI angle (0-360) to gradient angle
    // UI: 0° = right, 90° = down, 180° = left, 270° = up
    // Gradient: 0° = up, 90° = right, 180° = down, 270° = left
    num normalValue = ((value < 0 ? value + 360 : value) - 90) % 360;
    widget.onValueUpdated?.call(normalValue.toDouble());
    widget.onDragEnd?.call();
  }

  void onDragUpdate(double value) {
    // Normalize: convert from UI angle (0-360) to gradient angle
    num normalValue = ((value < 0 ? value + 360 : value) - 90) % 360;
    widget.onDragUpdate?.call(normalValue.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    // Convert gradient angle to UI angle for display
    double normalizedRot =
        ((widget.rotation < 0 ? widget.rotation + 360 : widget.rotation) + 90) %
            360;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _NumberInput(
          value: normalizedRot.round(),
          title: 'Angle',
          suffix: '°',
          readOnly: widget.readOnly,
          onValueUpdate: onValueUpdated,
          onDragUpdate: onDragUpdate,
          onDragEnd: widget.onDragEnd,
          suggestedContent: const <String>['0', '30', '45', '60', '90', '180'],
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^[-+]?\d*$'))
          ],
        ),
        const SizedBox(width: 12),
        AngleInputDialer(
          value: normalizedRot,
          onDragUpdate: onDragUpdate,
          onDragEnd: widget.onDragEnd,
          readOnly: widget.readOnly,
        ),
      ],
    );
  }
}

/// Circular dialer widget for visually setting gradient rotation angle.
///
/// This widget provides an interactive circular dialer for adjusting gradient
/// angles. Users can drag around the circle to set the angle, which is displayed
/// visually with a line indicator and arc fill.
///
/// Features:
/// - Modern skeumorphic design with depth and shadows
/// - Interactive hover and press states
/// - Visual angle indicator with arc fill
/// - Smooth animations and transitions
///
/// The angle value is in degrees (0-360), where:
/// - 0° = right
/// - 90° = down
/// - 180° = left
/// - 270° = up
///
/// Example:
/// ```dart
/// AngleInputDialer(
///   value: 45.0,
///   onDragUpdate: (angle) {
///     // Handle angle change during drag
///   },
///   onDragEnd: () {
///     // Handle drag end
///   },
/// )
/// ```
class AngleInputDialer extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onDragUpdate;
  final VoidCallback? onDragEnd;
  final double size;
  final bool readOnly;

  const AngleInputDialer({
    super.key,
    required this.value,
    this.size = 36,
    this.onDragUpdate,
    this.onDragEnd,
    this.readOnly = false,
  });

  @override
  State<AngleInputDialer> createState() => _AngleInputDialerState();
}

class _AngleInputDialerState extends State<AngleInputDialer> {
  final GlobalKey circleKey =
      GlobalKey(debugLabel: 'AngleInputDialerState#circleKey');
  bool isHovering = false;
  bool isPressing = false;

  double normalize(double value) {
    double width = 360;
    double offsetValue = value;
    return (offsetValue - ((offsetValue / width).floorToDouble() * width));
  }

  @override
  void initState() {
    super.initState();
  }

  void onPan(Offset localPosition) {
    if (widget.readOnly) return;
    
    isPressing = true;
    isHovering = false;

    RenderBox? box = circleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    Offset center = Offset(
      ((localPosition.dx / box.size.width) * 2) - 1,
      ((localPosition.dy / box.size.height) * 2) - 1,
    );
    double angle = normalize((atan2(center.dy, center.dx) * 180 / pi) + 90);
    widget.onDragUpdate?.call(angle);
  }

  void onPanEnd() {
    isPressing = false;
    setState(() {});
    widget.onDragEnd?.call();
  }

  void onMouseExit(PointerExitEvent details) {
    if (!isHovering) return;
    isHovering = false;
    setState(() {});
  }

  void onMouseEnter(PointerEnterEvent details) {
    if (isPressing || isHovering) return;
    isHovering = true;
    setState(() {});
  }

  void onMouseHover(PointerHoverEvent details) {
    if (isPressing) return;
    isHovering = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    
    return SizedBox.square(
      dimension: widget.size,
      child: MouseRegion(
        cursor: widget.readOnly
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: widget.readOnly ? null : onMouseEnter,
        onExit: widget.readOnly ? null : onMouseExit,
        onHover: widget.readOnly ? null : onMouseHover,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: widget.readOnly
              ? null
              : (DragStartDetails details) => onPan(details.localPosition),
          onPanUpdate: widget.readOnly
              ? null
              : (DragUpdateDetails details) => onPan(details.localPosition),
          onPanEnd:
              widget.readOnly ? null : (DragEndDetails details) => onPanEnd(),
          onTapUp:
              widget.readOnly ? null : (TapUpDetails details) => onPanEnd(),
          onTapDown: widget.readOnly
              ? null
              : (TapDownDetails details) => onPan(details.localPosition),
          onDoubleTap: widget.readOnly
              ? null
              : () {
                  widget.onDragUpdate?.call(0);
                  onPanEnd();
                },
          child: Container(
            key: circleKey,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Outer shadow for floating effect
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.8)
                      : Colors.black.withValues(alpha: 0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
                // Inner highlight for skeumorphic effect
                BoxShadow(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.8),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: CustomPaint(
              painter: RotationAnglePainter(
                angle: widget.value * pi / 180,
                lineColor: (isHovering || isPressing)
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
                angleArcColor: (isHovering || isPressing)
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05)),
                isDark: isDark,
                isActive: isHovering || isPressing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RotationAnglePainter extends CustomPainter {
  final double angle;
  final Color lineColor;
  final Color angleArcColor;
  final bool isDark;
  final bool isActive;

  RotationAnglePainter({
    required this.angleArcColor,
    required this.lineColor,
    required this.angle,
    required this.isDark,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width / 2;
    
    // Draw background with raised edge shadow bands using radial gradient
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                // Center area
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.2),
                // Inner shadow band (darker)
                Colors.black.withValues(alpha: 0.4),
                // Highlight band (lighter - simulates raised edge)
                Colors.white.withValues(alpha: 0.08),
                // Outer edge (darker)
                Colors.black.withValues(alpha: 0.3),
              ]
            : [
                // Center area
                Colors.white.withValues(alpha: 0.4),
                Colors.white.withValues(alpha: 0.4),
                // Inner shadow band (darker)
                Colors.grey.withValues(alpha: 0.25),
                // Highlight band (lighter - simulates raised edge)
                Colors.white.withValues(alpha: 0.8),
                // Outer edge (darker)
                Colors.grey.withValues(alpha: 0.35),
              ],
        stops: const [0.0, 0.78, 0.88, 0.94, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Paint for the angle arc fill
    final arcPaint = Paint()
      ..color = angleArcColor
      ..style = PaintingStyle.fill;

    // Paint for the angle line with rounded caps
    final angleLinePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 2.5 : 2
      ..strokeCap = StrokeCap.round;

    /// Filled in angle arc
    if (angle * 180 / pi < 0) {
      canvas.drawArc(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        -pi / 2,
        pi,
        true,
        arcPaint,
      );

      canvas.drawArc(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        pi / 2,
        angle + pi,
        true,
        arcPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        -pi / 2,
        angle,
        true,
        arcPaint,
      );
    }

    /// Draw the angle indicator line
    final lineEndPoint = center +
        Offset(
          (size.width / 2.0 - 4) * cos(angle - pi / 2),
          (size.height / 2.0 - 4) * sin(angle - pi / 2),
        );
    
    canvas.drawLine(center, lineEndPoint, angleLinePaint);

    /// Draw center dot with subtle shadow for depth
    final centerDotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    // Shadow for center dot
    final shadowPaint = Paint()
      ..color = isDark
          ? Colors.black.withValues(alpha: 0.4)
          : Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    canvas.drawCircle(center + const Offset(0, 0.5), 3.5, shadowPaint);
    canvas.drawCircle(center, 3.5, centerDotPaint);
    
    /// Draw end indicator circle for better visibility
    final endIndicatorPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    final endIndicatorShadowPaint = Paint()
      ..color = isDark
          ? Colors.black.withValues(alpha: 0.4)
          : Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    
    canvas.drawCircle(lineEndPoint + const Offset(0, 0.5), 3, endIndicatorShadowPaint);
    canvas.drawCircle(lineEndPoint, 3, endIndicatorPaint);
    
    // Inner circle for depth on end indicator
    final innerCirclePaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.3)
          : Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(lineEndPoint - const Offset(0.5, 0.5), 1.5, innerCirclePaint);
    
    // Highlight on center dot for skeumorphic effect - always visible
    final centerShinePaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.25)
          : Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      center - const Offset(1, 1),
      1.3,
      centerShinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant RotationAnglePainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.angleArcColor != angleArcColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isActive != isActive;
  }
}

/// Modern number input widget for angle entry with drag-to-adjust functionality.
/// 
/// Features:
/// - Text input with validation
/// - Horizontal drag to adjust value
/// - Modern skeumorphic styling
/// - Theme-aware colors and borders
class _NumberInput extends StatefulWidget {
  final num value;
  final String? title;
  final String? suffix;
  final bool readOnly;
  final ValueChanged<num>? onValueUpdate;
  final ValueChanged<double>? onDragUpdate;
  final VoidCallback? onDragEnd;
  final List<String>? suggestedContent;
  final List<TextInputFormatter>? inputFormatters;

  const _NumberInput({
    required this.value,
    this.title,
    this.suffix,
    this.readOnly = false,
    this.onValueUpdate,
    this.onDragUpdate,
    this.onDragEnd,
    this.suggestedContent,
    this.inputFormatters,
  });

  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isDragging = false;
  double? _dragStartValue;
  Offset? _dragStartPosition;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus && !_isDragging) {
      _controller.text = widget.value.toString();
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Select all text when focused
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    } else {
      // Validate and update value when focus is lost
      final text = _controller.text.trim();
      if (text.isEmpty) {
        _controller.text = widget.value.toString();
        return;
      }
      final value = num.tryParse(text);
      if (value != null) {
        // Normalize angle to 0-360 range (handles negative and large values)
        // For very large values, use modulo to wrap around
        final normalized = value % 360;
        final clampedValue = normalized < 0 ? normalized + 360 : normalized;
        
        // Update text field with clamped value
        _controller.text = clampedValue.round().toString();
        
        widget.onValueUpdate?.call(clampedValue);
      } else {
        _controller.text = widget.value.toString();
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (widget.readOnly) return;
    _isDragging = true;
    _dragStartValue = widget.value.toDouble();
    _dragStartPosition = details.globalPosition;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || widget.readOnly) return;
    
    final delta = details.globalPosition - _dragStartPosition!;
    final newValue = _dragStartValue! + delta.dx * 0.5; // Adjust sensitivity
    widget.onDragUpdate?.call(newValue);
    _controller.text = newValue.round().toString();
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;
    _dragStartValue = null;
    _dragStartPosition = null;
    widget.onDragEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    
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
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 0,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text(
              widget.title!,
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
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? focusBorderColor
                      : (_isDragging ? hoverBorderColor : borderColor),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
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
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        readOnly: widget.readOnly,
                        enabled: !widget.readOnly,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: widget.inputFormatters,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (value) {
                          final numValue = num.tryParse(value);
                          if (numValue != null) {
                            // Normalize angle to 0-360 range (handles negative and large values)
                            // For very large values, use modulo to wrap around
                            final normalized = numValue % 360;
                            final clampedValue = normalized < 0 ? normalized + 360 : normalized;
                            
                            // Update text field with clamped value
                            _controller.text = clampedValue.round().toString();
                            
                            widget.onValueUpdate?.call(clampedValue);
                          }
                        },
                      ),
                    ),
                    if (widget.suffix != null)
                      Text(
                        widget.suffix!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

