import 'package:colorpicker/colorpicker.dart';
import 'package:flutter/material.dart';
import '../local_soft_saas.dart';

/// Demonstrates the LayersList widget — full layer management UI.
class LayersListDemo extends StatefulWidget {
  const LayersListDemo({super.key});

  @override
  State<LayersListDemo> createState() => _LayersListDemoState();
}

class _LayersListDemoState extends State<LayersListDemo> {
  int? _selectedLayerIndex;

  final List<ColorPreset> _presets = [
    ColorPreset.solid(color: const Color(0xFF000000), label: 'Black'),
    ColorPreset.solid(color: const Color(0xFFFFFFFF), label: 'White'),
    ColorPreset.solid(color: const Color(0xFFFF0000), label: 'Red'),
    ColorPreset.solid(color: const Color(0xFF00FF00), label: 'Green'),
    ColorPreset.solid(color: const Color(0xFF0000FF), label: 'Blue'),
    ColorPreset.solid(color: const Color(0xFFFFFF00), label: 'Yellow'),
    ColorPreset.solid(color: const Color(0xFFFF00FF), label: 'Magenta'),
    ColorPreset.solid(color: const Color(0xFF00FFFF), label: 'Cyan'),
  ];

  final List<PresetLibraryEntry> _presetLibrary = DefaultPresetLibrary.all;

  List<LayerData> _layers = [
    LayerData(
      id: 'layer-1',
      name: 'Background',
      paintType: PaintType.solid,
      color: const Color(0xFF2196F3),
      blendMode: BlendModeType.normal,
    ),
    LayerData(
      id: 'layer-2',
      name: 'Gradient Overlay',
      paintType: PaintType.gradientLinear,
      color: Colors.purple,
      blendMode: BlendModeType.multiply,
      gradientStops: const [
        ColorStop(position: 0.0, color: Colors.purple),
        ColorStop(position: 1.0, color: Colors.blue),
      ],
      selectedStopIndex: 0,
      gradientAngle: 45.0,
      gradientOpacity: 0.7,
    ),
    LayerData(
      id: 'layer-3',
      name: 'Accent Color',
      paintType: PaintType.solid,
      color: const Color(0xFFFF5722),
      blendMode: BlendModeType.screen,
      visible: true,
    ),
  ];

  void _onLayersChanged(List<LayerData> updated) {
    setState(() => _layers = updated);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Layer list
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Layer Management',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SoftSaaSTokens.primaryText(brightness),
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayersList(
                    layers: _layers,
                    onLayersChanged: _onLayersChanged,
                    selectedIndex: _selectedLayerIndex,
                    onLayerSelected: (i) {
                      setState(() => _selectedLayerIndex = i);
                    },
                    enableReorder: true,
                    enableVisibility: true,
                    enableColorPicker: true,
                    enableSelection: true,
                    showRecentColors: true,
                    presets: _presets,
                    presetLibrary: _presetLibrary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Preview
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Preview',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SoftSaaSTokens.primaryText(brightness),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: LayersPreview(
                      layers: _layers,
                      size: 160,
                      borderRadius: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
