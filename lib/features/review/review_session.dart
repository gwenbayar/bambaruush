import '../../core/content/content_repository.dart';
import '../../models/item.dart';
import '../lesson/activity_spec.dart';
import 'review_distractors.dart';

/// Graded activity kinds the review tool can choose from.
enum ReviewActivityKind { listen, read, trace }

/// Which graded activities each item type supports. Forward-looking seam: new
/// ItemTypes (verb, color…) add their compatible games here.
const gradedActivitiesFor = <ItemType, List<ReviewActivityKind>>{
  ItemType.word: [ReviewActivityKind.listen, ReviewActivityKind.read],
  ItemType.letter: [ReviewActivityKind.trace],
};

/// Deterministic given (item, seed): picks one compatible graded activity.
/// Words pick Listen/Read by `seed % options.length`; letters are always Trace.
ReviewActivityKind pickActivityForItem(Item item, {required int seed}) {
  final options = gradedActivitiesFor[item.type];
  if (options == null || options.isEmpty) {
    throw StateError('No graded activities for item type ${item.type}');
  }
  return options[seed % options.length];
}

/// Builds a review activity sequence from due (or free-practice) items, reusing
/// the same ActivitySpecs as lessons. Caps the session and ends on a
/// ReviewCompleteSpec celebration.
class ReviewSession {
  ReviewSession.due({
    required this.items,
    required this.content,
    required this.learnedWordIds,
    this.seed,
  });

  /// Same shape as [ReviewSession.due] today; the free-practice warm-up
  /// diverges in Slice 5. Kept distinct so call sites read intent.
  ReviewSession.free({
    required this.items,
    required this.content,
    required this.learnedWordIds,
    this.seed,
  });

  final List<Item> items;
  final ContentRepository content;
  final List<String> learnedWordIds;
  final int? seed;

  static const sessionCap = 8;

  List<ActivitySpec> buildSequence() {
    final s = seed;
    final chosen = items.take(sessionCap).toList();
    final allWordIds = content.words.keys.toList();
    final specs = <ActivitySpec>[];

    for (var i = 0; i < chosen.length; i++) {
      final item = chosen[i];
      final kind = pickActivityForItem(item, seed: s == null ? i : Object.hash(s, i));
      switch (kind) {
        case ReviewActivityKind.listen:
          specs.add(
            ListenSpec(
              wordId: item.id,
              attempt: 1,
              distractorIds: _distractors(item.id, allWordIds, s),
            ),
          );
        case ReviewActivityKind.read:
          specs.add(
            ReadSpec(
              wordId: item.id,
              attempt: 1,
              distractorIds: _distractors(item.id, allWordIds, s),
            ),
          );
        case ReviewActivityKind.trace:
          specs.add(TraceSpec(letterId: item.id, attempt: 1));
      }
    }

    specs.add(ReviewCompleteSpec(reviewedCount: chosen.length));
    return specs;
  }

  List<String> _distractors(String wordId, List<String> allWordIds, int? s) =>
      pickReviewDistractors(
        targetWordId: wordId,
        learnedWordIds: learnedWordIds,
        allWordIds: allWordIds,
        n: 2,
        seed: s == null ? null : Object.hash(s, wordId),
      );
}
