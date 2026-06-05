import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/core/persistence/in_memory_progress_store.dart';
import 'package:bambaruush/core/providers.dart';
import 'package:bambaruush/features/steppe/splash_screen.dart';
import 'package:bambaruush/models/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('SplashScreen renders title and redirects to /steppe',
      (tester) async {
    // Splash now reads progress + review queues to decide /warmup vs /steppe,
    // so the providers it depends on must be overridden (as in main()/app boot).
    // With empty progress there are no practice items, so it routes to /steppe.
    final content = ContentRepository.fromJson(
      jsonDecode(
        File('test/fixtures/content_valid.json').readAsStringSync(),
      ) as Map<String, dynamic>,
    );
    final store = InMemoryProgressStore();

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(
          path: '/steppe',
          builder: (_, __) => const Scaffold(
            body: Center(child: Text('STEPPE_OK')),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contentRepositoryProvider.overrideWithValue(content),
          progressRepositoryProvider.overrideWithValue(store),
          progressControllerProvider.overrideWith(
            (ref) => ProgressController(store, Progress.empty()),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump(); // initial frame
    expect(find.text('Bambaruush'), findsOneWidget);

    // Let the 300ms post-frame delay expire and the redirect occur.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(); // route transition
    expect(find.text('STEPPE_OK'), findsOneWidget);
  });

  test('content fixture loads via ContentRepository', () {
    final json = jsonDecode(
      File('test/fixtures/content_valid.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final content = ContentRepository.fromJson(json);
    expect(content.regions.first.nameEn, 'The Yurt');
  });
}
