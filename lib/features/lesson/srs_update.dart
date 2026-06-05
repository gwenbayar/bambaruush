import '../../core/srs/leitner_engine.dart';
import '../../models/item.dart';
import '../../models/srs_box.dart';

/// Applies a session's first-attempt results to the SRS map. Every item that was
/// quizzed (i.e. present in [itemCorrectness], keyed "type:id") gets created or
/// updated — track-everything. Pure → easy to test.
Map<String, SrsBox> applySessionToSrs({
  required Map<String, SrsBox> current,
  required Map<String, bool> itemCorrectness,
  required DateTime now,
}) {
  final next = {...current};
  itemCorrectness.forEach((key, correct) {
    final ref = itemRefFromKey(key);
    final box = next[key] ?? LeitnerEngine.initial(ref.id, ref.type, now);
    next[key] =
        correct ? LeitnerEngine.onCorrect(box, now) : LeitnerEngine.onWrong(box, now);
  });
  return next;
}
