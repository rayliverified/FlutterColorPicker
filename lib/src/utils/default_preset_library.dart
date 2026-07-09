import 'package:flutter/material.dart';

import '../models/paint_swatch.dart';
import '../widgets/recent_colors_view.dart' show PresetLibraryEntry;

/// Default preset library for the Codelessly Color Picker.
/// 
/// Provides beautiful, curated color palettes inspired by popular design systems
/// and modern SaaS applications. Users can override these with their own custom
/// presets, but these are provided by default if no custom presets are specified.
class DefaultPresetLibrary {
  /// Returns the complete default preset library.
  /// 
  /// This is the main API for accessing default presets. Use this method
  /// to get all preset library entries.
  static List<PresetLibraryEntry> get all => [
        // Theme Colors
        codelessly,
        material3,
        apple,
        google,
        discord,
        github,
        vsCode,
        storybook,
        // Modern SaaS Themes
        slack,
        tailwind,
      ];

  /// Codelessly brand colors - Modern blue-based palette
  static final PresetLibraryEntry codelessly = PresetLibraryEntry.fromColors(
    name: 'Codelessly',
    colors: const [
      // Primary Blues
      Color(0xFF5C69E5), // Primary Blue
      Color(0xFF6C77E5), // Primary Container
      Color(0xFF4A56D3), // Dark Blue
      Color(0xFF7C8AFF), // Light Blue
      Color(0xFF3D47B0), // Darker Blue
      Color(0xFF9BA3FF), // Lighter Blue
      // Secondary Grays
      Color(0xFFA4AAC1), // Secondary Gray
      Color(0xFF8B92A8), // Dark Gray
      Color(0xFFBCC1D4), // Light Gray
      Color(0xFFEEF0F9), // Light Background
      Color(0xFFFAFAFA), // Off White
      Color(0xFF222222), // Near Black
      // Status Colors
      Color(0xFFEB4848), // Error Red
      Color(0xFFF87171), // Light Red
      Color(0xFF34D399), // Success Green
      Color(0xFF10B981), // Dark Green
      Color(0xFFFBBF24), // Warning Yellow
      Color(0xFFF59E0B), // Amber
    ],
  );

  /// Material Design 3 - Google's modern design system
  static final PresetLibraryEntry material3 = PresetLibraryEntry.fromColors(
    name: 'Material 3',
    colors: const [
      // Primary
      Color(0xFF0B57D0), // M3 Primary Blue
      Color(0xFF1A73E8), // M3 Primary Light
      Color(0xFF004A77), // M3 Primary Dark
      Color(0xFFD3E3FD), // Primary Container
      // Secondary
      Color(0xFF5E5E5E), // On Surface Variant
      Color(0xFF3C4043), // On Surface
      Color(0xFF80868B), // Medium Emphasis
      // Surface & Background
      Color(0xFFFFFFFF), // Surface
      Color(0xFFF7F7F7), // Surface Variant
      Color(0xFFE8F0FE), // Surface Tint
      Color(0xFFF8F9FA), // Background
      // Outline
      Color(0xFFE0E0E0), // Outline
      Color(0xFFDADCE0), // Outline Variant
      Color(0xFFC4C7C5), // Divider
      // Semantic
      Color(0xFFB3261E), // Error
      Color(0xFFF2B8B5), // Error Container
      Color(0xFF34A853), // Success
      Color(0xFFFBBC04), // Warning
    ],
  );

