import 'package:flutter/material.dart';

import 'color_picker.dart';

/// Custom dropdown widget using MenuAnchor to fix z-index issues in popups.
class PaintTypeDropdown extends StatelessWidget {
  final PaintType value;
  final List<PaintType> items;
  final ValueChanged<PaintType?> onChanged;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const PaintTypeDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final triggerTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      height: 1.0,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
    );
    final menuItemTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurface,
    );
    final menuItemStyle = ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
      textStyle: WidgetStatePropertyAll(menuItemTextStyle),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused)) {
          return colorScheme.onSurface.withValues(alpha: 0.08);
        }
        return null;
      }),
      side: const WidgetStatePropertyAll(BorderSide.none),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return MenuAnchor(
      style: const MenuStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
      menuChildren: items.map((PaintType type) {
        return MenuItemButton(
          style: menuItemStyle,
          onPressed: () => onChanged(type),
          child: DefaultTextStyle(
            style: menuItemTextStyle ?? const TextStyle(),
            child: Text(type.prettify),
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
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(value.prettify, style: triggerTextStyle),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
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
