import 'package:flutter/widgets.dart';

abstract class RetroGameInfo {
  String get id;
  String get title;
  String get description;
  String get bestScoreKey;
  String get icon;
  Widget buildScreen();
}
