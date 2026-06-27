import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final AudioPlayer _sfx = AudioPlayer();
  bool enabled = true;

  Future<void> play(String relativeAssetPath, {double volume = 0.75}) async {
    if (!enabled) return;
    try {
      await _sfx.stop();
      await _sfx.setVolume(volume);
      await _sfx.play(AssetSource('sounds/$relativeAssetPath'));
    } catch (_) {
      // اللعبة تستمر حتى لو لم يعمل الصوت على جهاز معين.
    }
  }

  void toggle() => enabled = !enabled;
}
