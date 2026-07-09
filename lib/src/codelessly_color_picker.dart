/// Codelessly Color Picker Library
///
/// A comprehensive, reusable color picker widget library for Flutter with
/// support for solid colors, gradients (linear, radial, angular), hex input,
/// alpha channels, recent colors, presets, and preset libraries.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:color_picker_plus/color_picker_plus.dart';
///
/// ColorPicker(
///   color: selectedColor,
///   onColorChanged: (color) => setState(() => selectedColor = color),
/// )
/// ```
///
/// See the [README](https://github.com/Codelessly/OverlookV2/tree/main/packages/color_picker)
/// for more information and examples.
library;

// Models
export 'models/paint_data.dart';
export 'models/layer_data.dart';
export 'models/color_stop.dart';
export 'models/blend_mode_type.dart';
export 'models/paint_swatch.dart';
export 'models/paint_state.dart';

// Widgets
export 'widgets/color_picker.dart';
export 'widgets/color_picker_panel.dart';
export 'widgets/color_picker_layers_control_panel.dart';
export 'widgets/color_picker_trigger.dart';
export 'widgets/color_picker_row.dart';
export 'widgets/image_picker_widget.dart';
export 'widgets/palette.dart';
export 'widgets/rainbow_slider.dart';
export 'widgets/alpha_slider.dart';
export 'widgets/color_inputs.dart';
export 'widgets/recent_colors_view.dart';
export 'widgets/color_tile.dart';
export 'widgets/color_picker_dialog.dart';
export 'widgets/layers_list.dart';
export 'widgets/layers_preview.dart';
export 'widgets/layer_info_panel.dart';
export 'widgets/gradient_editor.dart';
export 'widgets/gradient_stops_list.dart';
export 'widgets/angle_input_dialer.dart';
export 'widgets/gradient_alpha_input.dart';
export 'widgets/paint_type_dropdown.dart';
export 'widgets/blend_mode_dropdown.dart';

// Utils
export 'utils/color_utils.dart';
export 'utils/alpha_painter.dart';
export 'utils/color_picker_storage.dart';
export 'utils/color_picker_popup_height.dart';
export 'utils/default_preset_library.dart';
export 'utils/recent_colors_manager.dart';
