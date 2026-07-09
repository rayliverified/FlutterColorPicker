import 'package:colorpicker/colorpicker.dart';
import 'package:flutter/material.dart';

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

  bool get _hasSelectedStop =>
      _selectedStopIndex >= 0 && _selectedStopIndex < _stops.length;

  int get _safeSelectedStopIndex => _hasSelectedStop ? _selectedStopIndex : 0;

  Color get _selectedColor => _stops[_safeSelectedStopIndex].color;

  void _updateStopColor(Color color) {
    if (!_hasSelectedStop) return;

    setState(() {
      final selectedIndex = _safeSelectedStopIndex;
      _stops = [
        for (int i = 0; i < _stops.length; i++)
          if (i == selectedIndex)
            _stops[i].copyWith(color: color)
          else
            _stops[i],
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.zero,
          stops: _stops,
          selectedStopIndex: _selectedStopIndex,
          onStopsChanged: (stops) => setState(() => _stops = stops),
          onStopSelected: (i) => setState(() => _selectedStopIndex = i),
          onChangeStart: () {},
          onChangeEnd: () {},
          paintType: PaintType.gradientLinear,
          gradientAngle: _gradientAngle,
          onGradientAngleChanged: (v) => setState(() => _gradientAngle = v),
          onAngleChangeEnd: () {},
          stopControls: ColorPicker(
            color: _selectedColor,
            paintType: PaintType.solid,
            onColorChanged: _updateStopColor,
            inputsPadding: const EdgeInsets.symmetric(vertical: 8),
            paletteHeight: 210,
            readOnly: !_hasSelectedStop,
            showTitleBar: false,
            showRecentColors: false,
            showPresets: false,
            showPresetLibrary: false,
            slidersPadding: const EdgeInsets.symmetric(vertical: 12),
            showToolbar: true,
            showDivider: false,
            maxWidth: null,
          ),
        ),
        const SizedBox(height: 16),

        GradientStopsList(
          stops: _stops,
          selectedStopIndex: _selectedStopIndex,
          onStopsChanged: (stops) => setState(() {
            _stops = stops;
            if (_selectedStopIndex >= _stops.length) {
              _selectedStopIndex = _stops.length - 1;
            }
          }),
          onStopSelected: (i) => setState(() => _selectedStopIndex = i),
        ),
      ],
    );
  }
}
