import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/routing/app_router.dart';
import 'theme/app_theme.dart';

class BambaruushApp extends ConsumerStatefulWidget {
  const BambaruushApp({super.key});
  @override
  ConsumerState<BambaruushApp> createState() => _BambaruushAppState();
}

class _BambaruushAppState extends ConsumerState<BambaruushApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progress = ref.read(progressControllerProvider);
      ref.read(audioServiceProvider).setVolume(progress.volume);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Bambaruush',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
