import '../../core/audio/audio_manager.dart';
import '../../core/audio/sound_ids.dart';

class FuelPlaneAudio {
  static Future<void> shoot() => AudioManager.instance.play(SoundIds.planeShoot, volume: 0.45);
  static Future<void> fuel() => AudioManager.instance.play(SoundIds.fuelPickup, volume: 0.7);
  static Future<void> explosion() => AudioManager.instance.play(SoundIds.planeExplosion, volume: 0.9);
  static Future<void> gameOver() => AudioManager.instance.play(SoundIds.gameOver, volume: 0.75);
}
