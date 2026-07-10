---
format: api_reference
version: 1
---

# API Reference

# FlutterColorPicker — `color_picker_plus`

A full-featured Flutter color picker package providing solid colors, gradients (linear, radial, angular), blend modes, multi-layer paint management, recent color persistence, and preset libraries.

---

## Setup

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  color_picker_plus: ^1.0.0
```

The package requires Dart `>=3.8.0 <4.0.0` and Flutter `>=3.32.0`. Its only runtime dependency is `shared_preferences` (for recent color persistence).

Then import the library. All three entry points export the same public API surface:

```dart
import 'package:color_picker_plus/color_picker_plus.dart';
// or equivalently:
// import 'package:color_picker_plus/color_picker.dart';
// import 'package:color_picker_plus/colorpicker.dart';
```

### Simple Color Picking (Solid Colors)

For the majority of use cases where only a solid color is needed, use the `color` parameter on any widget:

```dart
// Inline row with swatch + hex input + opacity
ColorPickerRow(
  color: selectedColor,
  onColorChanged: (color) => setState(() => selectedColor = color),
)

// Clickable swatch that opens a popup
ColorPickerTrigger(
  color: selectedColor,
  onPaintChanged: (paint) => setState(() => selectedColor = paint.color),
)

// Full panel embedded in your layout
ColorPickerPanel(
  color: selectedColor,
  onColorChanged: (color) => setState(() => selectedColor = color),
)

// Modal dialog
final color = await showColorPickerDialog(
  context: context,
  initialColor: Colors.blue,
  title: 'Pick a color',
);
```

### Advanced Setup (Gradients, Blend Modes, Paint Model)

For full control including gradient editing, blend mode selection, and the unified `PaintData` model, use the `paint` parameter:

```dart
// Create a paint with gradient support
PaintData myPaint = PaintData.linearGradient(
  stops: [
    ColorStop(position: 0.0, color: Colors.red),
    ColorStop(position: 1.0, color: Colors.blue),
  ],
  angle: 45,
  blendMode: BlendModeType.multiply,
);

// Use the paint-based API
ColorPickerTrigger(
  paint: myPaint,
  onPaintChanged: (paint) => setState(() => myPaint = paint),
  showBlendMode: true,
  showPageSwitcher: true,
)
```

### Recent Colors & Preset Library

Recent colors are automatically persisted via SharedPreferences. `ColorPickerTrigger` and `showColorPickerDialog` auto-load recent colors from the shared singleton without any additional setup:

```dart
// Recent colors auto-load — no setup needed for ColorPickerTrigger or dialog.
// For manual control, use RecentColorsManager:

class _MyWidgetState extends State<MyWidget> {
  late final RecentColorsManager _recentColorsManager;

  @override
  void initState() {
    super.initState();
    _recentColorsManager = RecentColorsManager.shared;
    _recentColorsManager.addListener(() { if (mounted) setState(() {}); });
    _recentColorsManager.loadRecentColors();
  }

  @override
  void dispose() {
    _recentColorsManager.removeListener(() { if (mounted) setState(() {}); });
    super.dispose();
  }
}
```

### Available Preset Libraries

The package ships with 11 curated preset libraries. Access them via `DefaultPresetLibrary`:

```dart
DefaultPresetLibrary.all                // All libraries as a list
DefaultPresetLibrary.getByName('Tailwind') // Specific library
DefaultPresetLibrary.getSwatches('Material 3') // Just the swatches

// Available: Codelessly, Material 3, iOS, Google, Discord,
//            GitHub, VS Code, Storybook, Slack, Tailwind
```

### Read-Only Mode

All major widgets support a `readOnly` flag that disables all interactive controls and displays values as static text:

```dart
ColorPickerRow(color: myColor, readOnly: true)
ColorPickerTrigger(color: myColor, onPaintChanged: null, readOnly: true)
```

---

## Usage Examples

> Full lifecycle setup (state management, RecentColorsManager initialization) is shown in Example 1. All subsequent examples assume that context.

### Example 1 — ColorPickerRow with Inline Inputs

```dart
class _ColorRowDemoState extends State<_ColorRowDemo> {
  Color _color = const Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return ColorPickerRow(
      color: _color,
      onColorChanged: (color) => setState(() => _color = color),
      showOpacity: true,
      showRGB: true,
      showLabels: true,
      showOutline: true,
      showRecentColors: true,
      showPresetLibrary: true,
    );
  }
}
```

Inline editor with swatch, hex, RGB, alpha, and opacity inputs. Clicking the swatch opens the full popup picker. Labels and outline borders are optional visual enhancements.

### Example 2 — ColorPickerTrigger Popup with Advanced Features

```dart
PaintData _paint = PaintData.linearGradient(
  stops: [
    ColorStop(position: 0.0, color: Colors.purple),
    ColorStop(position: 1.0, color: Colors.blue),
  ],
  angle: 45,
);

