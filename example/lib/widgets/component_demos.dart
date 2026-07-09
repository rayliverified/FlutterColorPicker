import 'package:colorpicker/colorpicker.dart';
import 'package:flutter/material.dart';

/// Color tile (swatch) demonstration.
class ColorFieldSection extends StatelessWidget {
  const ColorFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 60),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ColorTile(color: Colors.red, size: 50),
            const SizedBox(width: 8),
            ColorTile(color: Colors.green, size: 50),
            const SizedBox(width: 8),
            ColorTile(color: Colors.blue, size: 50),
            const SizedBox(width: 8),
            ColorTile(
              color: Colors.yellow.withValues(alpha: 0.5),
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}

/// Hex input demonstration.
class HexInputSection extends StatelessWidget {
  const HexInputSection({
    super.key,
    required this.color,
    required this.onChanged,
  });

  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ColorHexInput(
          color: color,
          allowAlpha: false,
          onColorChanged: onChanged,
        ),
        const SizedBox(height: 12),
        ColorHexInput(
          color: color,
          allowAlpha: true,
          onColorChanged: onChanged,
        ),
      ],
    );
  }
}

/// Alpha input demonstration.
class AlphaInputSection extends StatelessWidget {
  const AlphaInputSection({
    super.key,
    required this.color,
    required this.onChanged,
  });

  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GradientAlphaInput(
        color: color,
        onValueUpdate: onChanged,
        onDragUpdate: onChanged,
        onDragEnd: () {},
      ),
    );
  }
}

/// Palette standalone demonstration.
class PaletteSection extends StatefulWidget {
  const PaletteSection({
    super.key,
    required this.paletteColor,
    required this.onChanged,
  });

  final Color paletteColor;
  final ValueChanged<Color> onChanged;

  @override
  State<PaletteSection> createState() => _PaletteSectionState();
}

class _PaletteSectionState extends State<PaletteSection> {
  late Offset _palettePosition;
  late Color _baseColor;

  @override
  void initState() {
    super.initState();
    _baseColor = widget.paletteColor;
    _palettePosition = Palette.getPosition(widget.paletteColor);
  }

  @override
  void didUpdateWidget(PaletteSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paletteColor != oldWidget.paletteColor) {
      final currentColor = Palette.getColor(_baseColor, _palettePosition);
      final colorDiff =
          (widget.paletteColor.toARGB32() - currentColor.toARGB32()).abs();
      if (colorDiff > 100) {
        _baseColor = widget.paletteColor;
        _palettePosition = Palette.getPosition(widget.paletteColor);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Palette(
        baseColor: _baseColor,
        position: _palettePosition,
        onPanStart: () {},
        onPositionChanged: (Offset position, Color color) {
          setState(() => _palettePosition = position);
          widget.onChanged(color);
        },
        onPanEnd: (Color previous, Color updated) {},
        thumbSize: 15,
      ),
    );
  }
}

/// Rainbow slider demonstration.
class RainbowSliderSection extends StatelessWidget {
  const RainbowSliderSection({
    super.key,
    required this.rainbowPosition,
    required this.onPositionChanged,
  });

  final double rainbowPosition;
  final ColorPositionChanged<double> onPositionChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 15,
      child: RainbowSlider(
        position: rainbowPosition,
        trackHeight: 15,
        onPanStart: (Color previous, Color updated) {},
        onPositionChanged: onPositionChanged,
        onPanEnd: (Color previous, Color updated) {},
      ),
    );
  }
}

/// Alpha slider demonstration.
class AlphaSliderSection extends StatelessWidget {
  const AlphaSliderSection({
    super.key,
    required this.color,
    required this.onChanged,
  });

  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 15,
      child: AlphaSlider(
        color: color,
        trackHeight: 15,
        onValueUpdate: (double opacity) {
          onChanged(color.withValues(alpha: opacity));
        },
        onDragEnd: (double opacity, double _) {},
      ),
    );
  }
}

/// Recent colors view demonstration.
class RecentColorsSection extends StatelessWidget {
  const RecentColorsSection({
    super.key,
    required this.swatches,
    required this.onSelected,
  });

  final List<PaintSwatch> swatches;
  final ValueChanged<PaintSwatch> onSelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 60),
      child: SizedBox(
        width: double.infinity,
        child: RecentColorsView(swatches: swatches, onSelected: onSelected),
      ),
    );
  }
}

/// Color presets view demonstration.
class ColorPresetsSection extends StatelessWidget {
  const ColorPresetsSection({
    super.key,
    required this.presets,
    required this.currentColor,
    required this.onSelected,
  });

  final List<ColorPreset> presets;
  final Color currentColor;
  final ValueChanged<PaintSwatch> onSelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 60),
      child: SizedBox(
        width: double.infinity,
        child: ColorPresetsView(
          presets: presets,
          currentSwatch: PaintSwatch.fromColor(currentColor),
          onSelected: onSelected,
        ),
      ),
    );
  }
}
