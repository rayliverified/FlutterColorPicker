import 'package:colorpicker/colorpicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'local_soft_saas.dart';

import 'widgets/color_picker_trigger_demo.dart';
import 'widgets/color_picker_row_demo.dart';
import 'widgets/dialog_mode_demo.dart';
import 'widgets/layers_list_demo.dart';
import 'widgets/layers_control_panel_demo.dart';
import 'widgets/gradient_demo.dart';
import 'widgets/component_demos.dart';

void main() => runApp(const ColorPickerDemoApp());

class ColorPickerDemoApp extends StatefulWidget {
  const ColorPickerDemoApp({super.key});

  @override
  State<ColorPickerDemoApp> createState() => _ColorPickerDemoAppState();
}

class _ColorPickerDemoAppState extends State<ColorPickerDemoApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Picker · Soft SaaS UI',
      debugShowCheckedModeBanner: false,
      theme: SoftSaaSTheme.light(),
      darkTheme: SoftSaaSTheme.dark(),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: ColorPickerHomePage(
        darkMode: _darkMode,
        onToggleTheme: () => setState(() => _darkMode = !_darkMode),
      ),
    );
  }
}

class ColorPickerHomePage extends StatefulWidget {
  const ColorPickerHomePage({
    super.key,
    required this.darkMode,
    required this.onToggleTheme,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;

  @override
  State<ColorPickerHomePage> createState() => _ColorPickerHomePageState();
}

class _ColorPickerHomePageState extends State<ColorPickerHomePage> {
  final ScrollController _paneScrollController = ScrollController();
  final PageController _mobilePageController = PageController();
  int _selectedPane = 0;

  @override
  void dispose() {
    _paneScrollController.dispose();
    _mobilePageController.dispose();
    super.dispose();
  }

  void _selectPane(int index) {
    if (_selectedPane != index) {
      setState(() => _selectedPane = index);
    }

    if (_mobilePageController.hasClients) {
      _mobilePageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }

    if (!_paneScrollController.hasClients) return;
    final maxExtent = _paneScrollController.position.maxScrollExtent;
    final target = _paneScrollOffsets[index].clamp(0.0, maxExtent);
    _paneScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleMobilePageChanged(int index) {
    if (_selectedPane == index) return;
    setState(() => _selectedPane = index);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: SoftSaaSTokens.secondaryBackground(brightness),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AppHeader(
              darkMode: widget.darkMode,
              onToggleTheme: widget.onToggleTheme,
            ),
            _PaneTabs(selectedIndex: _selectedPane, onChanged: _selectPane),
            Expanded(
              child: _PaneCanvas(
                controller: _paneScrollController,
                mobilePageController: _mobilePageController,
                onMobilePageChanged: _handleMobilePageChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App Header ────────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.darkMode, required this.onToggleTheme});

  final bool darkMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primary = SoftSaaSTokens.primaryColor(brightness);

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: SoftSaaSTokens.primaryBackground(brightness),
        border: Border(
          bottom: BorderSide(color: SoftSaaSTokens.primaryBorder(brightness)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(LucideIcons.palette, size: 14, color: primary),
          ),
          const SizedBox(width: 10),
          Text(
            'Color Picker',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              height: 1.0,
              color: SoftSaaSTokens.primaryText(brightness),
            ),
          ),
          const Spacer(),
          SoftSaaSIconButton(
            icon: darkMode ? LucideIcons.sun : LucideIcons.moon,
            size: SoftSaaSButtonSize.small,
            variant: SoftSaaSIconButtonVariant.ghost,
            tooltip: darkMode ? 'Switch to light' : 'Switch to dark',
            iconColor: SoftSaaSTokens.primaryText(brightness),
            onPressed: onToggleTheme,
          ),
        ],
      ),
    );
  }
}

// ── Workspace panes ──────────────────────────────────────────────────────────

const double _mobilePaneBreakpoint = 600;
const double _normalPaneWidth = 420;
const double _widePaneWidth = _normalPaneWidth * 1.5;
const double _paneGap = 16;
const double _panelGap = 16;
const EdgeInsets _paneContentPadding = EdgeInsets.all(16);
const EdgeInsets _panelBodyPadding = EdgeInsets.all(12);

const List<double> _paneScrollOffsets = [
  0,
  _normalPaneWidth + _paneGap,
  (_normalPaneWidth + _paneGap) * 2,
  (_normalPaneWidth + _paneGap) * 2 + _widePaneWidth + _paneGap,
  (_normalPaneWidth + _paneGap) * 3 + _widePaneWidth + _paneGap,
];

