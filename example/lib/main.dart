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
  int _selectedPane = 0;

  @override
  void dispose() {
    _paneScrollController.dispose();
    super.dispose();
  }

  void _selectPane(int index) {
    setState(() => _selectedPane = index);
    if (!_paneScrollController.hasClients) return;
    final maxExtent = _paneScrollController.position.maxScrollExtent;
    final target = _paneScrollOffsets[index].clamp(0.0, maxExtent);
    _paneScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
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
            Expanded(child: _PaneCanvas(controller: _paneScrollController)),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 2),
              Text(
                'Soft SaaS UI demo',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: -0.1,
                  height: 1.0,
                  color: SoftSaaSTokens.tertiaryText(brightness),
                ),
              ),
            ],
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

const double _normalPaneWidth = 420;
const double _widePaneWidth = _normalPaneWidth * 1.5;
const double _paneGap = 14;

const List<double> _paneScrollOffsets = [
  0,
  _normalPaneWidth + _paneGap,
  _normalPaneWidth + _paneGap + _widePaneWidth + _paneGap,
  _normalPaneWidth +
      _paneGap +
      _widePaneWidth +
      _paneGap +
      _normalPaneWidth +
      _paneGap,
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
  const _PaneCanvas({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        primary: false,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
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
              subtitle: 'Paint stack editing, reordering, and blend controls',
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
  }
}

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
          border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
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

// ── Pane: Picker ─────────────────────────────────────────────────────────────

class _PickerTab extends StatelessWidget {
  const _PickerTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ColorPickerTriggerDemo(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SoftSaaSPanel(
                title: 'Inline Row',
                subtitle:
                    'Edit hex and opacity inline, click swatch for full picker',
                icon: LucideIcons.list,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: ColorPickerRowDemo(),
                ),
              ),
              const SizedBox(height: 12),
              SoftSaaSPanel(
                title: 'Dialog Mode',
                subtitle: 'Open a color picker inside a modal dialog',
                icon: LucideIcons.panel_right,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SoftSaaSPanel(
            title: 'Layer Management',
            subtitle:
                'Drag to reorder, tap swatch to pick colors, toggle visibility',
            icon: LucideIcons.layers,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: LayersListDemo(),
            ),
          ),
          const SizedBox(height: 12),
          SoftSaaSPanel(
            title: 'Control Panel',
            subtitle: 'Paint type, blend mode, and page switching controls',
            icon: LucideIcons.sliders_horizontal,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: const SoftSaaSPanel(
            title: 'Gradient Editor',
            subtitle:
                'Tap to add stops · drag to move · drag down to delete · Alt+drag to copy',
            icon: LucideIcons.blend,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: GradientDemo(),
            ),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                      padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: ColorFieldSection(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftSaaSPanel(
                    title: 'Hex Input',
                    subtitle: 'Hex color input with optional alpha channel',
                    icon: LucideIcons.hash,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: HexInputSection(
                        color: _selectedColor,
                        onChanged: (c) => setState(() => _selectedColor = c),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftSaaSPanel(
                    title: 'Alpha Input',
                    subtitle: 'Gradient-based opacity drag input',
                    icon: LucideIcons.droplets,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: AlphaInputSection(
                        color: _selectedColor,
                        onChanged: (c) => setState(() => _selectedColor = c),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftSaaSPanel(
                    title: 'Palette',
                    subtitle: 'Saturation/brightness picker canvas',
                    icon: LucideIcons.circle_dot,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: PaletteSection(
                        paletteColor: _paletteColor,
                        onChanged: (c) => setState(() => _paletteColor = c),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftSaaSPanel(
                    title: 'Rainbow Slider',
                    subtitle: 'Hue selection slider',
                    icon: LucideIcons.sun_dim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: RainbowSliderSection(
                        rainbowPosition: _rainbowPosition,
                        onPositionChanged: (pos, color) => setState(() {
                          _rainbowPosition = pos;
                          _paletteColor = color;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftSaaSPanel(
                    title: 'Alpha Slider',
                    subtitle: 'Opacity slider for the selected color',
                    icon: LucideIcons.blend,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: AlphaSliderSection(
                        color: _selectedColor,
                        onChanged: (c) => setState(() => _selectedColor = c),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftSaaSPanel(
                    title: 'Recent Colors',
                    subtitle: 'Persisted recent color swatches',
                    icon: LucideIcons.history,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: RecentColorsSection(
                        swatches: _recentColorsManager.swatches,
                        onSelected: (swatch) => setState(() {
                          _selectedColor = swatch.color;
                          _paletteColor = swatch.color;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftSaaSPanel(
                    title: 'Color Presets',
                    subtitle:
                        'Named preset swatches with current color indicator',
                    icon: LucideIcons.bookmark,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
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
