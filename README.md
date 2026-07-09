# colorpicker

A modern, comprehensive color picker library for Flutter with support for solid colors, gradients, blend modes, and multi-layer paint management.

## Live Demo

Try the Flutter web example: [fluttercolorpicker.netlify.app](https://fluttercolorpicker.netlify.app/)

## ✨ Highlights

- **Unified Paint Model** with built-in value equality for effortless state management
- **Simple & Advanced APIs** - Use `color` for basics, `Paint` for full control
- **Gradient Support** - Linear, radial, and angular gradients with visual editor
- **Multi-Layer Management** - Layer reordering, visibility, and blend modes
- **Auto-Persistence** - Recent colors saved automatically to SharedPreferences
- **Preset Libraries** - Curated palettes (Material 3, iOS, Tailwind, and more)
- **Dialog & Popup Modes** - Flexible integration options
- **Composable Components** - Use individual pieces or complete solutions

---

## 🚀 Quick Start

### Simple Color Picking

```dart
import 'package:color_picker_plus/color_picker_plus.dart';

// Inline row with text inputs (like common design-tool inspectors)
ColorPickerRow(
  color: selectedColor,
  onColorChanged: (color) => setState(() => selectedColor = color),
)

// Basic swatch that opens popup
ColorPickerTrigger(
  color: selectedColor,
  onPaintChanged: (paint) => setState(() => selectedColor = paint.color),
)

// Full panel
ColorPickerPanel(
  color: selectedColor,
  onColorChanged: (color) => setState(() => selectedColor = color),
)

// Dialog
final color = await showColorPickerDialog(
  context: context,
  initialColor: Colors.blue,
  title: 'Pick a color',
);
```

### Advanced with Gradients & Blend Modes

```dart
// Using the unified Paint model
Paint myPaint = Paint.solid(color: Colors.blue);

ColorPickerTrigger(
  paint: myPaint,
  onPaintChanged: (paint) => setState(() => myPaint = paint),
  showBlendMode: true,
  showPageSwitcher: true,
)
```

---

## 📦 Core Widgets

### ColorPickerRow

Inline color editor with text inputs, similar to common design-tool inspectors. **Best for forms and property panels.**

Features **inline-edit behavior**: values display as text and become editable inputs when clicked.

```dart
// Default: Compact mode (swatch + HEX only)
ColorPickerRow(
  color: myColor,
  onColorChanged: (color) => setState(() => myColor = color),
)

// With labels and outline borders
ColorPickerRow(
  color: myColor,
  onColorChanged: (color) => setState(() => myColor = color),
  showOpacity: true,
  showRGB: true,
  showLabels: true,
  showOutline: true,
)
```

**Key Parameters:**
- `color` (required) - Current color
- `onColorChanged` - Callback with updated color
- `showRGB` - Show R, G, B numeric inputs (default: false)
- `showAlpha` - Show alpha input 0-255 (default: false)
- `showOpacity` - Show opacity percentage 0-100% (default: false)
- `showLabels` - Show labels above inputs (default: false)
- `showOutline` - Show visible borders on inputs (default: false)
- `swatchSize`, `spacing` - Customize layout
- `labelStyle`, `inputStyle` - Custom text styles
- Clicking the swatch opens the full popup picker

### ColorPickerTrigger

Clickable color swatch that opens a popup picker. **Recommended for toolbars and compact UIs.**

```dart
// Simple solid colors (90% of use cases)
ColorPickerTrigger(
  color: Colors.blue,
  onPaintChanged: (paint) => setState(() => myColor = paint.color),
)

// Advanced with gradients and blend modes
ColorPickerTrigger(
  paint: myPaint,
  onPaintChanged: (paint) => setState(() => myPaint = paint),
  showBlendMode: true,
  showPageSwitcher: true,
)
```

**Key Parameters:**
- `color` or `paint` (one required) - Current color/paint
- `onPaintChanged` - Callback with updated Paint
- `size`, `borderRadius` - Customize swatch appearance
- `showBlendMode`, `showPageSwitcher` - Enable advanced features
- `recentSwatches`, `presets`, `presetLibrary` - Add collections

### ColorPickerPanel

Full-featured picker panel with gradient editor, blend modes, and preset library.

```dart
ColorPickerPanel(
  color: selectedColor,
  onColorChanged: (color) => setState(() => selectedColor = color),
  showBlendMode: true,
  showPageSwitcher: true,
  recentSwatches: recentColors,
  presetLibrary: DefaultPresetLibrary.all,
)
```

### ColorPickerDialog

Modal dialog for color selection.

```dart
final Color? result = await showColorPickerDialog(
  context: context,
  initialColor: Colors.blue,
  title: 'Select Color',
  showBlendMode: true,
  showPresetLibrary: true,
);

if (result != null) {
  setState(() => selectedColor = result);
}
```

### LayersList

Multi-layer paint management with drag-to-reorder, visibility toggles, and inline color pickers.

```dart
List<LayerData> layers = [...];

LayersList(
  layers: layers,
  onLayersChanged: (updatedLayers) {
    setState(() => layers = updatedLayers);
  },
  selectedIndex: selectedIndex,
  onLayerSelected: (index) => setState(() => selectedIndex = index),
  enableReorder: true,
  enableVisibility: true,
  enableColorPicker: true,
  recentSwatches: recentColors,
  presets: presets,
)
```

**Feature Toggles:**
- `enableReorder` - Drag to reorder layers
- `enableVisibility` - Show/hide toggle buttons
- `enableColorPicker` - Inline color pickers for each layer
- `enableSelection` - Layer selection highlighting

---

## 🎨 Paint Model

The unified `Paint` model with built-in value equality simplifies state management:

### Creating Paints

```dart
// Solid color
final solid = Paint.solid(color: Colors.blue);

// Linear gradient
final linear = Paint.linearGradient(
  stops: [
    ColorStop(position: 0.0, color: Colors.red),
    ColorStop(position: 1.0, color: Colors.blue),
  ],
  angle: 45,
);

// Radial gradient
final radial = Paint.radialGradient(
  stops: [...],
);

// Angular gradient
final angular = Paint.angularGradient(
  stops: [...],
  angle: 90,
);
```

### Benefits

**✅ Automatic Change Detection**
```dart
if (oldPaint != newPaint) {
  print('Paint changed!');
}
```

**✅ Simple Undo/Redo**
```dart
final history = <Paint>[];
history.add(currentPaint); // Save state
currentPaint = history[previousIndex]; // Undo
```

**✅ Duplicate Detection**
```dart
final uniquePaints = <Paint>{paint1, paint2, paint2};
assert(uniquePaints.length == 2); // Automatic deduplication
```

**✅ Easy Persistence**
```dart
// Save
final json = paint.toJson();
await storage.save(json);

// Restore
final restored = Paint.fromJson(json);
assert(restored == paint); // Perfect equality!
```

---

## 🔧 Component Widgets

Mix and match individual components for custom UIs:

### Color Selection
- **`Palette`** - 2D saturation/brightness selector
- **`RainbowSlider`** - Hue slider (0.0-6.0 range)
- **`AlphaSlider`** - Opacity control with checkerboard

### Text Inputs
- **`ColorHexInput`** - Hex color input with validation and formatting
  - Supports 6-digit (`#RRGGBB`) and 8-digit (`#AARRGGBB`) hex formats
  - Parameters: `color`, `onColorChanged`, `allowAlpha`, `showLabel`, `showOutline`, `readOnly`
  - Auto-formats input as user types
- **`GradientAlphaInput`** - Opacity percentage input (0-100%) with drag support
  - Parameters: `color`, `onValueUpdate`, `label`, `showLabel`, `showOutline`, `readOnly`
  - Supports horizontal drag to adjust value
  - Displays percentage sign inline with value

### Gradient Editor
- **`GradientEditor`** - Visual stop editor with drag, add, delete, copy (Alt+drag)
- **`AngleInputDialer`** - Gradient angle adjuster with drag support

### Collections
- **`RecentColorsView`** - Grid of recent colors/gradients
- **`ColorPresetsView`** - Grid of preset swatches
- **`PresetLibraryView`** - Scrollable palette collections

### Dropdowns
- **`PaintTypeDropdown`** - Solid, Linear, Radial, Angular, Image
- **`BlendModeDropdown`** - 28 blend modes (normal, multiply, screen, etc.)

---

## 💾 Persistence & Presets

### RecentColorsManager

Auto-persisting recent colors with `ChangeNotifier` support.

```dart
class _MyWidgetState extends State<MyWidget> {
  late final RecentColorsManager _recentColorsManager;

  @override
  void initState() {
    super.initState();
    _recentColorsManager = RecentColorsManager();
    _recentColorsManager.loadRecentColors().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _recentColorsManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColorPickerTrigger(
      color: selectedColor,
      onPaintChanged: (paint) => setState(() => selectedColor = paint.color),
      recentSwatches: _recentColorsManager.swatches,
    );
  }
}
```

### Default Preset Libraries

Curated color palettes from popular design systems:

```dart
DefaultPresetLibrary.all  // Get all libraries
DefaultPresetLibrary.getByName('Material')  // Specific library
DefaultPresetLibrary.getSwatches('Tailwind')  // Get swatches

// Available libraries:
// Codelessly, Material 3, iOS (Apple), Google, Discord, 
// GitHub, VS Code, Storybook, Slack, Tailwind
```

---

## 📋 Common Patterns

### With Recent Colors and Preset Library

```dart
ColorPickerPanel(
  color: selectedColor,
  onColorChanged: (color) => setState(() => selectedColor = color),
  showRecentColors: true,
  recentSwatches: _recentColorsManager.swatches,
  showPresetLibrary: true,
  presetLibrary: DefaultPresetLibrary.all,
)
```

### Multi-Layer Paint Management

```dart
List<LayerData> layers = [
  LayerData(
    id: 'bg',
    name: 'Background',
    paintType: PaintType.solid,
    color: Colors.blue,
    blendMode: BlendModeType.normal,
  ),
  LayerData(
    id: 'gradient',
    name: 'Gradient Overlay',
    paintType: PaintType.gradientLinear,
    color: Colors.purple,
    blendMode: BlendModeType.multiply,
    gradientStops: [
      ColorStop(position: 0.0, color: Colors.purple),
      ColorStop(position: 1.0, color: Colors.blue),
    ],
    gradientAngle: 45,
  ),
];

LayersList(
  layers: layers,
  onLayersChanged: (updated) => setState(() => layers = updated),
  enableReorder: true,
  enableVisibility: true,
)
```

### Custom Color Picker Button

```dart
ColorPickerTrigger(
  color: selectedColor,
  onPaintChanged: (paint) => setState(() => selectedColor = paint.color),
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: selectedColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.color_lens, color: Colors.white),
        SizedBox(width: 8),
        Text('Pick Color', style: TextStyle(color: Colors.white)),
      ],
    ),
  ),
)
```

---

## 🎯 Key Models

### Paint
Unified paint model with value equality. Properties: `type`, `color`, `blendMode`, `gradientStops`, `gradientAngle`, `gradientOpacity`, `selectedStopIndex`.

### LayerData
Layer metadata for multi-layer management. Properties: `id`, `name`, `paintType`, `color`, `blendMode`, `visible`, `gradientStops`, etc.

Methods: `copyWith()`, `toPaint()`, `withPaint(Paint)`

### PaintType
Enum: `solid`, `gradientLinear`, `gradientRadial`, `gradientAngular`, `image`

### BlendModeType
Enum with 28 values: `normal`, `multiply`, `screen`, `overlay`, `darken`, `lighten`, etc.

### ColorStop
Position-color pair for gradients: `position` (0.0-1.0), `color`

### PaintSwatch
Display wrapper for Paint with optional label. Used in recent colors and presets.

### ColorPreset
Preset configuration with swatch and optional label. Constructors: `.solid()`, `.gradient()`

### PresetLibraryEntry
Named collection of swatches (e.g., "Material 3 Blues"). Constructor: `.fromColors(name, colors)`

---

## 🛠️ Utilities

### Color Utilities
- `colorToHex(Color, {withHashtag, withAlpha})` - Convert to hex string
- `hexToColor(String)` - Parse hex to Color
- `normalizeHex(String)` - Format validation
- `isValidHex(String)` - Validate hex format

### Storage
- **`ColorPickerStorage`** - Low-level SharedPreferences wrapper
- **`RecentColorsManager`** - High-level recent colors with ChangeNotifier

---

## ⚡ Performance

- **RepaintBoundary** wrapping for efficient repaints
- **Optimized CustomPainter** implementations
- **Minimal setState** calls with granular callbacks
- **Separate drag callbacks** to avoid rebuilds during interaction
- **Optional throttle duration** for high-frequency updates

---

## 📚 Examples

See the `/example` directory for comprehensive demos:

- **`popup_trigger_demo.dart`** - ColorPickerTrigger variations (simple & advanced)
- **`layers_list_demo.dart`** - Multi-layer management with features
- **`layers_demo.dart`** - Complete layers control panel
- **`dialog_mode_demo.dart`** - Modal dialog examples
- **`component_demos.dart`** - Individual component showcase

Run the example app:
```bash
cd colorpicker/example
flutter run
```

---
