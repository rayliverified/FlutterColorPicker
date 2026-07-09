import 'package:flutter/material.dart';

/// Resize handle widget for the bottom of the popup.
class PopupResizeHandle extends StatefulWidget {
  final ValueChanged<double> onResize;

  const PopupResizeHandle({super.key, required this.onResize});

  @override
  State<PopupResizeHandle> createState() => _PopupResizeHandleState();
}

class _PopupResizeHandleState extends State<PopupResizeHandle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (DragUpdateDetails details) {
        widget.onResize(details.delta.dy);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: SizedBox(
          height: 14,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: _hovered ? 1 : 0.35,
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
