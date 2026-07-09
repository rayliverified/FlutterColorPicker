import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/color_stop.dart';
import 'angle_input_dialer.dart';
import 'color_picker.dart';
import 'gradient_alpha_input.dart';

/// Callback for gradient stop changes.
typedef GradientStopChangedCallback = void Function(List<ColorStop> stops);

/// Widget for editing gradient stops with visual controls.
///
/// This widget provides:
/// - Visual gradient preview with stops
/// - Draggable stop pointers
/// - Add stops by tapping
/// - Delete stops by dragging down
/// - Copy stops with Alt+drag
class GradientEditor extends StatefulWidget {
  /// Current list of gradient stops.
  final List<ColorStop> stops;

  /// Called when stops are modified.
  final GradientStopChangedCallback onStopsChanged;

  /// Called when a stop is selected.
  final ValueChanged<int>? onStopSelected;

  /// Currently selected stop index.
  final int selectedStopIndex;

  /// Called when user starts modifying stops.
  final VoidCallback? onChangeStart;

  /// Called when user finishes modifying stops.
  final VoidCallback? onChangeEnd;

  /// Widget to display as global gradient controls.
  final Widget? globalControls;

  /// Widget to display as stop-specific controls (color picker, etc).
  final Widget? stopControls;

  /// Paint type to determine if angle control should be shown.
  final PaintType? paintType;

  /// Current gradient angle (for linear and angular gradients).
  final double? gradientAngle;

  /// Called when gradient angle changes.
  final ValueChanged<double>? onGradientAngleChanged;

  /// Called when user finishes interacting with angle.
  final VoidCallback? onAngleChangeEnd;

  /// Global opacity for gradients.
  final double? gradientOpacity;

  /// Called when gradient opacity changes.
  final ValueChanged<double>? onGradientOpacityChanged;

  /// Read-only mode.
  final bool readOnly;

  /// Height of the gradient bar.
  final double barHeight;

  /// Padding around the widget.
  final EdgeInsets padding;

