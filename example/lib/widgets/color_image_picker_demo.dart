import 'dart:typed_data';

import 'package:colorpicker/colorpicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Combined Color and Image Picker widget.
///
/// This demonstrates switching between color picker and image picker modes,
/// similar to how the editor handles paint type switching.
class ColorImagePickerDemo extends StatefulWidget {
  final Color selectedColor;
  final Uint8List? selectedImageBytes;
  final String? selectedImageName;
  final List<PaintSwatch> recentSwatches;
  final List<ColorPreset> presets;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged2<Uint8List, String> onImageSelected;
  final ValueChanged<PaintSwatch> onRecentSwatchAdd;

  const ColorImagePickerDemo({
    super.key,
    required this.selectedColor,
    this.selectedImageBytes,
    this.selectedImageName,
    required this.recentSwatches,
    required this.presets,
    required this.onColorChanged,
    required this.onImageSelected,
    required this.onRecentSwatchAdd,
  });

  @override
  State<ColorImagePickerDemo> createState() => _ColorImagePickerDemoState();
}

class _ColorImagePickerDemoState extends State<ColorImagePickerDemo> {
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final name = result.files.single.name;

        widget.onImageSelected(bytes, name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: SingleChildScrollView(
        child: ColorPickerPanel(
          color: widget.selectedColor,
          onColorChanged: widget.onColorChanged,
          onColorChangeStart: () {},
          onColorChangeEnd: () {},
          recentSwatches: widget.recentSwatches,
          onRecentSwatchAdd: widget.onRecentSwatchAdd,
          presets: widget.presets,
          showPresetLibrary: widget.presets.isNotEmpty,
          presetLibrary: widget.presets.isNotEmpty
              ? [
                  PresetLibraryEntry.fromColors(
                    name: 'Presets',
                    colors: widget.presets.map((p) => p.swatch.color).toList(),
                  ),
                ]
              : null,
          showBlendMode: true,
          blendMode: BlendModeType.normal,
          onBlendModeChanged: (BlendModeType mode) {
            // Handle blend mode change
          },
          showPageSwitcher: true,
          paletteHeight: 300,
          inputsPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          slidersPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
          onPaintTypeChanged: (PaintType type) {
            // Handle paint type change (e.g., switch to image picker)
            if (type == PaintType.image) {
              _pickImage();
            }
          },
        ),
      ),
    );
  }
}

/// Helper typedef for callback with two values.
typedef ValueChanged2<T1, T2> = void Function(T1 value1, T2 value2);
