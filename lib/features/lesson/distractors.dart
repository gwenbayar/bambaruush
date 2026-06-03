import 'dart:math';

import '../../models/lesson.dart';
import '../../models/word.dart';

List<String> pickDistractors({
  required String targetWordId,
  required Lesson lesson,
  required List<Word> allWords,
  required Map<String, String> wordIdToRegionId,
  required int n,
  int? seed,
}) {
  final rand = Random(seed ?? DateTime.now().microsecondsSinceEpoch);
  final targetRegion = lesson.regionId;

  final sameRegion = allWords
      .where((w) => w.id != targetWordId)
      .where((w) => wordIdToRegionId[w.id] == targetRegion)
      .map((w) => w.id)
      .toList()
    ..shuffle(rand);

  if (sameRegion.length >= n) return sameRegion.take(n).toList();

  final fallback = allWords
      .where((w) => w.id != targetWordId && wordIdToRegionId[w.id] != targetRegion)
      .map((w) => w.id)
      .toList()
    ..shuffle(rand);

  return [...sameRegion, ...fallback.take(n - sameRegion.length)];
}
