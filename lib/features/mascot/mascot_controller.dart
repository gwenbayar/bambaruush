import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mascot_mood.dart';

class MascotController extends StateNotifier<MascotMood> {
  MascotController() : super(MascotMood.idle);
  Timer? _resetTimer;

  void cheer() => _setTransient(MascotMood.cheer);
  void sad() => _setTransient(MascotMood.sad);
  void point() => _setTransient(MascotMood.point);
  void wave() => _setTransient(MascotMood.wave);
  void sleep() => _set(MascotMood.sleep);
  void idle() => _set(MascotMood.idle);

  void _set(MascotMood mood) {
    _resetTimer?.cancel();
    state = mood;
  }

  void _setTransient(MascotMood mood) {
    _resetTimer?.cancel();
    state = mood;
    _resetTimer = Timer(const Duration(seconds: 2), () {
      state = MascotMood.idle;
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }
}

final mascotProvider =
    StateNotifierProvider<MascotController, MascotMood>((ref) => MascotController());
