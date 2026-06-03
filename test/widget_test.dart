import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/features/steppe/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('SplashScreen renders title and redirects to /steppe',
      (tester) async {
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