  const GradientEditor({
    super.key,
    required this.stops,
    required this.onStopsChanged,
    required this.selectedStopIndex,
    this.onStopSelected,
    this.onChangeStart,
    this.onChangeEnd,
    this.globalControls,
    this.stopControls,
    this.paintType,
    this.gradientAngle,
    this.onGradientAngleChanged,
    this.onAngleChangeEnd,
    this.gradientOpacity,
    this.onGradientOpacityChanged,
    this.readOnly = false,
    this.barHeight = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  State<GradientEditor> createState() => _GradientEditorState();
}

class _GradientEditorState extends State<GradientEditor> {
  /// Index of stop that should be deleted on pan end.
  int? _prepDeletion;

  // Precomputed each build() so per-stop lookup is O(1).
  double _minStopPos = 0;
  double _maxStopPos = 1;

  bool _isEdgeStop(int index) {
    if (widget.stops.length < 2) return true;
    final pos = widget.stops[index].position;
    return pos == _minStopPos || pos == _maxStopPos;
  }

  void _addStop(double position) {
    if (widget.readOnly) return;

    widget.onChangeStart?.call();

    final newStops = [...widget.stops];
    // Use a safe index in case selectedStopIndex is out of bounds
    final safeIndex = widget.selectedStopIndex.clamp(
      0,
      widget.stops.length - 1,
    );
    final currentColor = widget.stops[safeIndex].color;

    newStops.add(
      ColorStop(position: position.clamp(0.0, 1.0), color: currentColor),
    );

    widget.onStopsChanged(newStops);
    widget.onStopSelected?.call(newStops.length - 1);

    widget.onChangeEnd?.call();
  }

  void _updateStopPosition(int index, double position) {
    if (widget.readOnly) return;

    final newStops = [...widget.stops];
    newStops[index] = newStops[index].copyWith(
      position: position.clamp(0.0, 1.0),
    );

    widget.onStopsChanged(newStops);
  }

  void _deleteStop(int index) {
    if (widget.readOnly || widget.stops.length <= 2) return;

    widget.onChangeStart?.call();

    final newStops = [...widget.stops];
    newStops.removeAt(index);

    widget.onStopsChanged(newStops);

    // Adjust selected index if needed
    if (widget.selectedStopIndex >= newStops.length) {
      widget.onStopSelected?.call(newStops.length - 1);
    } else if (widget.selectedStopIndex == index && index > 0) {
      widget.onStopSelected?.call(index - 1);
    }

    widget.onChangeEnd?.call();
  }

  void _copyStop(int index) {
    if (widget.readOnly) return;

    widget.onChangeStart?.call();

    final newStops = [...widget.stops];
    final stopToCopy = widget.stops[index];

    newStops.add(
      ColorStop(position: stopToCopy.position, color: stopToCopy.color),
    );

    widget.onStopsChanged(newStops);
    widget.onStopSelected?.call(newStops.length - 1);

    widget.onChangeEnd?.call();
  }

  void _prepStopDeletion(Offset localPosition, int index) {
    if (widget.readOnly || widget.stops.length <= 2) return;

    const threshold = 10.0;
    if (localPosition.dy > 15 + threshold || localPosition.dy < 0 - threshold) {
      setState(() => _prepDeletion = index);
    } else {
      setState(() => _prepDeletion = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sort stops for visual display
    final sortedStops = [...widget.stops]
      ..sort((a, b) => a.position.compareTo(b.position));

    final colors = sortedStops.map((stop) => stop.color).toList();
    final positions = sortedStops.map((stop) => stop.position).toList();

    // Cache edge positions for O(1) _isEdgeStop lookups this frame.
    if (sortedStops.isNotEmpty) {
      _minStopPos = sortedStops.first.position;
      _maxStopPos = sortedStops.last.position;
    }

    // Get theme colors for checkerboard and border
    final isDark = theme.brightness == Brightness.dark;
    final checkerboardColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.15);
    final borderColor = colorScheme.outline.withValues(alpha: 0.5);

    // Add 8px extra padding for gradient bar and stop pointers
    final gradientBarPadding = widget.padding.copyWith(
      left: widget.padding.left + 8,
      right: widget.padding.right + 8,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gradient bar with stops
        SizedBox(
          height: 70, // Increased by 8px for extended interactable area at top
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth - widget.padding.horizontal;

              return Stack(
                children: [
                  // Invisible tap area for adding stops
                  Positioned.fill(
                    child: Padding(
                      padding: widget.padding,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: widget.readOnly
                            ? null
                            : (details) {
                                widget.onChangeStart?.call();
                              },
                        onPanUpdate: widget.readOnly
                            ? null
                            : (details) {
                                final index = widget.selectedStopIndex;
                                if (index < 0 || index >= widget.stops.length) {
                                  return;
                                }

                                final currentPos =
                                    widget.stops[index].position * width;
                                final newPos =
                                    (currentPos + details.delta.dx) / width;

                                _updateStopPosition(index, newPos);
                                _prepStopDeletion(details.localPosition, index);
                              },
                        onPanEnd: widget.readOnly
                            ? null
                            : (details) {
                                if (_prepDeletion != null) {
                                  _deleteStop(_prepDeletion!);
                                  _prepDeletion = null;
                                } else {
                                  widget.onChangeEnd?.call();
                                }
                              },
                        // Tap on empty bar area adds a new stop at that position.
                        onTapUp: widget.readOnly
                            ? null
                            : (details) {
                                final position =
                                    details.localPosition.dx / width;
                                _addStop(position);
                              },
                      ),
                    ),
                  ),
                  // Gradient preview bar with extra 8px side padding
                  Positioned(
                    left: gradientBarPadding.left,
                    right: gradientBarPadding.right,
                    top: 38,
                    height: widget.barHeight,
                    child: CustomPaint(
                      painter: _GradientBarPainter(
                        colors: colors,
                        stops: positions,
                        checkerboardColor: checkerboardColor,
                        borderColor: borderColor,
                      ),
                    ),
                  ),
                  // Stop pointers
                  for (int i = 0; i < widget.stops.length; i++)
                    _GradientStopPointer(
                      key: ValueKey('stop_$i'),
                      stop: widget.stops[i],
                      isSelected: i == widget.selectedStopIndex,
                      isEdgeStop: _isEdgeStop(i),
                      shouldBeDeleted: _prepDeletion == i,
                      readOnly: widget.readOnly,
                      padding: gradientBarPadding,
                      onSelect: () {
                        widget.onStopSelected?.call(
                          i == widget.selectedStopIndex ? -1 : i,
                        );
                      },
                      onSlideStart: () {
                        widget.onChangeStart?.call();
                      },
                      onSlideUpdate: (position, localPosition) {
                        _updateStopPosition(i, position);
                        _prepStopDeletion(localPosition, i);
                      },
                      onSlideEnd: () {
                        if (_prepDeletion == i) {
                          setState(() => _prepDeletion = null);
                          _deleteStop(i);
                        } else {
                          widget.onChangeEnd?.call();
                        }
                      },
                      onCopy: () {
                        _copyStop(i);
                      },
                      onDelete: () {
                        _deleteStop(i);
                      },
                    ),
                ],
              );
            },
          ),
        ),
        // Angle control (for linear and angular gradients)
        if ((widget.paintType == PaintType.gradientLinear ||
                widget.paintType == PaintType.gradientAngular) &&
            widget.gradientAngle != null &&
            widget.onGradientAngleChanged != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.padding.left),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GradientRotationInput(
                    rotation: widget.gradientAngle ?? 0.0,
                    onValueUpdated: widget.readOnly
                        ? null
                        : (double angle) {
                            widget.onGradientAngleChanged?.call(angle);
                            widget.onAngleChangeEnd?.call();
                          },
                    onDragUpdate: widget.readOnly
                        ? null
                        : (double angle) {
                            widget.onGradientAngleChanged?.call(angle);
                          },
                    onDragEnd: widget.onAngleChangeEnd,
                    readOnly: widget.readOnly,
                  ),
                ),
                // Show global opacity alongside angle control for linear/angular
                if (widget.onGradientOpacityChanged != null) ...[
                  const SizedBox(width: 16),
                  GradientAlphaInput(
                    readOnly: widget.readOnly,
                    label: 'Global Opacity',
                    labelAlignment: TextAlign.left,
                    color: Theme.of(context).colorScheme.surface.withValues(
                      alpha: widget.gradientOpacity ?? 1.0,
                    ),
                    onValueUpdate: widget.readOnly
                        ? null
                        : (Color color) {
                            widget.onGradientOpacityChanged?.call(color.a);
                            widget.onChangeEnd?.call();
                          },
                    onDragUpdate: widget.readOnly
                        ? null
                        : (Color color) {
                            widget.onGradientOpacityChanged?.call(color.a);
                          },
                    onDragEnd: widget.onChangeEnd,
                  ),
                ],
              ],
            ),
          ),
        ],
        // Global opacity control (for radial gradients, or linear/angular without angle control)
        if (widget.onGradientOpacityChanged != null &&
            (widget.paintType == PaintType.gradientRadial ||
                ((widget.paintType == PaintType.gradientLinear ||
                        widget.paintType == PaintType.gradientAngular) &&
                    (widget.gradientAngle == null ||
                        widget.onGradientAngleChanged == null)))) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.padding.left),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GradientAlphaInput(
                    readOnly: widget.readOnly,
                    label: 'Global Opacity',
                    labelAlignment: TextAlign.left,
                    color: Theme.of(context).colorScheme.surface.withValues(
                      alpha: widget.gradientOpacity ?? 1.0,
                    ),
                    onValueUpdate: widget.readOnly
                        ? null
                        : (Color color) {
                            widget.onGradientOpacityChanged?.call(color.a);
                            widget.onChangeEnd?.call();
                          },
                    onDragUpdate: widget.readOnly
                        ? null
                        : (Color color) {
                            widget.onGradientOpacityChanged?.call(color.a);
                          },
                    onDragEnd: widget.onChangeEnd,
                  ),
                ),
              ],
            ),
          ),
        ],
        // Stop controls stay visible even when no stop is selected; callers can
        // decide whether the controls should be read-only or use a fallback.
        if (widget.globalControls != null || widget.stopControls != null) ...[
          if (widget.globalControls != null) ...[
            const SizedBox(height: 16),
            widget.globalControls!,
            const SizedBox(
              height: 12,
            ), // Padding below alpha slider to match solid mode
          ],
          if (widget.stopControls != null) widget.stopControls!,
        ],
      ],
    );
  }
}

