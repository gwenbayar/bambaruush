import 'dart:math';

/// Pick [n] distractor word ids for a review tile. Prefers the learned pool
/// (words the child has already practiced), excluding the target; falls back to
/// [allWordIds] when the learned pool is too small. Seeded → deterministic.
List<String> pickReviewDistractors({
  required String targetWordId,
  required List<String> learnedWordIds,
  required List<String> allWordIds,
  required int n,
  int? seed,
}) {
  final rand = Random(seed ?? DateTime.now().microsecondsSinceEpoch);

  final learned = learnedWordIds.where((id) => id != targetWordId).toSet().toList()
    ..shuffle(rand);
  if (learned.length >= n) return learned.take(n).toList();

  final fallback = allWordIds
      .where((id) => id != targetWordId && !learned.contains(id))
      .toSet()
      .toList()
    ..shuffle(rand);

  return [...learned, ...fallback.take(n - learned.length)];
}
