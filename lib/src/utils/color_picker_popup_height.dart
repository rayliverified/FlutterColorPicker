import '../models/paint_data.dart' as paint_model;
import '../models/paint_swatch.dart';
import '../widgets/color_picker.dart';

/// Calculates the default popup height from the widget layouts that compose a
/// [ColorPickerPanel].
///
/// The constants below mirror the source widgets instead of compensating after
/// the fact:
/// - panel header padding + 24px controls + divider
/// - baked rendered height of the color input widgets plus their outer padding
/// - palette and slider dimensions from [ColorPicker]
/// - [RecentColorsView] and [ColorPresetsView] padding, label, gap, tile, and
///   wrap spacing values
class ColorPickerPopupHeight {
  const ColorPickerPopupHeight._();

  // ColorPickerPanel header: top/bottom padding (4 + 4), 24px buttons, divider.
  static const double panelHeaderHeight = 33.0;

  // ColorPicker toolbar: baked Windows desktop rendered ColorHexInput /
  // GradientAlphaInput height (label + label gap + input field) plus
  // ColorPicker inputsPadding vertical.
  static const double inputControlsHeight = 49.0;
  static const double inputRowVerticalPadding = 16.0;
  static const double inputRowHeight =
      inputControlsHeight + inputRowVerticalPadding;

  // ColorPicker palette and slider stack.
  static const double solidPaletteHeight = 200.0;
  static const double gradientStopPaletteHeight = 210.0;
  static const double sliderPaddingBeforeHue = 12.0;
  static const double hueSliderHeight = 15.0;
  static const double sliderGap = 12.0;
  static const double alphaSliderHeight = 15.0;
  static const double sliderStackHeight =
      sliderPaddingBeforeHue + hueSliderHeight + sliderGap + alphaSliderHeight;

  // GradientEditor: stop bar plus angle/global-opacity controls row.
  static const double gradientBarWithStopsHeight = 70.0;
  static const double gradientControlsRowHeight = inputControlsHeight;

  // ColorPickerPanel spacing before RecentColorsView.
  static const double recentSectionLeadIn = 8.0;

  // RecentColorsView / ColorPresetsView layout values.
  static const double sectionHorizontalPadding = 12.0;
  static const double sectionLabelHeight = 13.0;
  static const double presetDropdownLabelHeight = 20.0;
  static const double labelToGridGap = 8.0;
  static const double tileSize = 20.0;
  static const double tileSpacing = 5.0;

  static const double recentTopPadding = 8.0;
  static const double recentBottomPadding = 8.0;
  static const double presetsTopPadding = 8.0;
  static const double presetsTopPaddingAfterRecents = 4.0;
  static const double presetsBottomPadding = 8.0;

  // The editor needs the same lower breathing room that recents/presets provide
  // through their component bottom padding when they are present.
  static const double editorOnlyBottomPadding = 8.0;

  static const int recentMaxItems = 18;

  static double editorHeightFor(PaintType paintType) {
    final isGradientMode =
        paintType == PaintType.gradientLinear ||
        paintType == PaintType.gradientRadial ||
        paintType == PaintType.gradientAngular;

    if (!isGradientMode) {
      return inputRowHeight + solidPaletteHeight + sliderStackHeight;
    }

    return gradientBarWithStopsHeight +
        gradientControlsRowHeight +
        inputRowHeight +
        gradientStopPaletteHeight +
        sliderStackHeight;
  }

  static double estimate({
    required double popupWidth,
    required paint_model.PaintData paint,
    required bool showRecentColors,
    required List<PaintSwatch>? recentSwatches,
    required bool showPresets,
    required int presetCount,
    required bool readOnly,
    bool hasCreatePresetButton = false,
    bool usesPresetLibraryDropdown = false,
    double minHeight = 200.0,
    double maxHeight = 650.0,
  }) {
    final recentCount = _recentItemCount(
      showRecentColors: showRecentColors,
      recentSwatches: recentSwatches,
      readOnly: readOnly,
    );

    final recentHeight = _recentColorsHeight(
      popupWidth: popupWidth,
      itemCount: recentCount,
    );
    final presetsHeight = _presetsHeight(
      popupWidth: popupWidth,
      showPresets: showPresets,
      itemCount: presetCount + (hasCreatePresetButton && !readOnly ? 1 : 0),
      hasRecentColors: recentCount > 0,
      usesPresetLibraryDropdown: usesPresetLibraryDropdown,
    );
    final bottomPadding = recentHeight == 0.0 && presetsHeight == 0.0
        ? editorOnlyBottomPadding
        : 0.0;

    final height =
        panelHeaderHeight +
        editorHeightFor(paint.type) +
        recentHeight +
        presetsHeight +
        bottomPadding;

    return height.clamp(minHeight, maxHeight);
  }

  static int _recentItemCount({
    required bool showRecentColors,
    required List<PaintSwatch>? recentSwatches,
    required bool readOnly,
  }) {
    if (!showRecentColors || recentSwatches == null) return 0;
    return recentSwatches.take(recentMaxItems).length + (readOnly ? 0 : 1);
  }

  static double _recentColorsHeight({
    required double popupWidth,
    required int itemCount,
  }) {
    if (itemCount <= 0) return 0.0;

    return recentSectionLeadIn +
        recentTopPadding +
        recentBottomPadding +
        sectionLabelHeight +
        labelToGridGap +
        _swatchGridHeight(popupWidth: popupWidth, itemCount: itemCount);
  }

  static double _presetsHeight({
    required double popupWidth,
    required bool showPresets,
    required int itemCount,
    required bool hasRecentColors,
    required bool usesPresetLibraryDropdown,
  }) {
    if (!showPresets || itemCount <= 0) return 0.0;

    return (hasRecentColors
            ? presetsTopPaddingAfterRecents
            : presetsTopPadding) +
        presetsBottomPadding +
        (usesPresetLibraryDropdown
            ? presetDropdownLabelHeight
            : sectionLabelHeight) +
        labelToGridGap +
        _swatchGridHeight(popupWidth: popupWidth, itemCount: itemCount);
  }

  static double _swatchGridHeight({
    required double popupWidth,
    required int itemCount,
  }) {
    if (itemCount <= 0) return 0.0;

    final availableWidth = popupWidth - (sectionHorizontalPadding * 2);
    final columns = ((availableWidth + tileSpacing) / (tileSize + tileSpacing))
        .floor()
        .clamp(1, itemCount)
        .toInt();
    final rows = (itemCount / columns).ceil();

    return rows * tileSize + (rows - 1) * tileSpacing;
  }
}
