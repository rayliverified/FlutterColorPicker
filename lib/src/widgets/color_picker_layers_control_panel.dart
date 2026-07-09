import 'package:flutter/material.dart';

import 'color_picker.dart';
import '../models/blend_mode_type.dart';
import 'paint_type_dropdown.dart';
import 'blend_mode_dropdown.dart';

/// Layers control panel for color picker.
/// 
/// This widget provides the layer controls UI including:
/// - Paint type dropdown (Solid, Linear, Radial, Angular, Image)
/// - Blend mode dropdown (Normal, Multiply, Screen, etc.)
/// - Page switcher button (Library/Editor toggle)
/// 
/// This is extracted from ColorPickerPanel to be used independently.
/// 
/// ## Usage
/// 
/// ```dart
/// ColorPickerLayersControlPanel(
///   paintType: PaintType.solid,
///   onPaintTypeChanged: (type) => print('Changed to $type'),
///   showBlendMode: true,
///   blendMode: BlendModeType.normal,
///   onBlendModeChanged: (mode) => print('Blend mode: $mode'),
///   showPageSwitcher: true,
///   currentPageIndex: 0,
///   onPageSwitcherTapped: () => setState(() => _pageIndex = (_pageIndex + 1) % 2),
/// )
/// ```
/// 
/// See [API_LAYERS_PANEL.md] for complete API documentation.
class ColorPickerLayersControlPanel extends StatelessWidget {
  /// Currently selected paint type.
  /// 
  /// If null, defaults to the first item in [supportedTypes].
  /// Only types in [supportedTypes] will appear in the dropdown.
  final PaintType? paintType;
  
  /// Called when paint type changes.
  /// 
  /// The callback receives the newly selected paint type.
  /// This is called when the user selects a different paint type from the dropdown.
  final ValueChanged<PaintType>? onPaintTypeChanged;
  
  /// List of supported paint types.
  /// 
  /// Defaults to: [PaintType.solid, PaintType.gradientLinear, 
  /// PaintType.gradientRadial, PaintType.gradientAngular, PaintType.image]
  /// 
  /// Only types in this list will appear in the dropdown.
  /// You can customize this to show only specific paint types.
  final List<PaintType> supportedTypes;
  
  /// Whether to show the blend mode dropdown.
  /// 
  /// Defaults to false. Set to true to enable blend mode selection.
  /// When enabled, a dropdown will appear next to the paint type dropdown.
  final bool showBlendMode;
  
  /// Currently selected blend mode.
  /// 
  /// If null, defaults to [BlendModeType.normal].
  /// This value determines which blend mode is selected in the dropdown.
  final BlendModeType? blendMode;
  
  /// Called when blend mode changes.
  /// 
  /// The callback receives the newly selected blend mode.
  /// This is called when the user selects a different blend mode from the dropdown.
  final ValueChanged<BlendModeType>? onBlendModeChanged;
  
  /// Whether to show the page switcher button.
  /// 
  /// Defaults to false. Set to true to enable page switching.
  /// 
  /// **Important:** The button will only appear for solid and gradient paint types.
  /// It is hidden for image and emoji paint types, matching the behavior
  /// in the main Codelessly editor where the Library view is only available
  /// for color-based paint types.
  final bool showPageSwitcher;
  
  /// Current page index (0 = Editor, 1 = Library).
  /// 
  /// Used to determine which icon to display:
  /// - `0` (Editor): Shows `Icons.gps_not_fixed`
  /// - `1` (Library): Shows `Icons.book`
  /// 
  /// If null, defaults to 0 (Editor).
  final int? currentPageIndex;
  
  /// Called when page switcher button is tapped.
  /// 
  /// You should update [currentPageIndex] in your state to toggle pages.
  /// Typically, you would toggle between 0 and 1:
  /// ```dart
  /// onPageSwitcherTapped: () {
  ///   setState(() {
  ///     _pageIndex = (_pageIndex + 1) % 2;
  ///   });
  /// }
  /// ```
  final VoidCallback? onPageSwitcherTapped;
  
