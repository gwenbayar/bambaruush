import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/lesson/lesson_runner_screen.dart';
import '../../features/settings/parent_gate_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/steppe/region_detail_screen.dart';
import '../../features/steppe/splash_screen.dart';
import '../../features/steppe/steppe_map_screen.dart';
import '../../features/stickers/sticker_album_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/steppe', builder: (_, __) => const SteppeMapScreen()),
      GoRoute(
        path: '/region/:id',
        builder: (_, state) =>
            RegionDetailScreen(regionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, state) =>
            LessonRunnerScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/album', builder: (_, __) => const StickerAlbumScreen()),
      GoRoute(path: '/settings/gate', builder: (_, __) => const ParentGateScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});
