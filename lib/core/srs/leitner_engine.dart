import '../../models/srs_box.dart';

class LeitnerEngine {
  static const intervals = <int, Duration>{
    1: Duration(days: 1),
    2: Duration(days: 3),
    3: Duration(days: 7),
    4: Duration(days: 14),
    5: Duration(days: 30),
  };

  static SrsBox initial(String wordId, DateTime now) => SrsBox(
        wordId: wordId,
        level: 1,
        nextReviewAt: now,
        correctStreak: 0,
      );

  static SrsBox onCorrect(SrsBox box, DateTime now) {
    final newLevel = (box.level + 1).clamp(1, 5);
    return box.copyWith(
      level: newLevel,
      nextReviewAt: now.add(intervals[newLevel]!),
      correctStreak: box.correctStreak + 1,
    );
  }

  static SrsBox onWrong(SrsBox box, DateTime now) => box.copyWith(
        level: 1,
        nextReviewAt: now.add(intervals[1]!),
        correctStreak: 0,
      );

  static bool isDue(SrsBox box, DateTime now) => !now.isBefore(box.nextReviewAt);
}
