import 'package:colorpicker/colorpicker.dart';
import 'package:flutter/material.dart';
import '../local_soft_saas.dart';

/// Inline row mode demonstration (ColorPickerRow).
class ColorPickerRowDemo extends StatefulWidget {
  const ColorPickerRowDemo({super.key});

  @override
  State<ColorPickerRowDemo> createState() => _ColorPickerRowDemoState();
}

class _ColorPickerRowDemoState extends State<ColorPickerRowDemo> {
  Color _compactColor = const Color(0x80FF5722);
  Color _withLabelsColor = const Color(0xFF00BCD4);
  Color _fullColor = const Color(0xCC2196F3);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _RowVariant(
          label: 'Compact (HEX + Opacity)',
          description: 'Default — swatch, hex, and opacity percentage.',
          color: _compactColor,
          child: ColorPickerRow(
            color: _compactColor,
            onColorChanged: (c) => setState(() => _compactColor = c),
            showOpacity: true,
          ),
        ),
        const SizedBox(height: 16),
        _RowVariant(
          label: 'With Labels',
          description: 'Shows labels above inputs (HEX, Opacity, etc.).',
          color: _withLabelsColor,
          child: ColorPickerRow(
            color: _withLabelsColor,
            onColorChanged: (c) => setState(() => _withLabelsColor = c),
            showOpacity: true,
            showLabels: true,
          ),
        ),
        const SizedBox(height: 16),
        _RowVariant(
          label: 'Full (RGB + Alpha)',
          description: 'Complete mode with RGB, alpha, labels, and outline.',
          color: _fullColor,
          child: ColorPickerRow(
            color: _fullColor,
            onColorChanged: (c) => setState(() => _fullColor = c),
            showRGB: true,
            showAlpha: true,
            showLabels: true,
            showOutline: true,
          ),
        ),
      ],
    );
  }
}

class _RowVariant extends StatelessWidget {
  const _RowVariant({
    required this.label,
    required this.description,
    required this.color,
    required this.child,
  });

  final String label;
  final String description;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final border = SoftSaaSTokens.primaryBorder(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.0,
                  fontWeight: FontWeight.w600,
                  color: SoftSaaSTokens.primaryText(brightness),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: border, width: 1),
              ),
              child: Text(
                colorToHex(color, withHashtag: true),
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: SoftSaaSTokens.secondaryText(brightness),
                ),
              ),
            ),
          ],
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