ColorPickerTrigger(
  paint: _paint,
  onPaintChanged: (paint) => setState(() => _paint = paint),
  showBlendMode: true,
  showPageSwitcher: true,
  popupWidth: 320,
  maxHeight: 700,
)
```

Opens a popup with gradient editor, blend mode dropdown, and library/editor page switcher. The popup is draggable and resizable.

### Example 3 — Modal Dialog

```dart
final Color? result = await showColorPickerDialog(
  context: context,
  initialColor: Colors.blue,
  title: 'Select Color',
  showRecentColors: true,
  showPresets: true,
  showPresetLibrary: true,
  allowOpacity: true,
);

if (result != null) {
  setState(() => selectedColor = result);
}
```

Convenience function wrapping `ColorPickerDialog` in `showDialog`. Returns `null` on cancel. Auto-saves to recent colors on confirm.

### Example 4 — Multi-Layer Paint Management

```dart
List<LayerData> layers = [
  LayerData(
    id: 'bg', name: 'Background',
    paintType: PaintType.solid, color: Colors.blue,
    blendMode: BlendModeType.normal,
  ),
  LayerData(
    id: 'gradient', name: 'Gradient Overlay',
    paintType: PaintType.gradientLinear, color: Colors.purple,
    blendMode: BlendModeType.multiply,
    gradientStops: [
      ColorStop(position: 0.0, color: Colors.purple),
      ColorStop(position: 1.0, color: Colors.blue),
    ],
    gradientAngle: 45,
  ),
];
int? selectedIndex;

