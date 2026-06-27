import 'package:flutter/widgets.dart';
import '../../core/models/retro_game_info.dart';
import 'fuel_plane_screen.dart';

class FuelPlaneGameInfo implements RetroGameInfo {
  @override
  String get id => 'fuel_plane';
  @override
  String get title => 'طائرة الوقود';
  @override
  String get description => 'اجمع الوقود، أطلق النار، وتجنب العوائق في طريق كلاسيكي سريع.';
  @override
  String get bestScoreKey => 'best_fuel_plane_score';
  @override
  String get icon => '✈️';
  @override
  Widget buildScreen() => const FuelPlaneScreen();
}
