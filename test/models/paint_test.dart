import 'package:flutter/material.dart' hide Paint;
import 'package:flutter_test/flutter_test.dart';

import 'package:color_picker_plus/color_picker_plus.dart';

void main() {
  group('Paint Model Tests', () {
    group('Value Equality', () {
      test('Solid paints with same color are equal', () {
        final paint1 = PaintData.solid(color: Colors.blue);
        final paint2 = PaintData.solid(color: Colors.blue);

        expect(paint1, equals(paint2));
        expect(paint1.hashCode, equals(paint2.hashCode));
      });

      test('Solid paints with different colors are not equal', () {
        final paint1 = PaintData.solid(color: Colors.blue);
        final paint2 = PaintData.solid(color: Colors.red);

        expect(paint1, isNot(equals(paint2)));
      });

      test('Gradient paints with same properties are equal', () {
        final stops = [
          ColorStop(position: 0.0, color: Colors.red),
          ColorStop(position: 1.0, color: Colors.blue),
        ];

        final paint1 = PaintData.linearGradient(stops: stops, angle: 45);
        final paint2 = PaintData.linearGradient(stops: stops, angle: 45);

        expect(paint1, equals(paint2));
        expect(paint1.hashCode, equals(paint2.hashCode));
      });

      test('Gradient paints with different angles are not equal', () {
        final stops = [
          ColorStop(position: 0.0, color: Colors.red),
          ColorStop(position: 1.0, color: Colors.blue),
        ];

        final paint1 = PaintData.linearGradient(stops: stops, angle: 45);
        final paint2 = PaintData.linearGradient(stops: stops, angle: 90);

        expect(paint1, isNot(equals(paint2)));
      });

      test('Gradient paints with different stops are not equal', () {
        final stops1 = [
          ColorStop(position: 0.0, color: Colors.red),
          ColorStop(position: 1.0, color: Colors.blue),
        ];

        final stops2 = [
          ColorStop(position: 0.0, color: Colors.green),
          ColorStop(position: 1.0, color: Colors.yellow),
        ];

        final paint1 = PaintData.linearGradient(stops: stops1);
        final paint2 = PaintData.linearGradient(stops: stops2);

        expect(paint1, isNot(equals(paint2)));
      });
    });

    group('Change Detection', () {
      test('Change detection using equality', () {
        final oldPaint = PaintData.solid(color: Colors.blue);
        var currentPaint = oldPaint;

        // No change
        expect(oldPaint != currentPaint, isFalse);

        // Change detected
        currentPaint = PaintData.solid(color: Colors.red);
        expect(oldPaint != currentPaint, isTrue);
      });

      test('Can be used in Set for detecting duplicates', () {
        final paint1 = PaintData.solid(color: Colors.blue);
        final paint2 = PaintData.solid(color: Colors.blue); // Duplicate
        final paint3 = PaintData.solid(color: Colors.red);

        final uniquePaints = {paint1, paint2, paint3};

        expect(uniquePaints.length, equals(2)); // Only 2 unique paints
        expect(uniquePaints.contains(paint1), isTrue);
        expect(uniquePaints.contains(paint3), isTrue);
      });
    });

    group('Undo/Redo Simulation', () {
      test('Undo/redo is trivial with Paint model', () {
        // History stack
        final history = <PaintData>[];

        // Initial paint
        var currentPaint = PaintData.solid(color: Colors.blue);
        history.add(currentPaint);

        // Change 1
        currentPaint = PaintData.solid(color: Colors.red);
        history.add(currentPaint);

        // Change 2
        currentPaint = PaintData.solid(color: Colors.green);
        history.add(currentPaint);

        expect(history.length, equals(3));

        // Undo to Change 1
        currentPaint = history[history.length - 2];
        expect(currentPaint.color, equals(Colors.red));

        // Undo to initial
        currentPaint = history[0];
        expect(currentPaint.color, equals(Colors.blue));

        // Redo to Change 2
        currentPaint = history[2];
        expect(currentPaint.color, equals(Colors.green));
      });
    });

    group('CopyWith', () {
      test('CopyWith creates new instance with updated values', () {
        final original = PaintData.solid(
          color: Colors.blue,
          blendMode: BlendModeType.normal,
        );

        final updated = original.copyWith(color: Colors.red);

        expect(updated.color, equals(Colors.red));
        expect(updated.blendMode, equals(BlendModeType.normal));
        expect(updated, isNot(equals(original)));
      });

      test('CopyWith on gradient updates angle', () {
        final stops = [
          ColorStop(position: 0.0, color: Colors.red),
          ColorStop(position: 1.0, color: Colors.blue),
        ];

        final original = PaintData.linearGradient(stops: stops, angle: 45);
        final updated = original.copyWith(gradientAngle: 90);

        expect(updated.gradientAngle, equals(90));
        expect(updated.gradientStops, equals(original.gradientStops));
      });
    });

    group('JSON Serialization', () {
      test('Solid paint can be serialized and deserialized', () {
        final original = PaintData.solid(
          color: const Color(0xFF2196F3),
        ); // Blue
        final json = original.toJson();
        final restored = PaintData.fromJson(json);

        expect(restored, equals(original));
        expect(restored.color, equals(original.color));
      });

      test('Gradient paint can be serialized and deserialized', () {
        const stops = [
          ColorStop(position: 0.0, color: Color(0xFFF44336)), // Red
          ColorStop(position: 1.0, color: Color(0xFF2196F3)), // Blue
        ];

        final original = PaintData.linearGradient(stops: stops, angle: 45);
        final json = original.toJson();
        final restored = PaintData.fromJson(json);

        expect(restored, equals(original));
        expect(restored.gradientAngle, equals(45));
        expect(restored.gradientStops?.length, equals(2));
        expect(restored.gradientStops![0].color, equals(stops[0].color));
        expect(restored.gradientStops![1].color, equals(stops[1].color));
      });
    });

    group('PaintSwatch Integration', () {
      test('PaintSwatch wraps Paint and inherits equality', () {
        final paint1 = PaintData.solid(color: Colors.blue);
        final paint2 = PaintData.solid(color: Colors.blue);

        final swatch1 = PaintSwatch(paint1, label: 'Blue');
        final swatch2 = PaintSwatch(paint2, label: 'Blue');

        expect(swatch1, equals(swatch2));
      });

      test('Swatches with different labels are not equal', () {
        final paint = PaintData.solid(color: Colors.blue);

        final swatch1 = PaintSwatch(paint, label: 'Sky Blue');
        final swatch2 = PaintSwatch(paint, label: 'Ocean Blue');

        expect(swatch1, isNot(equals(swatch2)));
      });
    });

    group('PaintState Compatibility', () {
      test('PaintState wraps Paint correctly', () {
        final paint = PaintData.solid(color: Colors.blue);
        final state = PaintState.fromPaint(paint);

        expect(state.color, equals(Colors.blue));
        expect(state.paintType, equals(PaintType.solid));
        expect(state.paint, equals(paint));
      });

      test('PaintState equality delegates to Paint', () {
        final paint1 = PaintData.solid(color: Colors.blue);
        final paint2 = PaintData.solid(color: Colors.blue);

        final state1 = PaintState.fromPaint(paint1);
        final state2 = PaintState.fromPaint(paint2);

        expect(state1, equals(state2));
      });

      test('PaintState.didChange uses Paint equality', () {
        final paint1 = PaintData.solid(color: Colors.blue);
        final paint2 = PaintData.solid(color: Colors.red);

        final state1 = PaintState.fromPaint(paint1);
        final state2 = PaintState.fromPaint(paint2);

        expect(state1.didChange(state2), isTrue);
        expect(state1.didChange(state1), isFalse);
      });
    });
  });
}
