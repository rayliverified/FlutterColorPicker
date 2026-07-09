import 'dart:typed_data';

import 'package:color_picker_plus/color_picker_plus.dart';
import 'package:flutter/material.dart';

/// Widget that displays the selected color or image preview.
class ColorPreviewCard extends StatelessWidget {
  final Color color;
  final Uint8List? imageBytes;
  final String? imageName;

  const ColorPreviewCard({
    super.key,
    required this.color,
    this.imageBytes,
    this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Text(
              imageBytes != null ? 'Selected Image' : 'Selected Color',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: imageBytes == null ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(imageBytes!, fit: BoxFit.cover),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            if (imageBytes != null) ...[
              Text(
                imageName ?? 'image.png',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(imageBytes!.length / 1024).toStringAsFixed(1)} KB',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else ...[
              Text(
                colorToHex(color, withHashtag: true),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Opacity: ${(color.a * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
