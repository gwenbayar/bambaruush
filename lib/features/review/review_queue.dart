import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content_repository.dart';
import '../../core/providers.dart';
import '../../core/srs/leitner_engine.dart';
import '../../models/item.dart';
import '../../models/srs_box.dart';

/// Resolve an SRS box to its concrete content Item, or null if the id no longer
/// exists. Word and Letter both implement Item.
Item? _itemForBox(SrsBox box, ContentRepository content) =>
    box.itemType == ItemType.word
        ? content.words[box.itemId]
        : content.letters[box.itemId];

List<Item> _resolve(List<SrsBox> boxes, ContentRepository content) {
  final out = <Item>[];
  for (final box in boxes) {
    final item = _itemForBox(box, content);
    if (item != null) out.add(item);
  }
  return out;
}

/// All due items, resolved to concrete Items (unknown ids dropped), sorted
/// most-overdue-first (earliest nextReviewAt first). Not capped — the badge uses
/// the length; the session caps.
List<Item> dueReviewItems({
  required Map<String, SrsBox> srsByItem,
  required ContentRepository content,
  required DateTime now,
}) {
  final due = LeitnerEngine.dueItems(srsByItem, now)
    ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
  return _resolve(due, content);
}

/// Items the child has already practiced (have an SRS box), resolved & sorted
/// soonest-due-first. Used for free practice when nothing is due.
List<Item> freePracticeItems({
  required Map<String, SrsBox> srsByItem,
  required ContentRepository content,
}) {
  final boxes = srsByItem.values.toList()
    ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
  return _resolve(boxes, content);
}

/// Due items right now (drives the map badge + the review entry gate).
/// Recomputes only when progress/content change — not on a wall-clock timer,
/// which is fine since it's consumed right after session mutations.
final reviewQueueProvider = Provider<List<Item>>((ref) {
  final progress = ref.watch(progressControllerProvider);
  final content = ref.watch(contentRepositoryProvider);
  return dueReviewItems(
    srsByItem: progress.srsByItem,
    content: content,
    now: DateTime.now(),
  );
});

/// Learned items for "Practice anyway" when nothing is due.
final freePracticeProvider = Provider<List<Item>>((ref) {
  final progress = ref.watch(progressControllerProvider);
  final content = ref.watch(contentRepositoryProvider);
  return freePracticeItems(srsByItem: progress.srsByItem, content: content);
});
