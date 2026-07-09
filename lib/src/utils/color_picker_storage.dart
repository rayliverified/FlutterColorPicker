import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/paint_swatch.dart';
import '../models/color_stop.dart';
import '../widgets/color_picker.dart' show PaintType;

/// Storage service for color picker data (recent colors, preferences).
///
/// This class provides static methods for persisting color picker data using
/// SharedPreferences. It handles serialization and deserialization of paint
/// swatches and manages the maximum number of recent colors.
///
/// Example:
/// ```dart
/// // Save recent colors
/// await ColorPickerStorage.saveRecentColors(swatches);
///
/// // Load recent colors
/// final swatches = await ColorPickerStorage.loadRecentColors();
///
/// // Add a new color to recent colors
/// final updated = await ColorPickerStorage.addToRecentColors(
///   newSwatch,
///   currentSwatches,
/// );
/// ```
class ColorPickerStorage {
  static const String _keyRecentColors = 'color_picker_recent_colors';
  static const String _keyLastPresetLibrary = 'color_picker_last_preset_library';
  static const int maxRecentColors = 24;

  /// Saves recent colors to SharedPreferences.
  ///
  /// Only the first [maxRecentColors] swatches are saved. If the list contains
  /// more than the maximum, only the first items are persisted.
  ///
  /// Errors during saving are silently ignored.
  static Future<void> saveRecentColors(List<PaintSwatch> swatches) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> serializedSwatches = swatches
          .take(maxRecentColors)
          .map((swatch) => _serializePaintSwatch(swatch))
          .toList();
      await prefs.setStringList(_keyRecentColors, serializedSwatches);
    } catch (e) {
      // Error saving recent colors - silently fail
    }
  }

  /// Loads recent colors from SharedPreferences.
  ///
  /// Returns an empty list if no colors were previously saved or if an error
  /// occurs during loading.
  static Future<List<PaintSwatch>> loadRecentColors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? serializedSwatches = prefs.getStringList(_keyRecentColors);
      if (serializedSwatches == null || serializedSwatches.isEmpty) {
        return [];
      }
      return serializedSwatches
          .map((json) => _deserializePaintSwatch(json))
          .whereType<PaintSwatch>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Adds a swatch to recent colors and saves to storage.
  ///
  /// This method:
  /// - Removes any duplicate of the new swatch from the list
  /// - Adds the new swatch at the beginning
  /// - Trims the list to [maxRecentColors] items
  /// - Saves the updated list to storage
  ///
  /// Returns the updated list of recent color swatches.
  static Future<List<PaintSwatch>> addToRecentColors(
    PaintSwatch swatch,
    List<PaintSwatch> currentSwatches,
  ) async {
    // Remove duplicate if exists
    final updatedSwatches = currentSwatches.where((s) => s != swatch).toList();
    
    // Add new swatch at the beginning
    updatedSwatches.insert(0, swatch);
    
    // Trim to max size
    final trimmedSwatches = updatedSwatches.take(maxRecentColors).toList();
    
    // Save to storage
    await saveRecentColors(trimmedSwatches);
    
    return trimmedSwatches;
  }

  /// Saves the last selected preset library name.
  ///
  /// This allows the color picker to remember which preset library the user
  /// was viewing, so it can be restored on the next session.
  ///
  /// Errors during saving are silently ignored.
  static Future<void> saveLastPresetLibrary(String libraryName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastPresetLibrary, libraryName);
    } catch (e) {
      // Error saving last preset library - silently fail
    }
  }

  /// Loads the last selected preset library name.
  ///
  /// Returns the saved library name, or `null` if no library was previously
  /// saved or if an error occurs during loading.
  static Future<String?> loadLastPresetLibrary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLastPresetLibrary);
    } catch (e) {
      return null;
    }
  }

  /// Serializes a [PaintSwatch] to a JSON string.
  ///
  /// This is an internal method used for storage. The format includes paint
  /// type, color, and gradient properties if applicable.
  static String _serializePaintSwatch(PaintSwatch swatch) {
    final Map<String, dynamic> json = {
      'paintType': swatch.paintType.name,
      'color': swatch.color.toARGB32(),
    };

    if (swatch.gradientStops != null) {
      json['gradientStops'] = swatch.gradientStops!.map((stop) {
        return {
          'position': stop.position,
          'color': stop.color.toARGB32(),
        };
      }).toList();
    }

    if (swatch.gradientAngle != null) {
      json['gradientAngle'] = swatch.gradientAngle;
    }

    if (swatch.gradientOpacity != null) {
      json['gradientOpacity'] = swatch.gradientOpacity;
    }

    return jsonEncode(json);
  }

  /// Deserializes a [PaintSwatch] from a JSON string.
  ///
  /// This is an internal method used for loading from storage. Returns `null`
  /// if the JSON is invalid or cannot be parsed.
  static PaintSwatch? _deserializePaintSwatch(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      final paintTypeName = json['paintType'] as String;
      final PaintType paintType = PaintType.values.firstWhere(
        (type) => type.name == paintTypeName,
        orElse: () => PaintType.solid,
      );

      final color = Color(json['color'] as int);

      if (paintType == PaintType.solid) {
        return PaintSwatch.solid(color: color);
      } else {
        final List<dynamic>? stopsJson = json['gradientStops'] as List<dynamic>?;
        if (stopsJson == null || stopsJson.isEmpty) {
          return null;
        }

        final List<ColorStop> stops = stopsJson.map((stopJson) {
          return ColorStop(
            position: (stopJson['position'] as num).toDouble(),
            color: Color(stopJson['color'] as int),
          );
        }).toList();

        return PaintSwatch.gradient(
          paintType: paintType,
          gradientStops: stops,
          color: color,
          gradientAngle: json['gradientAngle'] as double?,
          gradientOpacity: json['gradientOpacity'] as double?,
        );
      }
    } catch (e) {
      return null;
    }
  }
}

