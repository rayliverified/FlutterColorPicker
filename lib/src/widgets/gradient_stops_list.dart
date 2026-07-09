import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/color_stop.dart';
import '../utils/color_utils.dart';
import 'color_tile.dart';

/// Editable list of gradient stops.
///
/// This complements [GradientEditor]'s visual stop handles with a compact,
/// inspector-style list for selecting, adding, deleting, and editing stop
/// positions/colors. It follows the compact inline-row input styling used by
/// [ColorPickerRow]: values are text-first, become editable on click, and only
/// show input chrome while editing/dragging.
class GradientStopsList extends StatelessWidget {
  /// Current gradient stops.
  final List<ColorStop> stops;

  /// Currently selected stop index.
  final int selectedStopIndex;

  /// Called when stops are modified.
  final ValueChanged<List<ColorStop>> onStopsChanged;

  /// Called when a stop row is selected.
  final ValueChanged<int>? onStopSelected;

  /// Read-only mode.
  final bool readOnly;

  /// Whether to show the section title.
  final bool showTitle;

  /// Outer padding for the component.
  final EdgeInsets padding;

  const GradientStopsList({
    super.key,
    required this.stops,
    required this.selectedStopIndex,
    required this.onStopsChanged,
    this.onStopSelected,
    this.readOnly = false,
    this.showTitle = true,
    this.padding = EdgeInsets.zero,
  });

  void _select(int index) {
    onStopSelected?.call(index == selectedStopIndex ? -1 : index);
  }

  void _delete(int index) {
    if (readOnly || stops.length <= 2) return;
    final updated = [...stops]..removeAt(index);
    onStopsChanged(updated);
    onStopSelected?.call(selectedStopIndex.clamp(0, updated.length - 1));
  }

  void _addStop() {
    if (readOnly || stops.isEmpty) return;

    final entries = stops.asMap().entries.toList()
      ..sort((a, b) => a.value.position.compareTo(b.value.position));

    var insertAfter = entries.first;
    var insertBefore = entries.last;
    var largestGap = -1.0;

    for (var i = 0; i < entries.length - 1; i++) {
      final current = entries[i];
      final next = entries[i + 1];
      final gap = next.value.position - current.value.position;
      if (gap > largestGap) {
        largestGap = gap;
        insertAfter = current;
        insertBefore = next;
      }
    }

    final position = largestGap <= 0
        ? 0.5
        : (insertAfter.value.position + insertBefore.value.position) / 2;
    final color =
        Color.lerp(insertAfter.value.color, insertBefore.value.color, 0.5) ??
        insertAfter.value.color;

    final updated = [...stops, ColorStop(position: position, color: color)];
    onStopsChanged(updated);
    onStopSelected?.call(updated.length - 1);
  }

  void _updatePosition(int index, double position) {
    if (readOnly) return;
    final updated = [
      for (var i = 0; i < stops.length; i++)
        if (i == index)
          stops[i].copyWith(position: position.clamp(0.0, 1.0))
        else
          stops[i],
    ];
    onStopsChanged(updated);
  }