LayersList(
  layers: layers,
  onLayersChanged: (updated) => setState(() => layers = updated),
  selectedIndex: selectedIndex,
  onLayerSelected: (index) => setState(() => selectedIndex = index),
  enableReorder: true,
  enableVisibility: true,
  enableColorPicker: true,
)
```

Drag-to-reorder layers, toggle visibility, and click any layer's swatch to open the full gradient-aware picker with blend mode support.

### Example 5 — Composited Layers Preview

```dart
LayersPreview(
  layers: layers,
  size: 200,
  borderRadius: 8,
)
```

Renders all visible layers composited with their blend modes applied, showing the final visual result.

### Example 6 — Gradient Stop Editor with ColorPickerPanel

```dart
ColorPickerPanel(
  paintType: PaintType.gradientLinear,
  onPaintTypeChanged: (type) => setState(() => _paintType = type),
  gradientStops: _gradientStops,
  onGradientStopsChanged: (stops) => setState(() => _gradientStops = stops),
  selectedStopIndex: _selectedStopIndex,
  onStopSelected: (index) => setState(() => _selectedStopIndex = index),
  gradientAngle: _angle,
  onGradientAngleChanged: (angle) => setState(() => _angle = angle),
  gradientOpacity: _opacity,
  onGradientOpacityChanged: (opacity) => setState(() => _opacity = opacity),
  color: _currentColor,
  onColorChanged: (color) => setState(() => _currentColor = color),
  showBlendMode: true,
  blendMode: _blendMode,
  onBlendModeChanged: (mode) => setState(() => _blendMode = mode),
  showPageSwitcher: true,
  presetLibrary: DefaultPresetLibrary.all,
  maxWidth: 320,
)
```

Full gradient editing panel with stop manipulation, angle dialer, global opacity, blend mode, and preset library switching.

### Example 7 — Standalone Gradient Stops List

```dart
GradientStopsList(
  stops: _gradientStops,
  selectedStopIndex: _selectedStopIndex,
  onStopsChanged: (stops) => setState(() => _gradientStops = stops),
  onStopSelected: (index) => setState(() => _selectedStopIndex = index),
)
```

Inspector-style list for selecting, adding, deleting, and editing gradient stop positions and colors inline.

### Example 8 — Individual Primitives (Palette, Sliders, Hex Input)

```dart
Column(
  children: [
    Palette(
      baseColor: rainbowColor,
      position: Offset(0.5, 0.5),
      onPanStart: () {},
      onPositionChanged: (pos, color) => setState(() => _color = color),
      onPanEnd: (prev, curr) {},
    ),
    RainbowSlider(
      position: 3.0,
      onPanStart: (prev, curr) {},
      onPositionChanged: (pos, color) => setState(() { rainbowColor = color; }),
      onPanEnd: (prev, curr) {},
    ),
    AlphaSlider(
      alpha: _color.a,
      color: _color,
      onValueUpdate: (alpha) => setState(() => _color = _color.withValues(alpha: alpha)),
      onDragEnd: (prev, curr) {},
    ),
    ColorHexInput(
      color: _color,
      onColorChanged: (color) => setState(() => _color = color),
      allowAlpha: true,
    ),
    GradientAlphaInput(
      color: _color,
      onValueUpdate: (color) => setState(() => _color = color),
      label: 'Opacity',
    ),
  ],
)
```

Mix and match low-level building blocks for completely custom layouts. `Palette` is the 2D saturation/brightness selector, `RainbowSlider` selects hue, `AlphaSlider` controls opacity with a checkerboard background, and text inputs provide direct numeric entry.

### Example 9 — Angle Input Dialer

```dart
GradientRotationInput(
  rotation: 45.0,
  onValueUpdated: (angle) => setState(() => _angle = angle),
  onDragUpdate: (angle) => setState(() => _angle = angle),
  onDragEnd: () {},
  readOnly: false,
)
```

Visual circular dialer with numeric input for setting gradient rotation angle. Supports both drag-to-adjust and direct typing.

### Example 10 — Custom Child on ColorPickerTrigger

```dart
ColorPickerTrigger(
  color: selectedColor,
  onPaintChanged: (paint) => setState(() => selectedColor = paint.color),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: selectedColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.color_lens, color: Colors.white),
        const SizedBox(width: 8),
        Text('Pick Color', style: TextStyle(color: Colors.white)),
      ],
    ),
  ),
)
```

When `child` is provided, the built-in color swatch is replaced with the custom widget as the tap target.

---

## Reference

### PaintData

Unified, immutable paint model with value equality. Represents solid colors and all gradient types with a single object.

**Named Constructors:** `PaintData.solid({required Color color, BlendModeType? blendMode})`, `PaintData.gradient({required PaintType type, required List<ColorStop> stops, ...})`, `PaintData.linearGradient({required List<ColorStop> stops, double? angle, ...})`, `PaintData.radialGradient({required List<ColorStop> stops, ...})`, `PaintData.angularGradient({required List<ColorStop> stops, double? angle, ...})`

**Factories:** `PaintData.fromJson(Map<String, dynamic> json)`

| Member | Description |
|--------|-------------|
| `final PaintType type` | Paint type (solid or gradient variant). |
| `final Color color` | Primary color for solid paints, or first stop color for gradients. |
| `final List<ColorStop>? gradientStops` | Gradient stops (null for solid). |
| `final int? selectedStopIndex` | Currently selected gradient stop index. |
| `final double? gradientAngle` | Gradient angle in degrees (linear/angular). |
| `final double? gradientOpacity` | Global opacity for gradients (0.0–1.0). |
| `final BlendModeType? blendMode` | Blend mode for compositing. |
| `bool get isSolid` | Whether this is a solid color paint. |
| `bool get isGradient` | Whether this is a gradient paint. |
| `bool get isImage` | Whether this is an image paint. |
| `Color get effectiveColor` | Primary color with gradient opacity applied. |
| `PaintData copyWith({PaintType? type, Color? color, List<ColorStop>? gradientStops, int? selectedStopIndex, double? gradientAngle, double? gradientOpacity, BlendModeType? blendMode})` | Immutable copy with replaced fields. |
| `Map<String, dynamic> toJson()` | Serialize to JSON. |
| `factory PaintData.fromJson(Map<String, dynamic> json)` | Deserialize from JSON. |

### PaintState

Backward-compatibility wrapper around `PaintData`. New code should use `PaintData` directly.

**Constructors:** `PaintState({required Color color, required PaintType paintType, BlendModeType? blendMode, ...})`, `PaintState.fromPaint(PaintData paint)`

| Member | Description |
|--------|-------------|
| `final PaintData paint` | The underlying paint object. |
| `Color get color` | Delegates to `paint.color`. |
| `PaintType get paintType` | Delegates to `paint.type`. |
| `BlendModeType? get blendMode` | Delegates to `paint.blendMode`. |
| `List<ColorStop>? get gradientStops` | Delegates to `paint.gradientStops`. |
| `int? get selectedStopIndex` | Delegates to `paint.selectedStopIndex`. |
| `double? get gradientAngle` | Delegates to `paint.gradientAngle`. |
| `double? get gradientOpacity` | Delegates to `paint.gradientOpacity`. |
| `bool get isGradientMode` | Whether paint type is a gradient. |
| `PaintData toPaint()` | Converts to underlying `PaintData`. |
| `bool didChange(PaintState? other)` | Checks if state differs from another. |
| `PaintState copyWith({...})` | Immutable copy. |
| Supports `operator ==`, `hashCode` via `PaintData`. | |

### LayerData

Data model for a paint layer with color, blend mode, paint type, and optional image data. Used by `LayersList` and `LayerInfoPanel`.

**Constructors:** `LayerData({required String id, required String name, required PaintType paintType, required Color color, required BlendModeType blendMode, ...})`

| Member | Description |
|--------|-------------|
| `final String id` | Unique identifier. |
| `final String name` | Display name. |
| `final PaintType paintType` | Paint type for the layer. |
| `final Color color` | Primary color. |
| `final BlendModeType blendMode` | Compositing blend mode. |
| `final Uint8List? imageBytes` | Image bytes for image paint type. |
| `final String? imageName` | Image filename. |
| `final bool visible` | Layer visibility (default `true`). |
| `final List<ColorStop>? gradientStops` | Gradient stops for gradient types. |
| `final int? selectedStopIndex` | Selected gradient stop index. |
| `final double? gradientAngle` | Gradient angle in degrees. |
| `final double? gradientOpacity` | Global gradient opacity. |
| `LayerData copyWith({...})` | Immutable copy. |
| `PaintData toPaint()` | Converts to `PaintData`. |
| `LayerData withPaint(PaintData paint)` | Creates new layer with paint properties merged in. |
| Supports `operator ==`, `hashCode`. | |

### ColorStop

Position-color pair defining a gradient stop.

**Constructors:** `ColorStop({required double position, required Color color})`

| Member | Description |
|--------|-------------|
| `final double position` | Position along gradient axis (0.0–1.0). |
| `final Color color` | Color at this position. |
| `ColorStop copyWith({double? position, Color? color})` | Immutable copy. |
| Supports `operator ==`, `hashCode`. | |

### BlendModeType

Enum with 30 values mapping to Flutter's `BlendMode` with human-readable labels.

| Member | Description |
|--------|-------------|
| `String get label` | Human-readable label (e.g., `'Multiply'`). |
| `BlendMode get flutterBlendMode` | Converts to Flutter `BlendMode`. |

Values: `normal`, `multiply`, `screen`, `overlay`, `darken`, `lighten`, `colorDodge`, `colorBurn`, `hardLight`, `softLight`, `difference`, `exclusion`, `hue`, `saturation`, `color`, `luminosity`, `clear`, `src`, `dst`, `srcOver`, `dstOver`, `srcIn`, `dstIn`, `srcOut`, `dstOut`, `srcATop`, `dstATop`, `xor`, `plus`, `modulate`.

### PaintType

Enum for paint type selection. Defined inside `color_picker.dart`.

| Member | Description |
|--------|-------------|
| `String get prettify` | Display label: `'Solid'`, `'Linear'`, `'Radial'`, `'Angular'`, `'Image'`. |

Values: `solid`, `gradientLinear`, `gradientRadial`, `gradientAngular`, `image`.

### PaintSwatch

Display wrapper for `PaintData` with optional label. Used in recent colors, presets, and libraries.

**Constructors:** `PaintSwatch(PaintData paint, {String? label})`, `PaintSwatch.solid({required Color color, String? label})`, `PaintSwatch.gradient({required PaintType paintType, required List<ColorStop> gradientStrokes, ...})`

**Factories:** `PaintSwatch.fromColor(Color color, {String? label})`, `PaintSwatch.fromGradient({...})`, `PaintSwatch.fromPaint(PaintData paint, {String? label})`

| Member | Description |
|--------|-------------|
| `final PaintData paint` | Underlying paint object. |
| `final String? label` | Optional label. |
| `PaintType get paintType` | Delegates to `paint.type`. |
| `Color get color` | Delegates to `paint.color`. |
| `List<ColorStop>? get gradientStops` | Delegates to `paint.gradientStops`. |
| `double? get gradientAngle` | Delegates to `paint.gradientAngle`. |
| `double? get gradientOpacity` | Delegates to `paint.gradientOpacity`. |
| `bool get isSolid` | Whether paint is solid. |
| `bool get isGradient` | Whether paint is gradient. |
| `PaintSwatch copyWith({PaintData? paint, String? label})` | Immutable copy. |
| Supports `operator ==`, `hashCode`. | |

### ColorPreset & PresetLibraryEntry

Preset configuration types defined in `recent_colors_view.dart`.

`ColorPreset` wraps a `PaintSwatch` with optional label.

**Factories:** `ColorPreset.solid({required Color color, String? label})`, `ColorPreset.gradient({required PaintSwatch swatch, String? label})`

`PresetLibraryEntry` represents a named collection of swatches.

**Constructors:** `PresetLibraryEntry({required String name, required List<PaintSwatch> swatches})`, `PresetLibraryEntry.fromColors({required String name, required List<Color> colors})`

### ColorPicker (Core Widget)

Full-featured color picker with title bar, 2D palette, hue/alpha sliders, hex input, and optional recent colors and presets.

**Constructors:** `ColorPicker({required ValueChanged<Color> onColorChanged, Color color, ...})`

| Member | Description |
|--------|-------------|
| `final Color color` | Initial/current color. |
| `final ValueChanged<Color> onColorChanged` | Called on color change during drag. |
| `final VoidCallback? onColorChangeStart` | Called when interaction starts. |
| `final VoidCallback? onColorChangeEnd` | Called when interaction finishes. |
| `final ValueChanged<Offset>? onPalettePositionChanged` | Called on palette position change. |
| `final bool allowOpacity` | Enable opacity controls (default `true`). |
| `final EdgeInsets? inputsPadding` | Padding around hex/alpha inputs. |
| `final EdgeInsets? slidersPadding` | Padding around sliders. |
| `final double? paletteHeight` | Fixed palette height (null = expand). |
| `final bool readOnly` | Disable all interaction. |
| `final Duration? throttleDuration` | Throttle for `onColorChanged`. |
| `final bool showRecentColors` | Show recent colors section. |
| `final List<PaintSwatch>? recentSwatches` | Recent paint swatches. |
| `final ValueChanged<PaintSwatch>? onRecentSwatchAdd` | Called to add swatch to recent list. |
| `final bool showPresets` | Show presets section. |
| `final List<ColorPreset>? presets` | Custom preset colors. |
| `final VoidCallback? onCreatePreset` | Called to create a new preset. |
| `final bool showPresetLibrary` | Show preset library dropdown. |
| `final List<PresetLibraryEntry>? presetLibrary` | Preset library entries. |
| `final ValueChanged<Color>? onPresetLibrarySelected` | Called when library entry selected. |
| `final PaintType? paintType` | Current paint type. |
| `final ValueChanged<PaintType>? onPaintTypeChanged` | Called on paint type change. |
| `final List<PaintType> supportedTypes` | Supported paint types (default: all five). |
| `final bool showTitleBar` | Show title bar with dropdown. |
| `final bool showToolbar` | Show hex/opacity toolbar. |
| `final double? maxWidth` | Maximum width constraint (default `300`). |

### ColorPickerPanel

Full-featured panel with toolbar (mode dropdown, blend mode, close button) and scrollable editor content. Integrates gradient editor, recent colors, presets, and preset library.

**Constructors:** `ColorPickerPanel({required ValueChanged<Color> onColorChanged, Color color, ...})`

| Member | Description |
|--------|-------------|
| `final ValueChanged<Color> onColorChanged` | Called on color change. |
| `final VoidCallback? onColorChangeStart` / `onColorChangeEnd` | Interaction lifecycle. |
| `final bool allowOpacity` | Enable opacity controls. |
| `final EdgeInsets? inputsPadding` / `slidersPadding` / `contentPadding` | Padding overrides. |
| `final double? paletteHeight` | Fixed palette height. |
| `final bool readOnly` | Read-only mode. |
| `final double? maxWidth` | Max width (default `300`). |
| `final PaintType? paintType` / `onPaintTypeChanged` | Paint type control. |
| `final bool showBlendMode` / `BlendModeType? blendMode` / `onBlendModeChanged` | Blend mode controls. |
| `final bool showPageSwitcher` / `int initialPageIndex` / `onPageChanged` | Library/editor toggle. |
| `final bool showCloseButton` / `VoidCallback? onClose` | Close button. |
| `final String? title` | Header title text (overrides dropdown). |
| `final ValueChanged<Offset>? onHeaderDragStart` / `onHeaderDragUpdate` / `onHeaderDragEnd` | Draggable popup support. |
| `final bool showRecentColors` / `recentSwatches` / `onRecentSwatchAdd` / `onRecentSwatchSelected` | Recent colors. |
| `final bool showPresets` / `presets` / `onCreatePreset` | Presets. |
| `final bool showPresetLibrary` / `presetLibrary` / `onPresetLibrarySelected` | Preset library. |
| `final List<ColorStop>? gradientStops` / `onGradientStopsChanged` | Gradient stops. |
| `final int? selectedStopIndex` / `onStopSelected` | Stop selection. |
| `final double? gradientAngle` / `onGradientAngleChanged` | Gradient angle. |
| `final double? gradientOpacity` / `onGradientOpacityChanged` | Gradient opacity. |

### ColorPickerTrigger

Clickable swatch or custom child that opens a draggable, resizable popup with `ColorPickerPanel`.

**Constructors:** `ColorPickerTrigger({PaintData? paint, Color? color, Widget? child, ValueChanged<PaintData>? onPaintChanged, ...})`

| Member | Description |
|--------|-------------|
| `final PaintData? paint` / `final Color? color` | Current paint or color (one required). |
| `final Widget? child` | Custom tap target widget. |
| `final ValueChanged<PaintData>? onPaintChanged` | Unified callback for all changes. |
| `final VoidCallback? onPaintChangeStart` / `onPaintChangeEnd` | Interaction lifecycle. |
| `final double? size` | Swatch size (default `24`). |
| `final double borderRadius` / `borderWidth` | Swatch styling. |
| `final bool allowOpacity` | Enable opacity in picker. |
| `final bool showRecentColors` / `recentSwatches` / `onRecentSwatchAdd` / `onRecentSwatchSelected` | Recent colors. |
| `final bool showPresets` / `presets` / `onCreatePreset` | Presets. |
| `final bool showPresetLibrary` / `presetLibrary` / `onPresetLibrarySelected` | Preset library. |
| `final bool showBlendMode` | Show blend mode dropdown. |
| `final bool showPageSwitcher` | Show library/editor toggle. |
| `final Uint8List? imageBytes` / `String? imageName` / `onPickImage` / `onClearImage` / `imagePickerBuilder` | Image paint support. |
| `final bool readOnly` | Read-only mode. |
| `final double popupWidth` / `estimatedHeight` / `minHeight` / `maxHeight` | Popup sizing. |
| `final String? heightPersistenceKey` | Key for persisting popup height. |
| `final List<BoxShadow>? popupBoxShadow` | Custom popup shadow. |

### ColorPickerRow

Horizontal row with swatch and inline text inputs (hex, RGB, alpha, opacity). Best for forms and property panels.

**Constructors:** `ColorPickerRow({required Color color, ValueChanged<Color>? onColorChanged, ...})`

| Member | Description |
|--------|-------------|
| `final Color color` | Current color. |
| `final ValueChanged<Color>? onColorChanged` | Called on any input change. |
| `final VoidCallback? onColorChangeStart` / `onColorChangeEnd` | Interaction lifecycle. |
| `final bool showRGB` | Show R, G, B numeric inputs. |
| `final bool showAlpha` | Show alpha input (0–255). |
| `final bool showOpacity` | Show opacity percentage (0–100%). |
| `final bool showLabels` | Show labels above inputs. |
| `final bool showOutline` | Show visible borders. |
| `final double? swatchSize` / `swatchBorderRadius` | Swatch styling. |
| `final double spacing` | Element spacing. |
| `final bool readOnly` | Read-only mode. |
| `final bool allowOpacity` / `showRecentColors` / `showPresets` / `showPresetLibrary` | Popup picker options. |
| `final TextStyle? labelStyle` / `inputStyle` | Custom text styles. |
| `final double popupWidth` / `popupMinHeight` / `popupMaxHeight` | Popup sizing. |

### showColorPickerDialog / ColorPickerDialog

Convenience function and widget for modal color picker dialogs.

**Signature:** `Future<Color?> showColorPickerDialog({required BuildContext context, required Color initialColor, String title, bool allowOpacity, bool showRecentColors, bool showPresets, bool showPresetLibrary, List<ColorPreset>? presets, List<PresetLibraryEntry>? presetLibrary, List<PaintSwatch>? recentSwatches, ValueChanged<PaintSwatch>? onRecentSwatchAdd, VoidCallback? onCreatePreset, ValueChanged<Color>? onPresetLibrarySelected})`

`ColorPickerDialog` has the same parameters as the convenience function and uses `AlertDialog` with Cancel/OK buttons.

### LayersList

Multi-layer paint management with drag-to-reorder, visibility toggles, and inline color pickers.

**Constructors:** `LayersList({required List<LayerData> layers, required LayersChangedCallback onLayersChanged, ...})`

| Member | Description |
|--------|-------------|
| `final List<LayerData> layers` | Layers to display. |
| `final LayersChangedCallback onLayersChanged` | Consolidated callback returning full updated list. |
| `final int? selectedIndex` / `onLayerSelected` | Selection state and callback. |
| `final bool enableReorder` | Enable drag-to-reorder. |
| `final bool enableVisibility` | Show/hide toggle button. |
| `final bool enableColorPicker` | Inline color picker per layer. |
| `final bool enableSelection` | Selection highlighting. |
| `final bool showRecentColors` | Auto-managed recent colors. |
| `final List<ColorPreset>? presets` / `presetLibrary` | Color picker presets. |
| `final BoxDecoration? decoration` | Container decoration. |
| `final EdgeInsets itemPadding` | Per-item padding. |

### LayersPreview

Renders all visible layers composited with their blend modes.

**Constructors:** `LayersPreview({required List<LayerData> layers, double size, double borderRadius, double borderWidth})`

| Member | Description |
|--------|-------------|
| `final List<LayerData> layers` | Layers rendered bottom-to-top. |
| `final double size` | Preview size (square, default `200`). |
| `final double borderRadius` | Corner radius. |
| `final double borderWidth` | Border width. |

### LayerInfoPanel

Displays layer properties with interactive color picker.

**Constructors:** `LayerInfoPanel({required LayerData layer, ValueChanged<PaintData>? onPaintChanged, ...})`

| Member | Description |
|--------|-------------|
| `final LayerData layer` | Layer to display. |
| `final ValueChanged<PaintData>? onPaintChanged` | Called on paint change. |
| `final List<PaintSwatch>? recentSwatches` / `presets` / `onRecentSwatchAdd` | Color picker options. |
| `final BoxDecoration? decoration` / `padding` / `title` | Styling. |

### ColorPickerLayersControlPanel

Standalone toolbar with paint type dropdown, blend mode dropdown, and page switcher button.

**Constructors:** `ColorPickerLayersControlPanel({PaintType? paintType, ValueChanged<PaintType>? onPaintTypeChanged, ...})`

| Member | Description |
|--------|-------------|
| `final List<PaintType> supportedTypes` | Types shown in dropdown (default: all five). |
| `final bool showBlendMode` / `BlendModeType? blendMode` / `onBlendModeChanged` | Blend mode controls. |
| `final bool showPageSwitcher` / `int? currentPageIndex` / `onPageSwitcherTapped` | Page switcher. |
| `final bool readOnly` | Read-only mode. |
| `final EdgeInsets padding` | Control panel padding. |
| `final bool showDivider` | Divider below controls. |
| `Widget buildTitleWidget(BuildContext context)` | Build just the title row. |
| `List<Widget> buildActions(BuildContext context)` | Build just the actions row. |

### GradientEditor

Visual gradient stop editor with draggable stops, add/delete/copy, and angle/opacity controls.

**Constructors:** `GradientEditor({required List<ColorStop> stops, required GradientStopChangedCallback onStopsChanged, required int selectedStopIndex, ...})`

| Member | Description |
|--------|-------------|
| `final List<ColorStop> stops` | Current gradient stops. |
| `final GradientStopChangedCallback onStopsChanged` | Called when stops change. |
| `final int selectedStopIndex` / `onStopSelected` | Stop selection. |
| `final VoidCallback? onChangeStart` / `onChangeEnd` | Interaction lifecycle. |
| `final Widget? globalControls` / `stopControls` | Custom controls sections. |
| `final PaintType? paintType` | Determines if angle control shows. |
| `final double? gradientAngle` / `onGradientAngleChanged` / `onAngleChangeEnd` | Angle control. |
| `final double? gradientOpacity` / `onGradientOpacityChanged` | Global opacity. |
| `final bool readOnly` | Read-only mode. |
| `final double barHeight` / `EdgeInsets padding` | Styling. |

### GradientStopsList

Inspector-style editable list of gradient stops with inline hex input and position editing.

**Constructors:** `GradientStopsList({required List<ColorStop> stops, required int selectedStopIndex, required ValueChanged<List<ColorStop>> onStopsChanged, ...})`

| Member | Description |
|--------|-------------|
| `final ValueChanged<int>? onStopSelected` | Called when a stop row is selected. |
| `final bool readOnly` / `showTitle` | Display options. |
| `final EdgeInsets padding` | Outer padding. |

### GradientRotationInput & AngleInputDialer

Combined angle input widget with numeric field and circular dialer.

**GradientRotationInput constructors:** `GradientRotationInput({required double rotation, ValueChanged<double>? onValueUpdated, ValueChanged<double>? onDragUpdate, VoidCallback? onDragEnd, bool readOnly})`

**AngleInputDialer constructors:** `AngleInputDialer({required double value, ValueChanged<double>? onDragUpdate, VoidCallback? onDragEnd, double size, bool readOnly})`

### Palette

2D color picker for saturation (X) and brightness (Y) selection.

**Constructors:** `Palette({Color baseColor, Offset position, required ColorPositionChanged<Offset> onPositionChanged, required VoidCallback onPanStart, required Function(Color, Color) onPanEnd, double thumbSize, bool readOnly})`

| Member | Description |
|--------|-------------|
| `static Offset getPosition(Color color)` | Calculate palette position from color. |
| `static Color getColor(Color baseColor, Offset position)` | Calculate color from base and position. |

### RainbowSlider

Horizontal hue slider (0.0–6.0 range).

**Constructors:** `RainbowSlider({double position, double trackHeight, SliderComponentShape? thumbShape, required Function(Color, Color) onPanStart, required ColorPositionChanged<double> onPositionChanged, required Function(Color, Color) onPanEnd, bool readOnly})`

| Member | Description |
|--------|-------------|
| `static double getPosition(Color color)` | Calculate slider position from color. |
| `static Color getColor(double position)` | Calculate color from position. |

### AlphaSlider

Opacity slider with checkerboard background.

**Constructors:** `AlphaSlider({double alpha, Color color, double trackHeight, SliderComponentShape? thumbShape, required ValueChanged<double> onValueUpdate, required Function(double, double) onDragEnd, bool readOnly})`

### ColorHexInput

Hex color input with auto-formatting and validation.

**Constructors:** `ColorHexInput({Color color, ValueChanged<Color>? onColorChanged, ValueChanged<bool>? onFocusChanged, bool readOnly, TextStyle? textStyle, bool allowAlpha, bool showLabel, bool showOutline})`

### GradientAlphaInput

Opacity percentage input (0–100%) with horizontal drag support.

**Constructors:** `GradientAlphaInput({required Color color, ValueChanged<Color>? onValueUpdate, ValueChanged<Color>? onDragUpdate, VoidCallback? onDragEnd, bool readOnly, String label, TextAlign labelAlignment, FocusNode? focus, bool showLabel, bool showOutline})`

### RecentColorsView

Grid of recent color/gradient swatches with add button.

**Constructors:** `RecentColorsView({required List<PaintSwatch> swatches, required ValueChanged<PaintSwatch> onSelected, PaintSwatch? currentSwatch, ValueChanged<PaintSwatch>? onAddCurrent, bool readOnly, int maxItems, int crossAxisCount, double spacing, double tileSize, bool applyPadding, bool showLabel})`

### ColorPresetsView

Grid of preset swatches with optional preset library dropdown.

**Constructors:** `ColorPresetsView({required List<ColorPreset> presets, required ValueChanged<PaintSwatch> onSelected, PaintSwatch? currentSwatch, VoidCallback? onCreateNew, bool readOnly, int crossAxisCount, double spacing, double tileSize, List<PresetLibraryEntry>? presetLibrary, ValueChanged<PaintSwatch>? onPresetLibrarySelected, String? selectedPresetLibraryName, ValueChanged<PresetLibraryEntry>? onPresetLibraryChanged, bool applyPadding, EdgeInsets padding, bool showLabel})`

### PresetLibraryView

Scrollable display of preset library collections with names and swatch grids.

**Constructors:** `PresetLibraryView({required List<PresetLibraryEntry> entries, required ValueChanged<PaintSwatch> onSelected, PaintSwatch? currentSwatch, bool readOnly, int crossAxisCount, double spacing, double tileSize, int? maxEntries, String title})`

### ColorTile

Individual color/gradient tile for grid display.

**Constructors:** `ColorTile({required Color color, VoidCallback? onTap, double size, String? tooltip, bool isSelected, PaintSwatch? paintSwatch, double borderRadius, double? borderWidth, Color? borderColor, bool showCheckerboard})`

**Factories:** `ColorTile.fromSwatch({required PaintSwatch paintSwatch, VoidCallback? onTap, double? size, ...})`

### ImagePickerWidget

Simple image picker with preview, pick, and clear actions.

**Constructors:** `ImagePickerWidget({Uint8List? imageBytes, String? imageName, required VoidCallback onPickImage, VoidCallback? onClearImage, bool readOnly, double? previewHeight})`

### PaintTypeDropdown / BlendModeDropdown

MenuAnchor-based dropdowns for paint type and blend mode selection.

**PaintTypeDropdown:** `PaintTypeDropdown({required PaintType value, required List<PaintType> items, required ValueChanged<PaintType?> onChanged, required ThemeData theme, required ColorScheme colorScheme})`

**BlendModeDropdown:** `BlendModeDropdown({required BlendModeType value, required List<BlendModeType> items, required ValueChanged<BlendModeType?> onChanged, required ThemeData theme, required ColorScheme colorScheme})`

### RecentColorsManager

`ChangeNotifier` singleton for auto-persisting recent colors via SharedPreferences.

**Constructors:** `factory RecentColorsManager()` (returns `shared` singleton)

| Member | Description |
|--------|-------------|
| `static final RecentColorsManager shared` | Shared singleton instance. |
| `List<PaintSwatch> get swatches` | Current list of recent swatches. |
| `bool get isLoaded` | Whether loaded from storage. |
| `int maxItems` | Maximum items kept (default `24`). |
| `Future<void> loadRecentColors()` | Load from SharedPreferences. |
| `Future<void> addSwatch(PaintSwatch swatch)` | Add swatch, deduplicate, trim, persist. |
| `Future<void> addColor(Color color)` | Convenience: add solid color. |
| `Future<void> clear()` | Clear all recent colors. |
| `Future<void> save()` | Manually save to storage. |

### DefaultPresetLibrary

Static access to 11 curated preset palettes.

| Member | Description |
|--------|-------------|
| `static List<PresetLibraryEntry> get all` | All libraries. |
| `static PresetLibraryEntry? getByName(String name)` | Lookup by name (case-insensitive). |
| `static List<PaintSwatch> getSwatches(String name)` | Get swatches by name. |

Named entries: `codelessly`, `material3`, `apple`, `google`, `discord`, `github`, `vsCode`, `storybook`, `slack`, `tailwind`.

### ColorPickerStorage

Low-level SharedPreferences wrapper for persisting recent colors and last preset library.

| Member | Description |
|--------|-------------|
| `static Future<void> saveRecentColors(List<PaintSwatch> swatches)` | Save up to `maxRecentColors` (24). |
| `static Future<List<PaintSwatch>> loadRecentColors()` | Load saved swatches. |
| `static Future<List<PaintSwatch>> addToRecentColors(PaintSwatch swatch, List<PaintSwatch> currentSwatches)` | Add, deduplicate, trim, save. Returns updated list. |
| `static Future<void> saveLastPresetLibrary(String libraryName)` | Persist last selected library name. |
| `static Future<String?> loadLastPresetLibrary()` | Load last selected library name. |

### Color Utilities

Top-level functions in `color_utils.dart`.

| Member | Description |
|--------|-------------|
| `String parseHex(String hex, {bool withAlpha})` | Normalize/expand hex string. |
| `String colorToHex(Color color, {bool withAlpha, bool withHashtag})` | Convert `Color` to hex string. |
| `Color? hexToColor(String hex, {Color? fallback})` | Parse hex string to `Color`. |
| `String normalizeHex(String hex, {bool withAlpha})` | Normalize hex format. |
| `bool isValidHex(String hex, {bool withAlpha})` | Validate hex format. |

### PopupPositioningUtils

Utility for popup positioning relative to a trigger widget and height persistence.

| Member | Description |
|--------|-------------|
| `static double? loadPersistedHeight(String? key)` | Load persisted height. |
| `static void savePersistedHeight(String? key, double height)` | Save persisted height. |
| `static ({Offset position, double adjustedHeight}) calculatePopupPosition({required BuildContext context, required RenderBox triggerBox, required double popupWidth, required double popupHeight, required double minHeight, required double maxHeight})` | Calculate optimal position with screen-bound awareness. |

### ColorPickerPopupHeight

Calculates estimated popup height from widget layout constants.

| Member | Description |
|--------|-------------|
| `static double estimate({required double popupWidth, required PaintData paint, required bool showRecentColors, required List<PaintSwatch>? recentSwatches, required bool showPresets, required int presetCount, required bool readOnly, ...})` | Estimate popup height. |
| `static double editorHeightFor(PaintType paintType)` | Editor height for solid vs gradient modes. |

### Painters

Custom painters for specialized rendering.

**AlphaPainter** — Checkerboard pattern for transparency visualization. `AlphaPainter(Color alphaColor, double alphaRectSize)`, includes `static void paintAlpha(Canvas, Rect, Color, double, [int, bool])`.

**CheckerboardPainter** — Generic checkerboard pattern with border radius clipping. `CheckerboardPainter(Radius borderRadius, {Color? color, double? size, Color? foregroundColor, Color? backgroundColor})`.

**CircleThumbShape** — Circular slider thumb with white ring, shadow, and highlight. `CircleThumbShape({double? thumbRadius, Color? strokeColor, double strokeWidth, Color? backgroundColor, Color? shadowColor, Color? outlineColor})`.

**GradientSwatchPainter** — Renders linear, radial, or angular gradients with opacity. `GradientSwatchPainter({required Color color, required PaintType paintType, List<ColorStop>? gradientStops, double? gradientAngle, double? gradientOpacity})`.

### PopupResizeHandle

Drag handle for bottom of popup to resize vertically. `PopupResizeHandle({required ValueChanged<double> onResize})`.