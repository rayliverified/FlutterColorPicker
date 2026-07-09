import 'package:colorpicker/colorpicker.dart';
import 'package:flutter/material.dart';
import '../local_soft_saas.dart';

/// Gradient editor demonstration.
class GradientDemo extends StatefulWidget {
  const GradientDemo({super.key});

  @override
  State<GradientDemo> createState() => _GradientDemoState();
}

class _GradientDemoState extends State<GradientDemo> {
  List<ColorStop> _stops = [
    const ColorStop(position: 0.0, color: Colors.blue),
    const ColorStop(position: 0.5, color: Colors.purple),
    const ColorStop(position: 1.0, color: Colors.red),
  ];

  int _selectedStopIndex = 0;
  double _gradientAngle = 0.0;

  Color get _selectedColor => _stops[_selectedStopIndex].color;

  void _updateStopColor(Color color) {
    setState(() {
      _stops = [
        for (int i = 0; i < _stops.length; i++)
          if (i == _selectedStopIndex)
            _stops[i].copyWith(color: color)
          else
            _stops[i],
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final sortedStops = [..._stops]
      ..sort((a, b) => a.position.compareTo(b.position));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gradient preview strip
        Container(
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: LinearGradient(
              colors: sortedStops.map((s) => s.color).toList(),
              stops: sortedStops.map((s) => s.position).toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: GradientRotation(_gradientAngle * 3.14159 / 180),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Gradient editor
        GradientEditor(
          stops: _stops,
          selectedStopIndex: _selectedStopIndex,
          onStopsChanged: (stops) => setState(() => _stops = stops),
          onStopSelected: (i) => setState(() => _selectedStopIndex = i),
          onChangeStart: () {},
          onChangeEnd: () {},
          globalControls: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GradientRotationInput(
              rotation: _gradientAngle,
              onValueUpdated: (v) => setState(() => _gradientAngle = v),
              onDragUpdate: (v) => setState(() => _gradientAngle = v),
              onDragEnd: () {},
            ),
          ),
          stopControls: SizedBox(
            height: 400,
            child: ColorPicker(
              color: _selectedColor,
              onColorChanged: _updateStopColor,
              paletteHeight: 250,
              showTitleBar: false,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stops list
        Text(
          'Gradient Stops (${_stops.length})',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: SoftSaaSTokens.primaryText(brightness),
          ),
        ),
        const SizedBox(height: 8),
        ..._stops.asMap().entries.map((entry) {
          final i = entry.key;
          final stop = entry.value;
          final isSelected = i == _selectedStopIndex;

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? SoftSaaSTokens.primaryColor(brightness)
                        .withValues(alpha: 0.06)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? SoftSaaSTokens.primaryColor(brightness)
                          .withValues(alpha: 0.2)
                      : SoftSaaSTokens.primaryBorder(brightness),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: stop.color,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: SoftSaaSTokens.primaryBorder(brightness),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(stop.position * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: SoftSaaSTokens.secondaryText(brightness),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    colorToHex(stop.color, withHashtag: true),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: SoftSaaSTokens.tertiaryText(brightness),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
