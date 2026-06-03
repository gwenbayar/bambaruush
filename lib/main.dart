import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/content/content_repository.dart';
import 'core/persistence/progress_store_factory.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final content = await ContentRepository.loadFromAssets();
  final store = await createProgressStore();
  final progress = await store.load();

  runApp(
    ProviderScope(
      overrides: [
        contentRepositoryProvider.overrideWithValue(content),
        progressRepositoryProvider.overrideWithValue(store),
        progressControllerProvider.overrideWith(
          (ref) => ProgressController(store, progress),
        ),
      ],
      child: const BambaruushApp(),
    ),
  );
}
