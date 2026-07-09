import 'package:flutter/material.dart';

import '../models/paint_swatch.dart';
import 'color_picker_storage.dart';

/// Helper class to manage recent colors with automatic persistence.
/// 
/// This class handles loading recent colors from storage on initialization,
/// adding new colors, and automatically saving changes to SharedPreferences.
/// 
/// Usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> {
///   late final RecentColorsManager _recentColorsManager;
/// 
///   @override
///   void initState() {
///     super.initState();
///     _recentColorsManager = RecentColorsManager()
///       ..loadRecentColors();
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return RecentColorsView(
///       swatches: _recentColorsManager.swatches,
///       onSelected: (swatch) { /* handle selection */ },
///       onAddAsNew: () {
///         _recentColorsManager.addSwatch(
///           PaintSwatch.fromColor(currentColor),
///         );
///         setState(() {});
///       },
///     );
///   }
/// }
/// ```
class RecentColorsManager extends ChangeNotifier {
  /// Shared singleton — all [ColorPickerTrigger] instances use this so that
  /// recent colors added in one picker are immediately visible in every other
  /// open picker without requiring a SharedPreferences round-trip.
  static final RecentColorsManager shared = RecentColorsManager._();

  // ignore: unused_element_parameter
  RecentColorsManager._({this.maxItems = ColorPickerStorage.maxRecentColors});

  List<PaintSwatch> _swatches = [];
  bool _isLoaded = false;
  bool _isDisposed = false;

  /// Current list of recent color swatches.
  List<PaintSwatch> get swatches => _swatches;

  /// Whether recent colors have been loaded from storage.
  bool get isLoaded => _isLoaded;

  /// Maximum number of recent colors to keep (default: 24).
  final int maxItems;

  factory RecentColorsManager() => shared;

  /// Load recent colors from SharedPreferences.
  /// Call this in initState or whenever you want to refresh from storage.
  Future<void> loadRecentColors() async {
    _swatches = await ColorPickerStorage.loadRecentColors();
    _isLoaded = true;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Add a new swatch to recent colors.
  /// Automatically removes duplicates, adds to the beginning,
  /// trims to max size, and saves to storage.
  Future<void> addSwatch(PaintSwatch swatch) async {
    _swatches = await ColorPickerStorage.addToRecentColors(swatch, _swatches);
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Add a color to recent colors (convenience method).
  Future<void> addColor(Color color) async {
    await addSwatch(PaintSwatch.fromColor(color));
  }

  /// Clear all recent colors.
  Future<void> clear() async {
    _swatches = [];
    await ColorPickerStorage.saveRecentColors(_swatches);
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Manually save current swatches to storage.
  /// Usually not needed as addSwatch automatically saves.
  Future<void> save() async {
    await ColorPickerStorage.saveRecentColors(_swatches);
  }

  @override
  void dispose() {
    // Never dispose the shared singleton — callers that hold a reference via
    // the factory constructor or RecentColorsManager.shared must not kill the
    // singleton's ChangeNotifier state. Use removeListener instead.
    if (this == shared) return;
    _isDisposed = true;
    super.dispose();
  }
}

