import 'package:flutter/material.dart';

/// Utilities for popup positioning and height persistence.
///
/// This class provides helper methods for calculating optimal popup positions
/// relative to a trigger widget, and for persisting popup heights across
/// sessions. The positioning algorithm follows a set of rules to ensure the
/// popup stays within screen bounds.
class PopupPositioningUtils {
  /// In-memory cache for persisted popup heights.
  ///
  /// Currently uses a simple map for storage. Can be extended to use
  /// SharedPreferences for persistence across app restarts.
  static final Map<String, double> _heightCache = <String, double>{};

  /// Loads a persisted height for a given key.
  ///
  /// Returns the stored height, or `null` if no height was previously saved
  /// for the given key.
  ///
  /// Example:
  /// ```dart
  /// final height = PopupPositioningUtils.loadPersistedHeight('colorPicker');
  /// ```
  static double? loadPersistedHeight(String? key) {
    if (key == null) return null;
    return _heightCache[key];
  }

  /// Saves a persisted height for a given key.
  ///
  /// The height will be stored in memory and can be retrieved later using
  /// [loadPersistedHeight].
  ///
  /// Example:
  /// ```dart
  /// PopupPositioningUtils.savePersistedHeight('colorPicker', 400.0);
  /// ```
  static void savePersistedHeight(String? key, double height) {
    if (key == null) return;
    _heightCache[key] = height;
  }

  /// Calculates the optimal popup position and adjusted height.
  ///
  /// This method follows a set of positioning rules to ensure the popup stays
  /// within screen bounds:
  ///
  /// 1. **Default positioning**: Prefer opening the popup below the trigger,
  ///    with the popup's top-left corner aligned to the trigger's bottom-left corner.
  ///
  /// 2. **Horizontal overflow**: If there's not enough room on the right, align
  ///    the popup's top-right corner to the trigger's bottom-right corner.
  ///
  /// 3. **Vertical overflow**: If there's not enough room below, move the popup
  ///    above the trigger, following the horizontal rules above.
  ///
  /// 4. **Height adjustment**: If there's not enough room both above and below,
  ///    shrink the popup height to fit within available space (respecting min/max).
  ///
  /// Returns a record containing the calculated position and adjusted height.
  ///
  /// Example:
  /// ```dart
  /// final result = PopupPositioningUtils.calculatePopupPosition(
  ///   context: context,
  ///   triggerBox: triggerRenderBox,
  ///   popupWidth: 300.0,
  ///   popupHeight: 400.0,
  ///   minHeight: 200.0,
  ///   maxHeight: 600.0,
  /// );
  /// final position = result.position;
  /// final height = result.adjustedHeight;
  /// ```
  static ({Offset position, double adjustedHeight}) calculatePopupPosition({
    required BuildContext context,
    required RenderBox triggerBox,
    required double popupWidth,
    required double popupHeight,
    required double minHeight,
    required double maxHeight,
  }) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final Offset triggerPosition = triggerBox.localToGlobal(Offset.zero);
    final Size triggerSize = triggerBox.size;
    
    final double gap = 8.0; // Gap between trigger and popup
    
    // Calculate trigger bottom corners
    final Offset triggerBottomLeft = Offset(triggerPosition.dx, triggerPosition.dy + triggerSize.height);
    final Offset triggerBottomRight = Offset(triggerPosition.dx + triggerSize.width, triggerPosition.dy + triggerSize.height);
    final Offset triggerTopLeft = triggerPosition;
    final Offset triggerTopRight = Offset(triggerPosition.dx + triggerSize.width, triggerPosition.dy);
    
    // Calculate available space (for below positioning)
    final double availableSpaceRightBelow = screenSize.width - triggerBottomRight.dx;
    final double availableSpaceLeftBelow = triggerBottomLeft.dx;
    // Calculate available space (for above positioning)
    final double availableSpaceRightAbove = screenSize.width - triggerTopRight.dx;
    final double availableSpaceLeftAbove = triggerTopLeft.dx;
    
    final double availableHeightBelow = screenSize.height - triggerBottomLeft.dy;
    final double availableHeightAbove = triggerTopLeft.dy;
    
    double adjustedHeight = popupHeight;
    double horizontalPosition;
    double verticalPosition;
    
