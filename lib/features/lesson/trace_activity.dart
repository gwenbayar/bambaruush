import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../mascot/mascot_controller.dart';
import 'activity_spec.dart';
import 'trace_evaluator.dart';

class TraceActivityView extends ConsumerStatefulWidget {
  const TraceActivityView({
    super.key,
    required this.spec,
    required this.onResult,
  });
  final TraceSpec spec;
  final void Function({required bool correct}) onResult;
  @override
  ConsumerState<TraceActivityView> createState() => _TraceActivityViewState();
}

class _TraceActivityViewState extends ConsumerState<TraceActivityView> {
  final List<List<Offset>> _strokes = [];
  final GlobalKey _canvasKey = GlobalKey();
  Timer? _idleTimer;
  static const _evalSize = 256;
  int _attempt = 1;
  bool _evaluating = false;

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 2), _finishAttempt);
  }

  Future<void> _finishAttempt() async {
    if (_evaluating) return;
    _evaluating = true;
    final letter = ref.read(contentRepositoryProvider).letterById(widget.spec.letterId);
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final canvasSize = box?.size ?? Size(_evalSize.toDouble(), _evalSize.toDouble());
    final pass = await _evaluate(letter.cyrillic, canvasSize);
    if (!mounted) return;
    final mascot = ref.read(mascotProvider.notifier);
    if (pass && _attempt == 1) {
      mascot.cheer();
      widget.onResult(correct: true);
    } else if (!pass && _attempt == 1) {
      mascot.sad();
      setState(() {
        _strokes.clear();
        _attempt = 2;
        _evaluating = false;
      });
    } else {
      // attempt 2 — always advance, record correct=false
      pass ? mascot.cheer() : mascot.sad();
      widget.onResult(correct: false);
    }
  }

  Future<bool> _evaluate(String cyrillic, Size canvasSize) async {
    final template = await _rasterTemplate(cyrillic);
    final strokes = await _rasterStrokes(canvasSize);
    return TraceEvaluator.evaluate(
      strokesMask: strokes,
      templateMask: template,
      width: _evalSize,
      height: _evalSize,
    ).passed;
  }

  Future<Uint8List> _rasterTemplate(String cyrillic) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, _evalSize.toDouble(), _evalSize.toDouble()));
    canvas.drawColor(const Color(0xFFFFFFFF), BlendMode.src);
    final tp = TextPainter(
      text: TextSpan(
        text: cyrillic,
        style: const TextStyle(
          fontSize: _evalSize * 0.85,
          color: Color(0xFF000000),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _evalSize.toDouble());
    tp.paint(
      canvas,
      Offset((_evalSize - tp.width) / 2, (_evalSize - tp.height) / 2),
    );
    final pic = recorder.endRecording();
    final img = await pic.toImage(_evalSize, _evalSize);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return _toMask(byteData!.buffer.asUint8List());
  }

  Future<Uint8List> _rasterStrokes(Size size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, _evalSize.toDouble(), _evalSize.toDouble()));
    canvas.drawColor(const Color(0xFFFFFFFF), BlendMode.src);
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final scaleX = _evalSize / size.width;
    final scaleY = _evalSize / size.height;
    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx * scaleX, stroke.first.dy * scaleY);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx * scaleX, p.dy * scaleY);
      }
      canvas.drawPath(path, paint);
    }
    final pic = recorder.endRecording();
    final img = await pic.toImage(_evalSize, _evalSize);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return _toMask(byteData!.buffer.asUint8List());
  }

  /// Convert RGBA → grayscale mask (non-zero if pixel is "dark", i.e. drawn-on).
  Uint8List _toMask(Uint8List rgba) {
    final out = Uint8List(rgba.length ~/ 4);
    for (var i = 0, j = 0; i < rgba.length; i += 4, j++) {
      final r = rgba[i], g = rgba[i + 1], b = rgba[i + 2];
      final luminance = (r + g + b) ~/ 3;
      out[j] = luminance < 128 ? 255 : 0;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final letter = ref.watch(contentRepositoryProvider).letterById(widget.spec.letterId);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text('Trace the letter', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: GestureDetector(
              key: _canvasKey,
              onPanStart: (d) {
                setState(() => _strokes.add([d.localPosition]));
                _resetIdleTimer();
              },
              onPanUpdate: (d) {
                setState(() => _strokes.last.add(d.localPosition));
                _resetIdleTimer();
              },
              onPanEnd: (_) => _resetIdleTimer(),
              child: CustomPaint(
                size: Size.infinite,
                painter: _TracePainter(cyrillic: letter.cyrillic, strokes: _strokes),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => setState(_strokes.clear),
                icon: const Icon(Icons.refresh),
                label: const Text('Clear'),
              ),
              FilledButton(
                onPressed: _strokes.isEmpty ? null : _finishAttempt,
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({required this.cyrillic, required this.strokes});
  final String cyrillic;
  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: cyrillic,
        style: TextStyle(
          fontSize: size.height * 0.85,
          color: Colors.brown.withValues(alpha: 0.18),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );

    final paint = Paint()
      ..color = Colors.brown.shade800
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter old) => old.strokes != strokes;
}
