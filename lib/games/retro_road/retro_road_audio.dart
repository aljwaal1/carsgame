import '../../core/audio/audio_manager.dart';
import '../../core/audio/sound_ids.dart';

class RetroRoadAudio {
  static Future<void> pass() => AudioManager.instance.play(SoundIds.carPass, volume: 0.45);
  static Future<void> crash() => AudioManager.instance.play(SoundIds.carCrash, volume: 0.85);
  static Future<void> weather() => AudioManager.instance.play(SoundIds.weatherChange, volume: 0.6);
  static Future<void> clear() => AudioManager.instance.play(SoundIds.stageClear, volume: 0.75);
}
