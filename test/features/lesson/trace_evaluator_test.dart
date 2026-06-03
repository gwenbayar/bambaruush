import 'dart:typed_data';

import 'package:bambaruush/features/lesson/trace_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A 4×4 template where the diagonal is the "letter" (alpha = 255 on diagonal).
  final template = Uint8List.fromList([
    255, 0, 0, 0,
    0, 255, 0, 0,
    0, 0, 255, 0,
    0, 0, 0, 255,
  ]);

  test('full diagonal coverage with no outside marks passes', () {
    final strokes = Uint8List.fromList([
      255, 0, 0, 0,
      0, 255, 0, 0,
      0, 0, 255, 0,
      0, 0, 0, 255,
    ]);
    final result = TraceEvaluator.evaluate(
      strokesMask: strokes, templateMask: template, width: 4, height: 4,
    );
    expect(result.passed, isTrue);
    expect(result.insideRatio, 1.0);
    expect(result.outsideRatio, 0.0);
  });

  test('all-outside-no-inside fails', () {
    final strokes = Uint8List.fromList([
      0, 255, 255, 255,
      255, 0, 255, 255,
      255, 255, 0, 255,
      255, 255, 255, 0,
    ]);
    final result = TraceEvaluator.evaluate(
      strokesMask: strokes, templateMask: template, width: 4, height: 4,
    );
    expect(result.passed, isFalse);
    expect(result.insideRatio, 0.0);
  });

  test('majority-inside under threshold for outside passes', () {
    // 3 of 4 diagonal pixels filled; 0 outside marks.
    final strokes = Uint8List.fromList([
      255, 0, 0, 0,
      0, 255, 0, 0,
      0, 0, 255, 0,
      0, 0, 0, 0,
    ]);
    final r = TraceEvaluator.evaluate(
      strokesMask: strokes, templateMask: template, width: 4, height: 4,
    );
    expect(r.insideRatio, closeTo(0.75, 0.001));
    expect(r.passed, isTrue);
  });

  test('inside threshold met but heavy outside fails', () {
    final strokes = Uint8List.fromList([
      255, 255, 255, 255,
      255, 255, 255, 255,
      255, 255, 255, 255,
      255, 255, 255, 255,
    ]);
    final r = TraceEvaluator.evaluate(
      strokesMask: strokes, templateMask: template, width: 4, height: 4,
    );
    expect(r.insideRatio, 1.0);
    expect(r.outsideRatio, greaterThan(0.4));
    expect(r.passed, isFalse);
  });
}
