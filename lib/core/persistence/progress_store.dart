import '../../models/progress.dart';

/// Platform-agnostic persistence interface for [Progress].
abstract class ProgressStore {
  Future<Progress> load();
  Future<void> save(Progress p);
  Future<void> reset();
}