  void _updateColor(int index, Color color) {
    if (readOnly) return;
    final updated = [
      for (var i = 0; i < stops.length; i++)
        if (i == index) stops[i].copyWith(color: color) else stops[i],
    ];
    onStopsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sortedEntries = stops.asMap().entries.toList()
      ..sort((a, b) => a.value.position.compareTo(b.value.position));

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showTitle) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gradient Stops (${stops.length})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (!readOnly)
                  _StopsIconButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Add stop',
                    onTap: _addStop,
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in sortedEntries) ...[
                  _GradientStopRow(
                    stop: entry.value,
                    isSelected: entry.key == selectedStopIndex,
                    canDelete: stops.length > 2,
                    readOnly: readOnly,
                    isDark: isDark,
                    onTap: () => _select(entry.key),
                    onDelete: () => _delete(entry.key),
                    onPositionChanged: (position) =>
                        _updatePosition(entry.key, position),
                    onColorChanged: (color) => _updateColor(entry.key, color),
                  ),
                  if (entry != sortedEntries.last) const SizedBox(height: 2),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientStopRow extends StatelessWidget {
  final ColorStop stop;
  final bool isSelected;
  final bool canDelete;
  final bool readOnly;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<double> onPositionChanged;
  final ValueChanged<Color> onColorChanged;

  const _GradientStopRow({
    required this.stop,
    required this.isSelected,
    required this.canDelete,
    required this.readOnly,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
    required this.onPositionChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.12)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        child: Container(
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              ColorTile(
                color: stop.color,
                size: 22,
                borderRadius: 5,
                borderWidth: 1,
                onTap: onTap,
              ),
              const SizedBox(width: 9),
              _InlineStopInput(
                width: 48,
                value: '${(stop.position * 100).round()}%',
                readOnly: readOnly,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}%?')),
                ],
                onSubmitted: (value) {
                  final clean = value.trim().replaceAll('%', '');
                  final parsed = int.tryParse(clean);
                  if (parsed == null) return;
                  onPositionChanged(parsed.clamp(0, 100) / 100);
                },
                onDragUpdate: (delta) {
                  onPositionChanged((stop.position + delta / 240).clamp(0, 1));
                },
              ),
              const SizedBox(width: 8),
              _InlineStopInput(
                width: 86,
                value: colorToHex(stop.color, withHashtag: true),
                readOnly: readOnly,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
                  LengthLimitingTextInputFormatter(9),
                ],
                onSubmitted: (value) {
                  final color = hexToColor(value, fallback: stop.color);
                  if (color != null) onColorChanged(color);
                },
              ),
              const Spacer(),
              if (!readOnly && canDelete) ...[
                const SizedBox(width: 8),
                _StopsIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Delete stop',
                  onTap: onDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineStopInput extends StatefulWidget {
  final String value;
  final double? width;
  final bool readOnly;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<double>? onDragUpdate;

  const _InlineStopInput({
    required this.value,
    required this.readOnly,
    required this.keyboardType,
    required this.onSubmitted,
    this.width,
    this.inputFormatters,
    this.onDragUpdate,
  });

  @override
  State<_InlineStopInput> createState() => _InlineStopInputState();
}

class _InlineStopInputState extends State<_InlineStopInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;
  bool _isDragging = false;
  Offset? _dragStartPosition;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) _commit();
    });
  }

  @override
  void didUpdateWidget(_InlineStopInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus &&
        !_isDragging &&
        widget.value != oldWidget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    if (widget.readOnly) return;
    setState(() => _isEditing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _commit() {
    final value = _controller.text.trim();
    widget.onSubmitted(value);
    if (mounted) setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final focusBorderColor = colorScheme.primary;
    final hoverBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.15);
    final backgroundColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white;

    final input = MouseRegion(
      cursor: _isDragging
          ? SystemMouseCursors.resizeLeftRight
          : (widget.readOnly
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click),
      child: GestureDetector(
        onTap: _isEditing || _isDragging ? null : _enterEditMode,
        onHorizontalDragStart:
            widget.readOnly || _isEditing || widget.onDragUpdate == null
            ? null
            : (details) {
                setState(() => _isDragging = true);
                _dragStartPosition = details.globalPosition;
              },
        onHorizontalDragUpdate:
            widget.readOnly || _isEditing || widget.onDragUpdate == null
            ? null
            : (details) {
                final start = _dragStartPosition;
                if (start == null) return;
                widget.onDragUpdate!(details.globalPosition.dx - start.dx);
                _dragStartPosition = details.globalPosition;
              },
        onHorizontalDragEnd:
            widget.readOnly || _isEditing || widget.onDragUpdate == null
            ? null
            : (_) {
                setState(() => _isDragging = false);
                _dragStartPosition = null;
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _isEditing || _isDragging ? backgroundColor : null,
            border: Border.all(
              color: _isEditing
                  ? focusBorderColor
                  : (_isDragging ? hoverBorderColor : Colors.transparent),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isEditing || _isDragging
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: IgnorePointer(
              ignoring: _isDragging,
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      readOnly: widget.readOnly,
                      keyboardType: widget.keyboardType,
                      inputFormatters: widget.inputFormatters,
                      textInputAction: TextInputAction.done,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      cursorColor: colorScheme.primary,
                      cursorWidth: 1.5,
                      cursorRadius: const Radius.circular(1),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) {
                        _focusNode.unfocus();
                        _commit();
                      },
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: input);
    }
    return input;
  }
}

class _StopsIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _StopsIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(
            icon,
            size: 15,
            color: colorScheme.onSurface.withValues(alpha: 0.54),
          ),
        ),
      ),
    );
  }
}
