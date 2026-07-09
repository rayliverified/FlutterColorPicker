import 'package:colorpicker/colorpicker.dart';
import 'package:flutter/material.dart';

/// Demonstrates utility functions for color manipulation.
class UtilityFunctionsDemo extends StatelessWidget {
  final Color selectedColor;

  const UtilityFunctionsDemo({
    super.key,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Utility Functions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _UtilityDemoItem(
          label: 'Color to Hex:',
          value: colorToHex(selectedColor, withHashtag: true),
        ),
        _UtilityDemoItem(
          label: 'Color to Hex (with alpha):',
          value: colorToHex(
            selectedColor,
            withHashtag: true,
            withAlpha: true,
          ),
        ),
        _UtilityDemoItem(
          label: 'Parse Hex "#FF00AA":',
          value: hexToColor('#FF00AA')?.toString() ?? 'Invalid',
        ),
        _UtilityDemoItem(
          label: 'Parse Hex "#FF00AAFF" (with alpha):',
          value: hexToColor('#FF00AAFF')?.toString() ?? 'Invalid',
        ),
        _UtilityDemoItem(
          label: 'Is Valid Hex "#ABC":',
          value: isValidHex('#ABC').toString(),
        ),
        _UtilityDemoItem(
          label: 'Is Valid Hex "#GGG":',
          value: isValidHex('#GGG').toString(),
        ),
        _UtilityDemoItem(
          label: 'Normalize Hex "ABC":',
          value: normalizeHex('ABC', withAlpha: false),
        ),
        _UtilityDemoItem(
          label: 'Normalize Hex "FF00AA" (with alpha):',
          value: normalizeHex('FF00AA', withAlpha: true),
        ),
      ],
    );
  }
}

/// Individual utility function demo item.
class _UtilityDemoItem extends StatelessWidget {
  final String label;
  final String value;

  const _UtilityDemoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

