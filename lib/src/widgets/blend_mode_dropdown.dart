import 'package:flutter/material.dart';

import '../models/blend_mode_type.dart';

/// Custom dropdown widget using MenuAnchor for blend mode selection.
class BlendModeDropdown extends StatelessWidget {
  final BlendModeType value;
  final List<BlendModeType> items;
  final ValueChanged<BlendModeType?> onChanged;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const BlendModeDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: items.map((BlendModeType mode) {
        return MenuItemButton(
          onPressed: () => onChanged(mode),
          child: Text(
            mode.label,
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
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        value.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

