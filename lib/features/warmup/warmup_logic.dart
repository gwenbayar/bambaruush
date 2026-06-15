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

