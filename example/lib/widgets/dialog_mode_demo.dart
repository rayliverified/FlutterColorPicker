import 'package:colorpicker/colorpicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../local_soft_saas.dart';

/// Dialog mode demonstration.
class DialogModeDemo extends StatefulWidget {
  const DialogModeDemo({super.key});

  @override
  State<DialogModeDemo> createState() => _DialogModeDemoState();
}

class _DialogModeDemoState extends State<DialogModeDemo> {
  Color _selectedColor = const Color(0xFF5C69E5);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _DialogVariant(
          label: 'Default (Full Featured)',
          description:
              'Auto-loads recent colors, presets, and preset library dropdown.',
          child: SoftSaaSButton(
            onPressed: () async {
              final Color? result = await showColorPickerDialog(
                context: context,
                initialColor: _selectedColor,
                title: 'Select Color',
              );
              if (result != null) setState(() => _selectedColor = result);
            },
            icon: LucideIcons.pipette,
            child: const Text('Open Color Picker Dialog'),
          ),
        ),
        const SizedBox(height: 16),
        _DialogVariant(
          label: 'Minimal',
          description: 'Just the color picker, no recent colors or presets.',
          child: SoftSaaSButton(
            variant: SoftSaaSButtonVariant.secondary,
            onPressed: () async {
              final Color? result = await showColorPickerDialog(
                context: context,
                initialColor: _selectedColor,
                title: 'Select Color',
                showRecentColors: false,
                showPresets: false,
              );
              if (result != null) setState(() => _selectedColor = result);
            },
            icon: LucideIcons.pipette,
            child: const Text('Open Minimal Color Picker'),
          ),
        ),
      ],
    );
  }
}

class _DialogVariant extends StatelessWidget {
  const _DialogVariant({
    required this.label,
    required this.description,
    required this.child,
  });

  final String label;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 1.0,
            fontWeight: FontWeight.w600,
            color: SoftSaaSTokens.primaryText(brightness),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: TextStyle(
            fontSize: 11,
            height: 1.2,
            color: SoftSaaSTokens.tertiaryText(brightness),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
