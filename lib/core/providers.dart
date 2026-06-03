import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/progress.dart';
import 'audio/audio_service.dart';
import 'content/content_repository.dart';
import 'persistence/progress_store.dart';

/// Set in main() after async bootstrap completes.
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  throw UnimplementedError('Override in ProviderScope at app start');
});

/// Holds a [ProgressStore] (file-based on native, in-memory on web).
final progressRepositoryProvider = Provider<ProgressStore>((ref) {
  throw UnimplementedError('Override in ProviderScope at app start');
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final svc = AudioService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// Mutable Progress state. Reads pull from disk on first access via the store.
class ProgressController extends StateNotifier<Progress> {
  ProgressController(this._store, Progress initial) : super(initial);
  final ProgressStore _store;

  Future<void> update(Progress next) async {
    state = next;
    await _store.save(next);
  }

  Future<void> reset() async {
    await _store.reset();
    state = Progress.empty();
  }
}

final progressControllerProvider =
    StateNotifierProvider<ProgressController, Progress>((ref) {
  throw UnimplementedError('Override in ProviderScope at app start');
});
