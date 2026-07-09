import 'package:flutter/material.dart';

/// Resize handle widget for the bottom of the popup.
class PopupResizeHandle extends StatelessWidget {
  final ValueChanged<double> onResize;

  const PopupResizeHandle({
    super.key,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (DragUpdateDetails details) {
        onResize(details.delta.dy);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        child: Container(
          height: 8,
          color: colorScheme.surface,
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
