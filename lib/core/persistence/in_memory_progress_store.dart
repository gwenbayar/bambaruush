import '../../models/progress.dart';
import 'progress_store.dart';

/// Session-only store for platforms without a filesystem (web).
/// Progress is NOT persisted across reloads.
class InMemoryProgressStore implements ProgressStore {
  Progress _progress = Progress.empty();

  @override
  Future<Progress> load() async => _progress;

  @override
  Future<void> save(Progress p) async => _progress = p;

  @override
  Future<void> reset() async => _progress = Progress.empty();
}