  /// Apple iOS inspired colors - Clean and modern
  static final PresetLibraryEntry apple = PresetLibraryEntry.fromColors(
    name: 'iOS',
    colors: const [
      // System Colors
      Color(0xFF007AFF), // iOS Blue
      Color(0xFF5856D6), // iOS Purple
      Color(0xFFAF52DE), // iOS Pink
      Color(0xFFFF2D55), // iOS Red
      Color(0xFFFF9500), // iOS Orange
      Color(0xFFFFCC00), // iOS Yellow
      Color(0xFF34C759), // iOS Green
      Color(0xFF00C7BE), // iOS Teal
      Color(0xFF32ADE6), // iOS Sky Blue
      Color(0xFF5AC8FA), // iOS Cyan
      Color(0xFFFF453A), // iOS Red (Dark)
      Color(0xFFBF5AF2), // iOS Purple (Dark)
      // Grays
      Color(0xFF8E8E93), // iOS Gray
      Color(0xFFC7C7CC), // iOS Gray 2
      Color(0xFFD1D1D6), // iOS Gray 3
      Color(0xFFE5E5EA), // iOS Gray 4
      Color(0xFFF2F2F7), // iOS Gray 5
      Color(0xFFFFFFFF), // White
      Color(0xFF000000), // Black
    ],
  );

  /// Google Material Design colors - Bold and vibrant
  static final PresetLibraryEntry google = PresetLibraryEntry.fromColors(
    name: 'Google',
    colors: const [
      // Google Brand Colors
      Color(0xFF4285F4), // Google Blue
      Color(0xFFDB4437), // Google Red
      Color(0xFFF4B400), // Google Yellow
      Color(0xFF0F9D58), // Google Green
      // Material Blues
      Color(0xFF1A73E8), // Material Blue
      Color(0xFF1967D2), // Dark Blue
      Color(0xFF4285F4), // Medium Blue
      Color(0xFF669DF6), // Light Blue
      Color(0xFFD2E3FC), // Pale Blue
      // Material Colors
      Color(0xFFE8710A), // Material Orange
      Color(0xFFF9AB00), // Material Amber
      Color(0xFFFBBC04), // Yellow
      Color(0xFF34A853), // Material Green
      Color(0xFF188038), // Dark Green
      Color(0xFF9334E6), // Material Purple
      Color(0xFFEA4335), // Bright Red
      Color(0xFFC5221F), // Dark Red
      // Additional
      Color(0xFF00BCD4), // Cyan
      Color(0xFFFF6F00), // Deep Orange
    ],
  );

  /// Discord - Dark gaming communication platform
  static final PresetLibraryEntry discord = PresetLibraryEntry.fromColors(
    name: 'Discord',
    colors: const [
      // Brand Colors
      Color(0xFF5865F2), // Blurple (Primary)
      Color(0xFF4752C4), // Dark Blurple
      Color(0xFF3C45A5), // Darker Blurple
      Color(0xFFEB459E), // Fuchsia
      // Status Colors
      Color(0xFF57F287), // Green (Success)
      Color(0xFF3BA55D), // Dark Green
      Color(0xFFFEE75C), // Yellow (Warning)
      Color(0xFFFAA81A), // Orange
      Color(0xFFED4245), // Red (Danger)
      Color(0xFFF23F43), // Bright Red
      // Background Colors
      Color(0xFF23272A), // Almost Black
      Color(0xFF2C2F33), // Dark Background
      Color(0xFF2F3136), // Background
      Color(0xFF36393F), // Elevated Background
      Color(0xFF40444B), // Secondary Background
      // Text Colors
      Color(0xFFFFFFFF), // White
      Color(0xFFDCDDDE), // Text
      Color(0xFFB9BBBE), // Muted Text
      Color(0xFF99AAB5), // Secondary Text
      Color(0xFF72767D), // Tertiary Text
    ],
  );

