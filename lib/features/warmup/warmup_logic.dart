import '../../models/progress.dart';
import '../lesson/srs_update.dart';

/// True iff [a] is the same calendar *local* day as [b] (null a → false).
/// Local is deliberate: "today" means the child's wall-clock day. No DST math
/// happens here (we only read y/m/d), so the only skew is cross-timezone travel.
bool isSameDay(DateTime? a, DateTime b) =>
    a != null && a.year == b.year && a.month == b.month && a.day == b.day;

/// Offer the daily warm-up when there's something to practice and we haven't
/// already warmed up (or skipped) today.
bool shouldOfferWarmup({
  required DateTime? lastWarmupAt,
  required DateTime now,
  required bool hasPracticeItems,
}) =>
    hasPracticeItems && !isSameDay(lastWarmupAt, now);

/// Apply a completed warm-up to progress: the SRS update (same as a normal
/// review) plus bumping [Progress.warmupCount] and stamping the dates. No reward
/// is granted yet — that's the seam the future house-accessory reward attaches to.
Progress applyWarmupCompletion({
  required Progress current,
  required Map<String, bool> itemCorrectness,
  required DateTime now,
}) =>
    current.copyWith(
      srsByItem: applySessionToSrs(
        current: current.srsByItem,
        itemCorrectness: itemCorrectness,
        now: now,
      ),
      warmupCount: current.warmupCount + 1,
      lastWarmupAt: now,
      lastPlayed: now,
    );
