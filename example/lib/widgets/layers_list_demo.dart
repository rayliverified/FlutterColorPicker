import 'package:color_picker_plus/color_picker_plus.dart';
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
      name: 'Ocean Base',
      paintType: PaintType.solid,
      color: const Color(0xD91E40AF),
      blendMode: BlendModeType.normal,
    ),
    LayerData(
      id: 'layer-2',
      name: 'Sunset Wash',
      paintType: PaintType.gradientLinear,
      color: const Color(0xFFFFB000),
      blendMode: BlendModeType.normal,
      gradientStops: const [
        ColorStop(position: 0.0, color: Color(0xFFFFB000)),
        ColorStop(position: 0.52, color: Color(0xFFFF3D81)),
        ColorStop(position: 1.0, color: Color(0xFF7C3AED)),
      ],
      selectedStopIndex: 0,
      gradientAngle: 35.0,
      gradientOpacity: 0.78,
    ),
    LayerData(
      id: 'layer-3',
      name: 'Mint Accent',
      paintType: PaintType.solid,
      color: const Color(0xCC00E5A8),
      blendMode: BlendModeType.normal,
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
            // Preview
            SizedBox(width: 128, child: _LayerPreviewCard(layers: _layers)),
            const SizedBox(width: 0),
            // Layer list
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Layer Management',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
                      color: SoftSaaSTokens.primaryText(brightness),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                    decoration: BoxDecoration(
                      color: SoftSaaSTokens.primaryBackground(brightness),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: SoftSaaSTokens.primaryBorder(brightness),
                      ),
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

class _LayerPreviewCard extends StatelessWidget {
  const _LayerPreviewCard({required this.layers});

  final List<LayerData> layers;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Preview',
          style: TextStyle(
            fontSize: 12,
            height: 1.0,
            fontWeight: FontWeight.w600,
            color: SoftSaaSTokens.primaryText(brightness),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 112,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SoftSaaSTokens.secondaryBackground(brightness),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayersPreview(layers: layers, size: 96, borderRadius: 8),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${layers.length} layers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.0,
                    fontWeight: FontWeight.w500,
                    color: SoftSaaSTokens.secondaryText(brightness),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
