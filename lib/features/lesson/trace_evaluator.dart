import 'dart:typed_data';

class TraceEvaluationResult {
  TraceEvaluationResult({
    required this.passed,
    required this.insideRatio,
    required this.outsideRatio,
  });
  final bool passed;
  final double insideRatio;
  final double outsideRatio;
}

class TraceEvaluator {
  static const insideThreshold = 0.6;
  static const outsideThreshold = 0.4;

  /// Both masks: row-major bytes, non-zero == filled.
  static TraceEvaluationResult evaluate({
    required Uint8List strokesMask,
    required Uint8List templateMask,
    required int width,
    required int height,
  }) {
    assert(strokesMask.length == width * height);
    assert(templateMask.length == width * height);

    var templatePixels = 0;
    var insidePixels = 0;
    var strokePixels = 0;
    var outsidePixels = 0;

    for (var i = 0; i < strokesMask.length; i++) {
      final t = templateMask[i] > 0;
      final s = strokesMask[i] > 0;
      if (t) templatePixels++;
      if (s) strokePixels++;
      if (t && s) insidePixels++;
      if (!t && s) outsidePixels++;
    }

    final insideRatio = templatePixels == 0 ? 0.0 : insidePixels / templatePixels;
    final outsideRatio = strokePixels == 0 ? 0.0 : outsidePixels / strokePixels;
    final passed = insideRatio >= insideThreshold && outsideRatio <= outsideThreshold;

    return TraceEvaluationResult(
      passed: passed,
      insideRatio: insideRatio,
      outsideRatio: outsideRatio,
    );
  }
}
