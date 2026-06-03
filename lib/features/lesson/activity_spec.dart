/// One step in a session's sequence. Open sealed hierarchy: future activities
/// (dress-up, walk-to-place…) add new subtypes without touching the runner.
sealed class ActivitySpec {
  const ActivitySpec();
}

class IntroSpec extends ActivitySpec {
  const IntroSpec(this.letterId);
  final String letterId;
}

class TraceSpec extends ActivitySpec {
  const TraceSpec({required this.letterId, required this.attempt});
  final String letterId;
  final int attempt;
}

class ListenSpec extends ActivitySpec {
  const ListenSpec({
    required this.wordId,
    required this.distractorIds,
    required this.attempt,
  });
  final String wordId;
  final List<String> distractorIds;
  final int attempt;
}

class ReadSpec extends ActivitySpec {
  const ReadSpec({
    required this.wordId,
    required this.distractorIds,
    required this.attempt,
  });
  final String wordId;
  final List<String> distractorIds;
  final int attempt;
}

class RewardSpec extends ActivitySpec {
  const RewardSpec(this.stickerId);
  final String stickerId;
}

/// Terminal marker: the session has no more steps.
class SessionComplete extends ActivitySpec {
  const SessionComplete();
}
