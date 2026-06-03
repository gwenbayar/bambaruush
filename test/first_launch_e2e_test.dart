import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/app.dart';
import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/core/persistence/progress_repository.dart';
import 'package:bambaruush/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Requires real device — just_audio plugin throws MissingPluginException
  // and Image.asset rasterization fails in the headless flutter_test harness.
  // Run on a simulator via:
  //   flutter test integration_test/first_launch_test.dart -d <device>
  testWidgets(
    'first launch -> finish lesson 1 -> sticker earned, lesson 2 unlocked',
    skip: true,
    (tester) async {
      // Set up isolated test environment.
      final json = jsonDecode(
        File('test/fixtures/content_valid.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final content = ContentRepository.fromJson(json);

      final tmp = await Directory.systemTemp.createTemp('bambaruush_e2e_');
      addTearDown(() async {
        if (tmp.existsSync()) await tmp.delete(recursive: true);
      });
      final progressRepo = ProgressRepository(documentsDir: tmp);
      await progressRepo.reset();
      final progress = await progressRepo.load();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contentRepositoryProvider.overrideWithValue(content),
            progressRepositoryProvider.overrideWithValue(progressRepo),
            progressControllerProvider.overrideWith(
              (ref) => ProgressController(progressRepo, progress),
            ),
          ],
          child: const BambaruushApp(),
        ),
      );

      // Splash -> /steppe
      await tester.pump(); // initial
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(); // route transition

      // Expect Steppe with "The Yurt" region tile.
      expect(find.text('The Steppe'), findsOneWidget);
      expect(find.text('The Yurt'), findsOneWidget);

      // Tap region.
      await tester.tap(find.text('The Yurt'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Tap lesson 1.
      expect(find.text('Lesson 1'), findsOneWidget);
      await tester.tap(find.text('Lesson 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Intro stage: tap "Next".
      expect(find.text('Next'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Trace stage: draw a stroke + tap Done.
      // The GestureDetector for the canvas is the first one in the trace
      // stage subtree.
      final gestureFinder = find.byType(GestureDetector).first;
      await tester.drag(gestureFinder, const Offset(100, 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Done'));
      // Trace eval is async; pump enough time for raster + advance.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Listen + Read stages: tap any tile. Target may not be the one we
      // tap, so handle retry by looping until Continue (Reward) shows.
      var safety = 20;
      while (safety > 0 && find.text('Continue').evaluate().isEmpty) {
        final tiles = find.byType(InkWell);
        if (tiles.evaluate().isNotEmpty) {
          await tester.tap(tiles.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
        } else {
          break;
        }
        safety--;
      }

      // Reward stage: tap Continue.
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      // Allow _persistCompletion to flush save + pop back to region screen.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // We should now be back on the region screen; lesson_01 marked complete.
      final reloaded = await progressRepo.load();
      expect(
        reloaded.lessons['lesson_01']?.completed,
        isTrue,
        reason: 'Lesson 1 should be marked complete after walk-through',
      );
      expect(
        reloaded.earnedStickerIds,
        contains('sticker_father_bear'),
        reason: 'Father Bear sticker should be earned',
      );
      expect(
        reloaded.lessons['lesson_02']?.unlocked,
        isTrue,
        reason: 'Lesson 2 should be unlocked',
      );
    },
  );
}
