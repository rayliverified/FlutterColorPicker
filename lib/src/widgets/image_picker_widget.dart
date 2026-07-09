import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Callback for when an image is selected.
typedef ImageSelectedCallback = void Function(Uint8List bytes, String name);

/// Simple image picker widget that displays a button to pick images.
/// 
/// This widget provides a basic UI for image selection. Consumers can provide
/// their own image picking logic via the [onImageSelected] callback.
class ImagePickerWidget extends StatelessWidget {
  /// Currently selected image bytes (for preview).
  final Uint8List? imageBytes;
  
  /// Name of the currently selected image.
  final String? imageName;
  
  /// Called when user wants to pick an image.
  final VoidCallback onPickImage;
  
  /// Called when user wants to clear the selected image.
  final VoidCallback? onClearImage;
  
  /// Read-only mode.
  final bool readOnly;
  
  /// Height of the preview area.
  final double? previewHeight;

  const ImagePickerWidget({
    super.key,
    this.imageBytes,
    this.imageName,
    required this.onPickImage,
    this.onClearImage,
    this.readOnly = false,
    this.previewHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Preview area
          if (imageBytes != null) ...[
            Container(
              height: previewHeight,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (imageName != null)
              Text(
                imageName!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            if (!readOnly && onClearImage != null)
              ElevatedButton.icon(
                onPressed: onClearImage,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                ),
              ),
          ] else ...[
            // No image selected - show pick button
            Container(
              height: previewHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surface,
              ),
              child: InkWell(
                onTap: readOnly ? null : onPickImage,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: readOnly 
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
                          : colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No image selected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: readOnly 
                            ? colorScheme.onSurface.withValues(alpha: 0.38)
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (!readOnly)
                      Text(
                        'Tap to select image',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Pick image button (always show if no image, or as secondary action)
          if (!readOnly)
            ElevatedButton.icon(
              onPressed: onPickImage,
              icon: Icon(
                imageBytes != null ? Icons.change_circle_outlined : Icons.add_photo_alternate_outlined,
                size: 18,
              ),
              label: Text(imageBytes != null ? 'Change Image' : 'Pick Image'),
            ),
        ],
      ),
    );
  }
}