/// Painter for the gradient preview bar with checkerboard background.
class _GradientBarPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> stops;
  final Color checkerboardColor;
  final Color borderColor;

  _GradientBarPainter({
    required this.colors,
    required this.stops,
    required this.checkerboardColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(90));

    // Clip to rounded rect
    canvas.clipRRect(rRect);

    // Draw checkerboard pattern
    final checkerPaint = Paint()..color = checkerboardColor;
    for (int i = 0; i * 4 < size.width; i++) {
      for (int j = 0; j * 4 < size.height; j++) {
        if (i % 2 != j % 2) continue;
        canvas.drawRect(Rect.fromLTWH(i * 4.0, j * 4.0, 4, 4), checkerPaint);
      }
    }

    // Draw gradient
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        stops: stops,
      ).createShader(rect);
    canvas.drawRect(rect, gradientPaint);

    // Draw border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = borderColor;
    canvas.drawRRect(rRect, borderPaint);
  }

  @override
  bool shouldRepaint(_GradientBarPainter oldDelegate) =>
      !listEquals(colors, oldDelegate.colors) ||
      !listEquals(stops, oldDelegate.stops) ||
      checkerboardColor != oldDelegate.checkerboardColor ||
      borderColor != oldDelegate.borderColor;
}

/// Individual draggable gradient stop pointer.
class _GradientStopPointer extends StatefulWidget {
  final ColorStop stop;
  final bool isSelected;
  final bool isEdgeStop;
  final bool shouldBeDeleted;
  final bool readOnly;
  final EdgeInsets padding;
  final VoidCallback onSelect;
  final VoidCallback onSlideStart;
  final void Function(double position, Offset localPosition) onSlideUpdate;
  final VoidCallback onSlideEnd;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _GradientStopPointer({
    super.key,
    required this.stop,
    required this.isSelected,
    required this.isEdgeStop,
    required this.shouldBeDeleted,
    required this.readOnly,
    required this.padding,
    required this.onSelect,
    required this.onSlideStart,
    required this.onSlideUpdate,
    required this.onSlideEnd,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  State<_GradientStopPointer> createState() => _GradientStopPointerState();
}

class _GradientStopPointerState extends State<_GradientStopPointer> {
  double? _tempPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - widget.padding.horizontal;
          final leftOffset =
              widget.padding.left +
              (widget.stop.position * width).clamp(0.0, width) -
              12;

          return Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(leftOffset, 0),
              child: SizedBox(
                // Extend hit test area upward by 8px (8px extension + visual content)
                height:
                    8 + 36, // 8px extension at top + ~36px for visual content
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: widget.readOnly
                      ? null
                      : (details) {
                          widget.onSlideStart();
                          _tempPosition = null;

                          // Check for Alt key to copy
                          if (HardwareKeyboard.instance.isAltPressed) {
                            widget.onCopy();
                          }
                          widget.onSelect();
                        },
                  onPanUpdate: widget.readOnly
                      ? null
                      : (details) {
                          final currentPos = widget.stop.position * width;
                          _tempPosition ??= currentPos;
                          _tempPosition = _tempPosition! + details.delta.dx;

                          final newPosition = (_tempPosition! / width).clamp(
                            0.0,
                            1.0,
                          );
                          widget.onSlideUpdate(
                            newPosition,
                            details.localPosition,
                          );
                        },
                  onPanEnd: widget.readOnly
                      ? null
                      : (details) {
                          widget.onSlideEnd();
                          _tempPosition = null;
                        },
                  onTap: widget.onSelect,
                  child: Transform.translate(
                    // Shift visual content down by 8px to maintain visual position
                    offset: const Offset(0, 8),
                    child: Visibility(
                      visible: !widget.shouldBeDeleted,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: widget.isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                                width: widget.isSelected ? 2 : 1,
                              ),
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: widget.stop.color,
                                border:
                                    widget.stop.color.withValues(alpha: 1) ==
                                        colorScheme.surface
                                    ? Border.all(
                                        color: colorScheme.outline.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 1,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -1.5),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: widget.isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
