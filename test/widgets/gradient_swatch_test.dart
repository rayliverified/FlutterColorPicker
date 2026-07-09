import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:colorpicker/colorpicker.dart';

void main() {
  group('Gradient Swatch Creation', () {
    test('PaintSwatch.fromGradient creates swatch with correct properties', () {
      final stops = [
        const ColorStop(position: 0.0, color: Colors.red),
        const ColorStop(position: 1.0, color: Colors.blue),
      ];

      final swatch = PaintSwatch.fromGradient(
        paintType: PaintType.gradientLinear,
        gradientStops: stops,
        gradientAngle: 45.0,
        gradientOpacity: 0.8,
      );

      expect(swatch.paintType, equals(PaintType.gradientLinear));
      expect(swatch.gradientStops, equals(stops));
      expect(swatch.gradientAngle, equals(45.0));
      expect(swatch.gradientOpacity, equals(0.8));
      expect(swatch.isGradient, isTrue);
    });

    test('PaintSwatch.fromGradient with null opacity', () {
      final stops = [
        const ColorStop(position: 0.0, color: Colors.red),
        const ColorStop(position: 1.0, color: Colors.blue),
      ];

      final swatch = PaintSwatch.fromGradient(
        paintType: PaintType.gradientLinear,
        gradientStops: stops,
        gradientAngle: 45.0,
        gradientOpacity: null,
      );

      expect(swatch.paintType, equals(PaintType.gradientLinear));
      expect(swatch.gradientStops, equals(stops));
      expect(swatch.gradientAngle, equals(45.0));
      expect(swatch.gradientOpacity, isNull);
      expect(swatch.isGradient, isTrue);
    });

    test('Gradient swatches with same properties are equal', () {
      final stops = [
        const ColorStop(position: 0.0, color: Colors.red),
        const ColorStop(position: 1.0, color: Colors.blue),
      ];

      final swatch1 = PaintSwatch.fromGradient(
        paintType: PaintType.gradientLinear,
        gradientStops: stops,
        gradientAngle: 45.0,
        gradientOpacity: 0.8,
      );

      final swatch2 = PaintSwatch.fromGradient(
        paintType: PaintType.gradientLinear,
        gradientStops: stops,
        gradientAngle: 45.0,
        gradientOpacity: 0.8,
      );

      expect(swatch1, equals(swatch2));
    });

    test('Gradient swatches with different opacity are not equal', () {
      final stops = [
        const ColorStop(position: 0.0, color: Colors.red),
        const ColorStop(position: 1.0, color: Colors.blue),
      ];

      final swatch1 = PaintSwatch.fromGradient(
        paintType: PaintType.gradientLinear,
        gradientStops: stops,
        gradientAngle: 45.0,
        gradientOpacity: 0.8,
      );

      final swatch2 = PaintSwatch.fromGradient(
        paintType: PaintType.gradientLinear,
        gradientStops: stops,
        gradientAngle: 45.0,
        gradientOpacity: 0.5,
      );

      expect(swatch1, isNot(equals(swatch2)));
    });

    test(
      'Gradient swatch with null opacity is different from swatch with opacity',
      () {
        final stops = [
          const ColorStop(position: 0.0, color: Colors.red),
          const ColorStop(position: 1.0, color: Colors.blue),
        ];

        final swatch1 = PaintSwatch.fromGradient(
          paintType: PaintType.gradientLinear,
          gradientStops: stops,
          gradientAngle: 45.0,
          gradientOpacity: null,
        );

        final swatch2 = PaintSwatch.fromGradient(
          paintType: PaintType.gradientLinear,
          gradientStops: stops,
          gradientAngle: 45.0,
          gradientOpacity: 1.0,
        );

        expect(swatch1, isNot(equals(swatch2)));
      },
    );
  });

}
