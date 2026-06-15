import '../../core/content/content_repository.dart';
import '../../models/constellation.dart';
import '../../models/progress.dart';
import '../../models/srs_box.dart';
import '../lesson/srs_update.dart';

/// A word/letter is "mastered" — and earns a permanent sky-star — once its
/// Leitner box reaches this level (recall across a few spaced sessions). See
/// Story Guide §8: mastery, never a single tap.
const kMasteryLevel = 3;

bool isMastered(SrsBox box) => box.level >= kMasteryLevel;

/// Append every item now mastered whose key isn't already a star, in a
/// deterministic order (sorted ascending), preserving prior placement order.
/// Idempotent. Earned keys are never removed — permanence (kindness invariant).
({List<String> updated, List<String> newlyEarned}) awardSkyStars({
  required List<String> current,
  required Map<String, SrsBox> srsByItem,
}) {
  final have = current.toSet();
  final newly = <String>[
    for (final entry in srsByItem.entries)
      if (isMastered(entry.value) && !have.contains(entry.key)) entry.key,
  ]..sort();
  return (updated: [...current, ...newly], newlyEarned: newly);
}

/// Constellations whose slot count is now filled and not yet celebrated.
List<Constellation> newlyCompletedConstellations({
  required int starCount,
  required List<Constellation> all,
  required Set<String> alreadyCompleted,
}) =>
    [
      for (final c in all)
        if (starCount >= c.slots.length && !alreadyCompleted.contains(c.id)) c,
    ];

/// Result of applying a finished session to progress: the next Progress plus
/// what to celebrate.
class SessionRewards {
  const SessionRewards({
    required this.progress,
    required this.newStarKeys,
    required this.completedConstellations,
  });

  final Progress progress;
  final List<String> newStarKeys;
  final List<Constellation> completedConstellations;
}

/// The single path every completion handler (lesson / review / warm-up) calls:
/// SRS update → permanent sky-stars → constellation completion → (warm-up)
/// warmupCount/lastWarmupAt. Pure. Lesson-specific bits (lessons/sticker/unlock)
/// are layered on top of [SessionRewards.progress] by the caller.
SessionRewards applySessionRewards({
  required Progress current,
  required Map<String, bool> itemCorrectness,
  required DateTime now,
  required ContentRepository content,
  bool isWarmup = false,
}) {
  final newSrs = applySessionToSrs(
    current: current.srsByItem,
    itemCorrectness: itemCorrectness,
    now: now,
  );
  final stars = awardSkyStars(
    current: current.skyStarItemKeys,
    srsByItem: newSrs,
  );
  final completed = newlyCompletedConstellations(
    starCount: stars.updated.length,
    all: content.constellations,
    alreadyCompleted: current.completedConstellationIds,
  );
  final next = current.copyWith(
    srsByItem: newSrs,
    skyStarItemKeys: stars.updated,
    completedConstellationIds: {
      ...current.completedConstellationIds,
      for (final c in completed) c.id,
    },
    lastPlayed: now,
    warmupCount: isWarmup ? current.warmupCount + 1 : current.warmupCount,
    lastWarmupAt: isWarmup ? now : current.lastWarmupAt,
  );
  return SessionRewards(
    progress: next,
    newStarKeys: stars.newlyEarned,
    completedConstellations: completed,
  );
}
