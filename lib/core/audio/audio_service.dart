import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService() : _player = AudioPlayer();

  final AudioPlayer _player;
  double _volume = 1.0;
  final Set<String> _preloaded = <String>{};

  Future<void> preload(List<String> assetPaths) async {
    for (final p in assetPaths) {
      if (_preloaded.contains(p)) continue;
      try {
        await _player.setAsset(p);
        _preloaded.add(p);
      } catch (_) {
        // Bundled asset missing or unreadable — skip.
      }
    }
  }

  Future<void> play(String assetPath) async {
    try {
      await _player.stop();
      await _player.setAsset(assetPath);
      await _player.setVolume(_volume);
      await _player.play();
    } catch (_) {
      // Playback failure is non-fatal; skip silently.
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    _player.setVolume(_volume);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
