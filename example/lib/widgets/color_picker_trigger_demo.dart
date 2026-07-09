import 'package:color_picker_plus/color_picker_plus.dart';
import 'package:flutter/material.dart';
import '../local_soft_saas.dart';

/// Popup trigger mode demonstration (ColorPickerTrigger).
class ColorPickerTriggerDemo extends StatefulWidget {
  const ColorPickerTriggerDemo({super.key});

  @override
  State<ColorPickerTriggerDemo> createState() => _ColorPickerTriggerDemoState();
}

class _ColorPickerTriggerDemoState extends State<ColorPickerTriggerDemo> {
  Color _color = const Color(0xFFFF5722);

  void _onPaintChanged(PaintData paint) {
    setState(() => _color = paint.color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TriggerVariant(
          label: 'Simple (Color Only)',
          description: 'Convenience parameter — just pass a Color.',
          child: ColorPickerTrigger(
            color: _color,
            onPaintChanged: _onPaintChanged,
          ),
        ),
        const SizedBox(height: 16),
        _TriggerVariant(
          label: 'Recent Colors Only',
          description: 'Shows recent colors, no presets.',
          child: ColorPickerTrigger(
            color: _color,
            onPaintChanged: _onPaintChanged,
            showPresets: false,
          ),
        ),
        const SizedBox(height: 16),
        _TriggerVariant(
          label: 'Presets Only',
          description: 'Shows presets, no recent colors.',
          child: ColorPickerTrigger(
            color: _color,
            onPaintChanged: _onPaintChanged,
            showRecentColors: false,
          ),
        ),
        const SizedBox(height: 16),
        _TriggerVariant(
          label: 'Minimal',
          description: 'Just the color picker, no extras.',
          child: ColorPickerTrigger(
            color: _color,
            onPaintChanged: _onPaintChanged,
            showRecentColors: false,
            showPresets: false,
          ),
        ),
        const SizedBox(height: 16),
        _TriggerVariant(
          label: 'Custom Size (40×40)',
          description: 'Larger swatch with 8px radius.',
          child: ColorPickerTrigger(
            color: _color,
            onPaintChanged: _onPaintChanged,
            size: 40,
            borderRadius: 8,
          ),
        ),
        const SizedBox(height: 16),
        _TriggerVariant(
          label: 'Custom Child Widget',
          description: 'Wrap any widget as the tap target.',
          child: ColorPickerTrigger(
            color: _color,
            onPaintChanged: _onPaintChanged,
            child: _ColorButtonChild(color: _color),
          ),
        ),
      ],
    );
  }
}

class _TriggerVariant extends StatelessWidget {
  const _TriggerVariant({
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

class _ColorButtonChild extends StatelessWidget {
  const _ColorButtonChild({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final onColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: SoftSaaSTokens.primaryBorder(brightness),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.color_lens, color: onColor, size: 16),
          const SizedBox(width: 6),
          Text(
            'Pick Color',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: onColor,
            ),
          ),
        ],
      ),
    );
  }
}