  /// Read-only mode.
  /// 
  /// When true, displays selected values as text instead of dropdowns.
  /// All interactive elements are disabled.
  /// 
  /// Defaults to false.
  final bool readOnly;
  
  /// Padding around the control panel.
  /// 
  /// Defaults to `EdgeInsets.fromLTRB(4, 8, 8, 6)` to match main app styling.
  /// You can customize this to adjust spacing.
  final EdgeInsets padding;
  
  /// Whether to show divider after the control panel.
  /// 
  /// Defaults to true. Set to false to hide the divider.
  /// The divider appears below the control row.
  final bool showDivider;

  const ColorPickerLayersControlPanel({
    super.key,
    this.paintType,
    this.onPaintTypeChanged,
    this.supportedTypes = const [
      PaintType.solid,
      PaintType.gradientLinear,
      PaintType.gradientRadial,
      PaintType.gradientAngular,
      PaintType.image,
    ],
    this.showBlendMode = false,
    this.blendMode,
    this.onBlendModeChanged,
    this.showPageSwitcher = false,
    this.currentPageIndex,
    this.onPageSwitcherTapped,
    this.readOnly = false,
    this.padding = const EdgeInsets.fromLTRB(4, 8, 8, 6),
    this.showDivider = true,
  });

  /// Builds the title widget (paint type + blend mode dropdowns).
  /// 
  /// This matches the structure used in the main app's DraggableWidgetHeaderBar
  /// where titleWidget contains the paint type and blend mode controls.
  Widget buildTitleWidget(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final selectedPaintType = paintType ?? supportedTypes.first;
    final selectedBlendMode = blendMode ?? BlendModeType.normal;

    return Row(
      children: <Widget>[
        // Paint type dropdown
        if (readOnly)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            child: Text(
              selectedPaintType.prettify,
              style: theme.textTheme.bodyMedium,
            ),
          )
        else
          PaintTypeDropdown(
            value: selectedPaintType,
            items: supportedTypes,
            onChanged: (PaintType? value) {
              if (value != null) {
                onPaintTypeChanged?.call(value);
              }
            },
            theme: theme,
            colorScheme: colorScheme,
          ),
        // Blend mode dropdown
        if (showBlendMode) ...[
          const SizedBox(width: 8),
          if (readOnly)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              child: Text(
                selectedBlendMode.label,
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            BlendModeDropdown(
              value: selectedBlendMode,
              items: BlendModeType.values,
              onChanged: (BlendModeType? value) {
                if (value != null) {
                  onBlendModeChanged?.call(value);
                }
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
        ],
      ],
    );
  }

  /// Builds the actions widgets (page switcher button).
  /// 
  /// This matches the structure used in the main app's DraggableWidgetHeaderBar
  /// where actions contains the page switcher button.
  List<Widget> buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final selectedPaintType = paintType ?? supportedTypes.first;
    final pageIndex = currentPageIndex ?? 0;
    
    final shouldShowPageSwitcher = showPageSwitcher && 
        (selectedPaintType == PaintType.solid || 
         selectedPaintType == PaintType.gradientLinear ||
         selectedPaintType == PaintType.gradientRadial ||
         selectedPaintType == PaintType.gradientAngular);

    if (!shouldShowPageSwitcher) {
      return const <Widget>[];
    }

    return <Widget>[
      Material(
        type: MaterialType.transparency,
        child: Tooltip(
          message: pageIndex == 0 ? 'Library' : 'Editor',
          waitDuration: const Duration(seconds: 1),
          child: IconButton(
            icon: Icon(
              pageIndex == 0 ? Icons.book : Icons.gps_not_fixed,
              size: 14,
            ),
            color: colorScheme.secondary,
            splashRadius: 12,
            onPressed: readOnly ? null : onPageSwitcherTapped,
            constraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Container matching DraggableWidgetHeaderBar structure
        Container(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Title widget (paint type + blend mode)
              buildTitleWidget(context),
              const Spacer(),
              // Actions (page switcher)
              ...buildActions(context),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}