  /// GitHub - Developer collaboration platform
  static final PresetLibraryEntry github = PresetLibraryEntry.fromColors(
    name: 'GitHub',
    colors: const [
      // Accent Colors
      Color(0xFF0969DA), // Accent Blue
      Color(0xFF1F6FEB), // Blue Light
      Color(0xFF388BFD), // Blue Lighter
      Color(0xFF54AEFF), // Bright Blue
      Color(0xFF8250DF), // Done Purple
      Color(0xFF8957E5), // Purple Light
      // Status Colors
      Color(0xFF238636), // Success Green
      Color(0xFF2EA043), // Green Light
      Color(0xFF3FB950), // Bright Green
      Color(0xFFCF222E), // Danger Red
      Color(0xFFDA3633), // Red Light
      Color(0xFFFF7B72), // Coral
      Color(0xFFBF8700), // Attention Orange
      Color(0xFFD29922), // Severe Orange
      // Dark Theme Canvas
      Color(0xFF0D1117), // Canvas Default
      Color(0xFF161B22), // Canvas Subtle
      Color(0xFF21262D), // Canvas Inset
      Color(0xFF30363D), // Border
      // Dark Theme Text
      Color(0xFFC9D1D9), // Foreground Default
      Color(0xFF8B949E), // Foreground Muted
      Color(0xFF484F58), // Foreground Subtle
      // Light Theme
      Color(0xFFFFFFFF), // White
      Color(0xFFF6F8FA), // Canvas Light
      Color(0xFF24292F), // Text Dark
    ],
  );

  /// VS Code - Popular code editor
  static final PresetLibraryEntry vsCode = PresetLibraryEntry.fromColors(
    name: 'VS Code',
    colors: const [
      // UI Colors
      Color(0xFF007ACC), // Primary Blue
      Color(0xFF0098FF), // Info Blue
      Color(0xFF14B8A6), // Accent Teal
      // Syntax Highlighting
      Color(0xFF4EC9B0), // Teal (Class)
      Color(0xFF569CD6), // Light Blue (Function)
      Color(0xFF9CDCFE), // Sky Blue (Parameter)
      Color(0xFFDCDCAA), // Yellow (Variable)
      Color(0xFFCE9178), // Orange (String)
      Color(0xFFB5CEA8), // Light Green (Number)
      Color(0xFFC586C0), // Pink (Keyword)
      Color(0xFF4FC1FF), // Bright Blue (Type)
      Color(0xFFD16969), // Red (Invalid)
      Color(0xFF6A9955), // Green (Comment)
      // Background Colors
      Color(0xFF1E1E1E), // Editor Background
      Color(0xFF252526), // Sidebar Background
      Color(0xFF2D2D30), // Panel Background
      Color(0xFF3E3E42), // Input Background
      Color(0xFF007ACC), // Selection Background
      // Text Colors
      Color(0xFFD4D4D4), // Foreground
      Color(0xFF858585), // Comment Gray
      Color(0xFFC5C5C5), // Light Gray
      Color(0xFF808080), // Medium Gray
      Color(0xFF505050), // Dark Gray
      Color(0xFFFFFFFF), // White
    ],
  );

  /// Storybook - Component development environment
  static final PresetLibraryEntry storybook = PresetLibraryEntry.fromColors(
    name: 'Storybook',
    colors: const [
      // Brand Colors
      Color(0xFFFF4785), // Primary Pink
      Color(0xFFFC521F), // Orange
      Color(0xFF1EA7FD), // Secondary Blue
      Color(0xFF029CFD), // Info Blue
      Color(0xFF37D5D3), // Teal
      // Status Colors
      Color(0xFF66BF3C), // Success Green
      Color(0xFF2CC84D), // Positive Green
      Color(0xFFFFAE00), // Alert Yellow
      Color(0xFFFBCA3E), // Warning
      Color(0xFFE02020), // Error Red
      // Neutral Colors
      Color(0xFF333333), // Dark Gray
      Color(0xFF666666), // Medium Dark Gray
      Color(0xFF999999), // Medium Gray
      Color(0xFFCCCCCC), // Light Medium Gray
      Color(0xFFEEEEEE), // Light Gray
      Color(0xFFF6F9FC), // Pale Blue Gray
      Color(0xFFFFFFFF), // White
      // Additional
      Color(0xFF0051AB), // Dark Blue
      Color(0xFF00A3F3), // Bright Blue
      Color(0xFF1BE2CC), // Bright Teal
      Color(0xFF30C8A6), // Seafoam
    ],
  );

