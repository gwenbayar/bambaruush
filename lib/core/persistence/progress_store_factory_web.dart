import 'in_memory_progress_store.dart';
import 'progress_store.dart';

/// Web: no filesystem — keep progress in memory for the session.
Future<ProgressStore> createProgressStore() async => InMemoryProgressStore();
