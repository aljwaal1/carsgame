import 'package:flutter/widgets.dart';
import '../../core/models/retro_game_info.dart';
import 'retro_road_screen.dart';

class RetroRoadGameInfo implements RetroGameInfo {
  @override
  String get id => 'retro_road';
  @override
  String get title => 'طريق التحمل';
  @override
  String get description => 'سباق كلاسيكي بمراحل نهار وليل وضباب وثلج ومطر.';
  @override
  String get bestScoreKey => 'best_retro_road_score';
  @override
  String get icon => '🏎️';
  @override
  Widget buildScreen() => const RetroRoadScreen();
}