    // Rule 3: Check if we need to position above first
    if (availableHeightBelow < popupHeight && availableHeightAbove >= popupHeight) {
      // Position above
      verticalPosition = triggerTopLeft.dy - popupHeight - gap;
      
      // Rule 1 & 2: Determine horizontal position (above)
      if (availableSpaceRightAbove >= popupWidth) {
        // Rule 1: Top left of popup aligned to top left of trigger
        horizontalPosition = triggerTopLeft.dx;
      } else if (availableSpaceLeftAbove >= popupWidth) {
        // Rule 2: Top right of popup aligned to top right of trigger
        horizontalPosition = triggerTopRight.dx - popupWidth;
      } else {
        // Not enough space on either side - position to fit within screen
        // Center the popup on screen if it's wider than the screen
        if (popupWidth > screenSize.width) {
          horizontalPosition = 0.0;
        } else {
          // Try to keep as much of the popup visible as possible
          horizontalPosition = (screenSize.width - popupWidth) / 2;
        }
      }
      
      // Check if popup would go off-screen at the top
      if (verticalPosition < 0) {
        // Move popup down as much as needed, but don't go above the trigger
        final double minVerticalPosition = 0.0;
        final double maxVerticalPosition = triggerTopLeft.dy - gap; // Don't move below trigger
        
        if (minVerticalPosition <= maxVerticalPosition) {
          // Can move down enough to fit - adjust position
          verticalPosition = minVerticalPosition;
        } else {
          // Both top and bottom are constrained - need to shrink
          // Calculate available height
          final double availableAtTop = availableHeightAbove;
          adjustedHeight = availableAtTop.clamp(minHeight, maxHeight);
          
          // Position at top with adjusted height
          verticalPosition = 0.0;
          
          // Ensure we don't position below the trigger if there's space
          if (verticalPosition + adjustedHeight > triggerTopLeft.dy - gap && 
              triggerTopLeft.dy - gap - adjustedHeight >= 0) {
            verticalPosition = triggerTopLeft.dy - adjustedHeight - gap;
          }
        }
      }
    } else {
      // Position below (default)
      verticalPosition = triggerBottomLeft.dy + gap;
      
      // Rule 1 & 2: Determine horizontal position (below)
      if (availableSpaceRightBelow >= popupWidth) {
        // Rule 1: Top left of popup aligned to bottom left of trigger
        horizontalPosition = triggerBottomLeft.dx;
      } else if (availableSpaceLeftBelow >= popupWidth) {
        // Rule 2: Top right of popup aligned to bottom right of trigger
        horizontalPosition = triggerBottomRight.dx - popupWidth;
      } else {
        // Not enough space on either side - position to fit within screen
        // Center the popup on screen if it's wider than the screen
        if (popupWidth > screenSize.width) {
          horizontalPosition = 0.0;
        } else {
          // Try to keep as much of the popup visible as possible
          horizontalPosition = (screenSize.width - popupWidth) / 2;
        }
      }
      
      // Check if popup would go off-screen at the bottom
      final double popupBottom = verticalPosition + popupHeight;
      if (popupBottom > screenSize.height) {
        // Move popup up as much as needed to fit on screen
        final double maxVerticalPosition = screenSize.height - popupHeight;
        
        if (maxVerticalPosition >= 0) {
          // Can move up enough to fit - adjust position (can go above trigger if needed)
          verticalPosition = maxVerticalPosition;
        } else {
          // Both top and bottom are constrained - need to shrink
          // Calculate available height from top of screen
          final double availableAtTop = screenSize.height;
          adjustedHeight = availableAtTop.clamp(minHeight, maxHeight);
          
          // Position at top with adjusted height
          verticalPosition = 0.0;
        }
      }
    }
    
    // Clamp positions to screen bounds (with safe checks)
    final double minX = 0.0;
    final double maxX = screenSize.width - popupWidth;
    final double clampedX = maxX >= minX 
        ? horizontalPosition.clamp(minX, maxX)
        : 0.0; // If popup is wider than screen, position at left edge
    
    final double minY = 0.0;
    final double maxY = screenSize.height - adjustedHeight;
    final double clampedY = maxY >= minY
        ? verticalPosition.clamp(minY, maxY)
        : 0.0; // If popup is taller than screen, position at top edge
    
    return (position: Offset(clampedX, clampedY), adjustedHeight: adjustedHeight);
  }
}