class _PaneTabs extends StatelessWidget {
  const _PaneTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SoftSaaSTokens.primaryBackground(brightness),
        border: Border(
          bottom: BorderSide(color: SoftSaaSTokens.primaryBorder(brightness)),
        ),
      ),
      child: SoftSaaSTabs(
        tabs: const [
          SoftSaaSTab(label: 'Popup', subtitle: 'Default embedded picker'),
          SoftSaaSTab(label: 'Picker', subtitle: 'Trigger & row modes'),
          SoftSaaSTab(label: 'Layers', subtitle: 'Paint stack controls'),
          SoftSaaSTab(label: 'Gradient', subtitle: 'Stop editor'),
          SoftSaaSTab(label: 'Primitives', subtitle: 'Inputs & swatches'),
        ],
        selectedIndex: selectedIndex,
        onChanged: onChanged,
      ),
    );
  }
}

class _PaneCanvas extends StatelessWidget {
  const _PaneCanvas({
    required this.controller,
    required this.mobilePageController,
    required this.onMobilePageChanged,
  });

  final ScrollController controller;
  final PageController mobilePageController;
  final ValueChanged<int> onMobilePageChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _mobilePaneBreakpoint) {
          return PageView(
            controller: mobilePageController,
            onPageChanged: onMobilePageChanged,
            children: [
              _MobilePanePage(child: _fullPickerPane),
              _MobilePanePage(child: _pickerPane),
              _MobilePanePage(child: _layersPane),
              _MobilePanePage(child: _gradientPane),
              _MobilePanePage(child: _primitivesPane),
            ],
          );
        }

        return Scrollbar(
          controller: controller,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            primary: false,
            padding: _paneContentPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _DemoPane(
                  title: 'Popup Picker',
                  subtitle: 'Default embedded picker with dropdown header',
                  icon: LucideIcons.palette,
                  width: _normalPaneWidth,
                  child: _FullPickerTab(),
                ),
                SizedBox(width: _paneGap),
                _DemoPane(
                  title: 'Picker',
                  subtitle: 'Trigger, inline row, and dialog entry points',
                  icon: LucideIcons.pipette,
                  width: _normalPaneWidth,
                  child: _PickerTab(),
                ),
                SizedBox(width: _paneGap),
                _DemoPane(
                  title: 'Layers',
                  subtitle:
                      'Paint stack editing, reordering, and blend controls',
                  icon: LucideIcons.layers,
                  width: _widePaneWidth,
                  child: _LayersTab(),
                ),
                SizedBox(width: _paneGap),
                _DemoPane(
                  title: 'Gradient',
                  subtitle: 'Stop editing and gradient preview workflows',
                  icon: LucideIcons.blend,
                  width: _normalPaneWidth,
                  child: _GradientTab(),
                ),
                SizedBox(width: _paneGap),
                _DemoPane(
                  title: 'Primitives',
                  subtitle: 'Low-level sliders, swatches, inputs, and palettes',
                  icon: LucideIcons.sliders_horizontal,
                  width: _normalPaneWidth,
                  child: _PrimitivesTab(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MobilePanePage extends StatelessWidget {
  const _MobilePanePage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _paneContentPadding,
      child: SizedBox.expand(child: child),
    );
  }
}

const Widget _fullPickerPane = _DemoPane(
  title: 'Popup Picker',
  subtitle: 'Default embedded picker with dropdown header',
  icon: LucideIcons.palette,
  width: double.infinity,
  child: _FullPickerTab(),
);

const Widget _pickerPane = _DemoPane(
  title: 'Picker',
  subtitle: 'Trigger, inline row, and dialog entry points',
  icon: LucideIcons.pipette,
  width: double.infinity,
  child: _PickerTab(),
);

const Widget _layersPane = _DemoPane(
  title: 'Layers',
  subtitle: 'Paint stack editing, reordering, and blend controls',
  icon: LucideIcons.layers,
  width: double.infinity,
  child: _LayersTab(),
);

const Widget _gradientPane = _DemoPane(
  title: 'Gradient',
  subtitle: 'Stop editing and gradient preview workflows',
  icon: LucideIcons.blend,
  width: double.infinity,
  child: _GradientTab(),
);

const Widget _primitivesPane = _DemoPane(
  title: 'Primitives',
  subtitle: 'Low-level sliders, swatches, inputs, and palettes',
  icon: LucideIcons.sliders_horizontal,
  width: double.infinity,
  child: _PrimitivesTab(),
);

class _DemoPane extends StatelessWidget {
  const _DemoPane({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.width,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SizedBox(
      width: width,
      height: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SoftSaaSTokens.primaryBackground(brightness),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 37,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: SoftSaaSTokens.primaryBackground(brightness),
                  border: Border(
                    bottom: BorderSide(
                      color: SoftSaaSTokens.primaryBorder(brightness),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Tooltip(
                      message: subtitle,
                      child: Icon(
                        icon,
                        size: 14,
                        color: SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: SoftSaaSTokens.primaryText(brightness),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pane: Full Picker ────────────────────────────────────────────────────────

class _FullPickerTab extends StatefulWidget {
  const _FullPickerTab();

  @override
  State<_FullPickerTab> createState() => _FullPickerTabState();
}

class _FullPickerTabState extends State<_FullPickerTab> {
  Color _color = const Color(0xFF2196F3);
  late final RecentColorsManager _recentColorsManager;

  @override
  void initState() {
    super.initState();
    _recentColorsManager = RecentColorsManager.shared;
    _recentColorsManager.addListener(_handleRecentColorsChanged);
    _recentColorsManager.loadRecentColors();
  }

  @override
  void dispose() {
    _recentColorsManager.removeListener(_handleRecentColorsChanged);
    super.dispose();
  }

  void _handleRecentColorsChanged() {
    if (mounted) setState(() {});
  }

  double _panelHeight(double width) {
    final presetCount =
        DefaultPresetLibrary.getByName('Codelessly')?.swatches.length ?? 0;

    return ColorPickerPopupHeight.estimate(
      popupWidth: width,
      paint: PaintData.solid(color: _color),
      showRecentColors: true,
      recentSwatches: _recentColorsManager.swatches,
      showPresets: true,
      presetCount: presetCount,
      usesPresetLibraryDropdown: DefaultPresetLibrary.all.isNotEmpty,
      readOnly: false,
      minHeight: 0,
      maxHeight: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SingleChildScrollView(
      padding: _paneContentPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : 300.0;

          return Container(
            decoration: BoxDecoration(
              color: SoftSaaSTokens.primaryBackground(brightness),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: SoftSaaSTokens.primaryBorder(brightness),
              ),
            ),
            child: SizedBox(
              height: _panelHeight(width),
              child: ColorPickerPanel(
                color: _color,
                onColorChanged: (color) => setState(() => _color = color),
                onColorChangeEnd: () {
                  _recentColorsManager.addColor(_color);
                },
                recentSwatches: _recentColorsManager.swatches,
                onRecentSwatchAdd: _recentColorsManager.addSwatch,
                onRecentSwatchSelected: (swatch) =>
                    setState(() => _color = swatch.color),
                showPresetLibrary: true,
                showPageSwitcher: true,
                onPresetLibrarySelected: (color) =>
                    setState(() => _color = color),
                maxWidth: null,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Pane: Picker ─────────────────────────────────────────────────────────────

class _PickerTab extends StatelessWidget {
  const _PickerTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _paneContentPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SoftSaaSPanel(
                title: 'Popup Trigger',
                subtitle: 'Click the color swatch to open a picker popup',
                icon: LucideIcons.pipette,
                child: Padding(
                  padding: _panelBodyPadding,
                  child: SizedBox(
                    width: double.infinity,
                    child: ColorPickerTriggerDemo(),
                  ),
                ),
              ),
              const SizedBox(height: _panelGap),
              SoftSaaSPanel(
                title: 'Inline Row',
                subtitle:
                    'Edit hex and opacity inline, click swatch for full picker',
                icon: LucideIcons.list,
                child: const Padding(
                  padding: _panelBodyPadding,
                  child: ColorPickerRowDemo(),
                ),
              ),
              const SizedBox(height: _panelGap),
              SoftSaaSPanel(
                title: 'Dialog Mode',
                subtitle: 'Open a color picker inside a modal dialog',
                icon: LucideIcons.panel_right,
                child: Padding(
                  padding: _panelBodyPadding,
                  child: SizedBox(
                    width: double.infinity,
                    child: DialogModeDemo(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab: Layers ───────────────────────────────────────────────────────────────

class _LayersTab extends StatelessWidget {
  const _LayersTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _paneContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SoftSaaSPanel(
            title: 'Layer Management',
            subtitle:
                'Drag to reorder, tap swatch to pick colors, toggle visibility',
            icon: LucideIcons.layers,
            child: const Padding(
              padding: _panelBodyPadding,
              child: LayersListDemo(),
            ),
          ),
          const SizedBox(height: _panelGap),
          SoftSaaSPanel(
            title: 'Control Panel',
            subtitle: 'Paint type, blend mode, and page switching controls',
            icon: LucideIcons.sliders_horizontal,
            child: const Padding(
              padding: _panelBodyPadding,
              child: LayersControlPanelDemo(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab: Gradient ─────────────────────────────────────────────────────────────

class _GradientTab extends StatelessWidget {
  const _GradientTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _paneContentPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: const SoftSaaSPanel(
            title: 'Gradient Editor',
            subtitle:
                'Tap to add stops · drag to move · drag down to delete · Alt+drag to copy',
            icon: LucideIcons.blend,
            child: Padding(padding: _panelBodyPadding, child: GradientDemo()),
          ),
        ),
      ),
    );
  }
}

// ── Tab: Primitives ───────────────────────────────────────────────────────────

class _PrimitivesTab extends StatefulWidget {
  const _PrimitivesTab();

  @override
  State<_PrimitivesTab> createState() => _PrimitivesTabState();
}

class _PrimitivesTabState extends State<_PrimitivesTab> {
  Color _selectedColor = Colors.blue;
  Color _paletteColor = Colors.orange;
  double _rainbowPosition = 2.0;

  late final RecentColorsManager _recentColorsManager;

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
    return ListenableBuilder(
      listenable: _recentColorsManager,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: _paneContentPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SoftSaaSPanel(
                    title: 'Color Field',
                    subtitle: 'Color tile swatches with transparency support',
                    icon: LucideIcons.square,
                    child: Padding(
                      padding: _panelBodyPadding,
                      child: ColorFieldSection(),
                    ),
                  ),
                  const SizedBox(height: _panelGap),
                  SoftSaaSPanel(
                    title: 'Hex Input',
                    subtitle: 'Hex color input with optional alpha channel',
                    icon: LucideIcons.hash,
                    child: Padding(
                      padding: _panelBodyPadding,
                      child: HexInputSection(
                        color: _selectedColor,
                        onChanged: (c) => setState(() => _selectedColor = c),
                      ),
                    ),
                  ),
                  const SizedBox(height: _panelGap),
                  SoftSaaSPanel(
                    title: 'Alpha Input',
                    subtitle: 'Gradient-based opacity drag input',
                    icon: LucideIcons.droplets,
                    child: Padding(
                      padding: _panelBodyPadding,
                      child: AlphaInputSection(
                        color: _selectedColor,
                        onChanged: (c) => setState(() => _selectedColor = c),
                      ),
                    ),
                  ),
                  const SizedBox(height: _panelGap),
                  SoftSaaSPanel(
                    title: 'Palette',
                    subtitle: 'Saturation/brightness picker canvas',
                    icon: LucideIcons.circle_dot,
                    child: PaletteSection(
                      paletteColor: _paletteColor,
                      onChanged: (c) => setState(() => _paletteColor = c),
                    ),
                  ),
                  const SizedBox(height: _panelGap),
                  SoftSaaSPanel(
                    title: 'Rainbow Slider',
                    subtitle: 'Hue selection slider',
                    icon: LucideIcons.sun_dim,
                    child: Padding(
                      padding: _panelBodyPadding,
                      child: RainbowSliderSection(
                        rainbowPosition: _rainbowPosition,
                        onPositionChanged: (pos, color) => setState(() {
                          _rainbowPosition = pos;
                          _paletteColor = color;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: _panelGap),
                  SoftSaaSPanel(
                    title: 'Alpha Slider',
                    subtitle: 'Opacity slider for the selected color',
                    icon: LucideIcons.blend,
                    child: Padding(
                      padding: _panelBodyPadding,
                      child: AlphaSliderSection(
                        color: _selectedColor,
                        onChanged: (c) => setState(() => _selectedColor = c),
                      ),
                    ),
                  ),
                  const SizedBox(height: _panelGap),
                  SoftSaaSPanel(
                    title: 'Recent Colors',
                    subtitle: 'Persisted recent color swatches',
                    icon: LucideIcons.history,
                    child: Padding(
                      padding: _panelBodyPadding,
                      child: RecentColorsSection(
                        swatches: _recentColorsManager.swatches,
                        onSelected: (swatch) => setState(() {
                          _selectedColor = swatch.color;
                          _paletteColor = swatch.color;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: _panelGap),
                  SoftSaaSPanel(
                    title: 'Color Presets',
                    subtitle:
                        'Named preset swatches with current color indicator',
                    icon: LucideIcons.bookmark,
                    child: Padding(
                      padding: _panelBodyPadding,
                      child: ColorPresetsSection(
                        presets: _presets,
                        currentColor: _paletteColor,
                        onSelected: (swatch) => setState(() {
                          _selectedColor = swatch.color;
                          _paletteColor = swatch.color;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
