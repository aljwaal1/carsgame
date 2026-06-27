import 'package:shared_preferences/shared_preferences.dart';

class ScoreStorage {
  static Future<int> getBestScore(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> saveBestScore(String key, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final old = prefs.getInt(key) ?? 0;
    if (score > old) await prefs.setInt(key, score);
  }
}
