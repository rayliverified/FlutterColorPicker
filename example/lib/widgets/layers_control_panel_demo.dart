import 'package:color_picker_plus/color_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../local_soft_saas.dart';

/// Demonstrates the ColorPickerLayersControlPanel widget in various configurations.
class LayersControlPanelDemo extends StatefulWidget {
  const LayersControlPanelDemo({super.key});

  @override
  State<LayersControlPanelDemo> createState() => _LayersControlPanelDemoState();
}

class _LayersControlPanelDemoState extends State<LayersControlPanelDemo> {
  PaintType _basicPaintType = PaintType.solid;

  PaintType _blendPaintType = PaintType.solid;
  BlendModeType _blendMode = BlendModeType.normal;

  PaintType _switcherPaintType = PaintType.solid;
  BlendModeType _switcherBlendMode = BlendModeType.normal;
  int _pageIndex = 0;

  PaintType _limitedPaintType = PaintType.solid;

  final PaintType _readOnlyPaintType = PaintType.gradientLinear;
  final BlendModeType _readOnlyBlendMode = BlendModeType.multiply;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _DemoSection(
          title: '1. Basic (Paint Type Only)',
          description: 'Shows only the paint type dropdown.',
          brightness: brightness,
          badge: _basicPaintType.prettify,
          child: _panelWrap(
            brightness,
            ColorPickerLayersControlPanel(
              paintType: _basicPaintType,
              onPaintTypeChanged: (t) => setState(() => _basicPaintType = t),
              showDivider: false,
            ),
          ),
        ),
        const SizedBox(height: 16),

        _DemoSection(
          title: '2. With Blend Mode',
          description: 'Shows paint type and blend mode dropdowns.',
          brightness: brightness,
          badge: '${_blendPaintType.prettify} · ${_blendMode.label}',
          child: _panelWrap(
            brightness,
            ColorPickerLayersControlPanel(
              paintType: _blendPaintType,
              onPaintTypeChanged: (t) => setState(() => _blendPaintType = t),
              showBlendMode: true,
              blendMode: _blendMode,
              onBlendModeChanged: (m) => setState(() => _blendMode = m),
              showDivider: false,
            ),
          ),
        ),
        const SizedBox(height: 16),

        _DemoSection(
          title: '3. Full Featured (With Page Switcher)',
          description:
              'Complete panel with paint type, blend mode, and library/editor toggle.',
          brightness: brightness,
          badge:
              '${_switcherPaintType.prettify} · ${_switcherBlendMode.label} · ${_pageIndex == 0 ? 'Editor' : 'Library'}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _panelWrap(
                brightness,
                ColorPickerLayersControlPanel(
                  paintType: _switcherPaintType,
                  onPaintTypeChanged: (t) =>
                      setState(() => _switcherPaintType = t),
                  showBlendMode: true,
                  blendMode: _switcherBlendMode,
                  onBlendModeChanged: (m) =>
                      setState(() => _switcherBlendMode = m),
                  showPageSwitcher: true,
                  currentPageIndex: _pageIndex,
                  onPageSwitcherTapped: () {
                    setState(() => _pageIndex = (_pageIndex + 1) % 2);
                  },
                  showDivider: false,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SoftSaaSTokens.secondaryBackground(brightness),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 13,
                      color: SoftSaaSTokens.tertiaryText(brightness),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Page switcher only appears for color-based paint types (Solid, Linear, Radial, Angular). Switch to Image to see it hide.',
                        style: TextStyle(
                          fontSize: 11,
                          color: SoftSaaSTokens.secondaryText(brightness),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _DemoSection(
          title: '4. Limited Paint Types',
          description: 'Only Solid and Linear gradient are available.',
          brightness: brightness,
          badge: _limitedPaintType.prettify,
          child: _panelWrap(
            brightness,
            ColorPickerLayersControlPanel(
              paintType: _limitedPaintType,
              onPaintTypeChanged: (t) => setState(() => _limitedPaintType = t),
              supportedTypes: const [PaintType.solid, PaintType.gradientLinear],
              showDivider: false,
            ),
          ),
        ),
        const SizedBox(height: 16),

        _DemoSection(
          title: '5. Read-Only Mode',
          description:
              'Displays current values as text instead of interactive dropdowns.',
          brightness: brightness,
          child: _panelWrap(
            brightness,
            ColorPickerLayersControlPanel(
              paintType: _readOnlyPaintType,
              showBlendMode: true,
              blendMode: _readOnlyBlendMode,
              readOnly: true,
              showDivider: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _panelWrap(Brightness brightness, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: SoftSaaSTokens.primaryBackground(brightness),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
      ),
      child: child,
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.description,
    required this.brightness,
    this.badge,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;
  final Brightness brightness;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.0,
                  fontWeight: FontWeight.w600,
                  color: SoftSaaSTokens.primaryText(brightness),
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SoftSaaSTokens.primaryColor(
                    brightness,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: SoftSaaSTokens.primaryColor(brightness),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: TextStyle(
            fontSize: 11,
            height: 1.2,
            color: SoftSaaSTokens.tertiaryText(brightness),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