  /// Slack - Business communication
  static final PresetLibraryEntry slack = PresetLibraryEntry.fromColors(
    name: 'Slack',
    colors: const [
      // Brand Colors
      Color(0xFF611F69), // Aubergine
      Color(0xFF4A154B), // Dark Purple
      Color(0xFFE01E5A), // Red/Pink
      Color(0xFFECB22E), // Yellow
      Color(0xFF36C5F0), // Cyan
      Color(0xFF2EB67D), // Green
      // Additional Brand
      Color(0xFFE8912D), // Orange
      Color(0xFFCC4400), // Dark Orange
      Color(0xFF007A5A), // Dark Green
      Color(0xFF1264A3), // Link Blue
      Color(0xFF0B4C8C), // Dark Blue
      // Background Colors
      Color(0xFF1D1C1D), // Black
      Color(0xFF222222), // Near Black
      Color(0xFF444444), // Dark Gray
      Color(0xFF888888), // Medium Gray
      Color(0xFFDDDDDD), // Light Gray
      Color(0xFFF8F8F8), // Off White
      Color(0xFFFFFFFF), // White
      // Text Colors
      Color(0xFF1D1C1D), // Text Black
      Color(0xFF454245), // Text Gray
      Color(0xFF616061), // Secondary Text
      Color(0xFF868686), // Tertiary Text
    ],
  );

  /// Tailwind CSS - Utility-first CSS framework
  static final PresetLibraryEntry tailwind = PresetLibraryEntry.fromColors(
    name: 'Tailwind',
    colors: const [
      // Blues
      Color(0xFF0EA5E9), // Sky 500
      Color(0xFF3B82F6), // Blue 500
      Color(0xFF2563EB), // Blue 600
      Color(0xFF1D4ED8), // Blue 700
      // Cyans & Teals
      Color(0xFF06B6D4), // Cyan 500
      Color(0xFF0891B2), // Cyan 600
      Color(0xFF14B8A6), // Teal 500
      Color(0xFF0D9488), // Teal 600
      // Greens
      Color(0xFF10B981), // Emerald 500
      Color(0xFF059669), // Emerald 600
      Color(0xFF22C55E), // Green 500
      Color(0xFF16A34A), // Green 600
      Color(0xFF84CC16), // Lime 500
      // Yellows & Oranges
      Color(0xFFFBBF24), // Yellow 400
      Color(0xFFF59E0B), // Amber 500
      Color(0xFFF97316), // Orange 500
      Color(0xFFEA580C), // Orange 600
      // Reds & Pinks
      Color(0xFFEF4444), // Red 500
      Color(0xFFDC2626), // Red 600
      Color(0xFFF43F5E), // Rose 500
      Color(0xFFEC4899), // Pink 500
      // Purples
      Color(0xFFD946EF), // Fuchsia 500
      Color(0xFFA855F7), // Purple 500
      Color(0xFF8B5CF6), // Violet 500
      Color(0xFF6366F1), // Indigo 500
      // Grays
      Color(0xFF1F2937), // Gray 800
      Color(0xFF374151), // Gray 700
      Color(0xFF6B7280), // Gray 500
      Color(0xFF9CA3AF), // Gray 400
      Color(0xFFD1D5DB), // Gray 300
      Color(0xFFF3F4F6), // Gray 100
    ],
  );

  /// Get preset library entry by name (case-insensitive).
  static PresetLibraryEntry? getByName(String name) {
    try {
      return all.firstWhere(
        (entry) => entry.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get just the color swatches from a preset library entry.
  static List<PaintSwatch> getSwatches(String name) {
    final entry = getByName(name);
    return entry?.swatches ?? [];
  }
}

