import 'dart:math';
import 'retro_road_config.dart';
import 'retro_road_models.dart';
import 'retro_road_weather.dart';

class RetroRoadEngine {
  final Random random = Random();
  double playerX = 0.5;
  double speed = RetroRoadConfig.initialSpeed;
  int score = 0;
  int day = 1;
  int passed = 0;
  bool running = false;
  bool gameOver = false;
  RoadWeather weather = RoadWeather.day;
  final cars = <RoadCar>[];
  RoadWeather _lastWeather = RoadWeather.day;

  void reset() {
    playerX = 0.5;
    speed = RetroRoadConfig.initialSpeed;
    score = 0;
    day = 1;
    passed = 0;
    running = true;
    gameOver = false;
    weather = RoadWeather.day;
    _lastWeather = RoadWeather.day;
    cars.clear();
  }

  void moveLeft() => playerX = max(0.16, playerX - 0.045 * weather.steeringMultiplier);
  void moveRight() => playerX = min(0.84, playerX + 0.045 * weather.steeringMultiplier);

  RoadEvent tick() {
    if (!running) return RoadEvent.none;
    var event = RoadEvent.none;
    score++;
    speed = min(RetroRoadConfig.maxSpeed, RetroRoadConfig.initialSpeed + day * 0.0014 + score / 110000);
    _updateWeather();
    if (weather != _lastWeather) { event = RoadEvent.weatherChanged; _lastWeather = weather; }

    final spawnChance = 0.030 + min(0.022, day * 0.004);
    if (random.nextDouble() < spawnChance) {
      final lanes = [0.28, 0.40, 0.52, 0.64, 0.76];
      final lane = random.nextInt(lanes.length);
      cars.add(RoadCar(x: lanes[lane] + (random.nextDouble() - 0.5) * 0.025, y: -0.10, lane: lane, speedFactor: 0.80 + random.nextDouble() * 0.55));
    }

    for (final car in cars) { car.y += speed * car.speedFactor; }
    final before = cars.length;
    cars.removeWhere((c) => c.y > 1.15);
    final removed = before - cars.length;
    if (removed > 0) { passed += removed; score += removed * 80; event = RoadEvent.passed; }

    if (passed >= RetroRoadConfig.carsPerDay) {
      day++;
      passed = 0;
      cars.clear();
      event = RoadEvent.dayClear;
    }

    if (_hasCrash()) {
      running = false;
      gameOver = true;
      event = RoadEvent.crash;
    }
    return event;
  }

  void _updateWeather() {
    final progress = passed / RetroRoadConfig.carsPerDay;
    if (progress < 0.16) weather = RoadWeather.day;
    else if (progress < 0.31) weather = RoadWeather.sunset;
    else if (progress < 0.47) weather = RoadWeather.night;
    else if (progress < 0.63) weather = RoadWeather.fog;
    else if (progress < 0.81) weather = RoadWeather.snow;
    else weather = RoadWeather.rain;
  }

  bool _hasCrash() {
    for (final c in cars) {
      if ((playerX - c.x).abs() < 0.055 && (RetroRoadConfig.playerY - c.y).abs() < 0.075) return true;
    }
    return false;
  }
}

enum RoadEvent { none, passed, crash, weatherChanged, dayClear }
