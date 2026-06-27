import 'dart:math';
import 'fuel_plane_config.dart';
import 'fuel_plane_models.dart';

class FuelPlaneEngine {
  final Random random = Random();
  double planeX = 0.5;
  double fuel = FuelPlaneConfig.initialFuel;
  double speed = FuelPlaneConfig.initialSpeed;
  int score = 0;
  int level = 1;
  bool running = false;
  bool gameOver = false;
  final objects = <PlaneObject>[];
  final bullets = <PlaneBullet>[];

  void reset() {
    planeX = 0.5;
    fuel = FuelPlaneConfig.initialFuel;
    speed = FuelPlaneConfig.initialSpeed;
    score = 0;
    level = 1;
    running = true;
    gameOver = false;
    objects.clear();
    bullets.clear();
  }

  void moveLeft() => planeX = max(0.08, planeX - FuelPlaneConfig.moveStep);
  void moveRight() => planeX = min(0.92, planeX + FuelPlaneConfig.moveStep);
  void fire() => bullets.add(PlaneBullet(planeX, FuelPlaneConfig.planeY - 0.06));

  PlaneEvent tick() {
    if (!running) return PlaneEvent.none;
    var event = PlaneEvent.none;
    score++;
    fuel -= FuelPlaneConfig.fuelDrain;
    level = 1 + score ~/ 900;
    speed = min(FuelPlaneConfig.maxSpeed, FuelPlaneConfig.initialSpeed + level * 0.0016);

    final spawnChance = 0.028 + min(0.025, level * 0.003);
    if (random.nextDouble() < spawnChance) {
      final roll = random.nextDouble();
      final type = roll < 0.23 ? PlaneObjectType.fuel : roll < 0.78 ? PlaneObjectType.rock : PlaneObjectType.enemy;
      objects.add(PlaneObject(x: 0.12 + random.nextDouble() * 0.76, y: -0.08, size: type == PlaneObjectType.fuel ? 0.052 : 0.066, type: type));
    }

    for (final obj in objects) { obj.y += speed; }
    for (final b in bullets) { b.y -= 0.04; }
    objects.removeWhere((o) => o.y > 1.12);
    bullets.removeWhere((b) => b.y < -0.08);

    event = _bulletHits(event);
    event = _collisions(event);
    if (fuel <= 0) event = PlaneEvent.dead;
    if (event == PlaneEvent.dead) { running = false; gameOver = true; }
    return event;
  }

  PlaneEvent _bulletHits(PlaneEvent current) {
    final hitObjects = <PlaneObject>[];
    final hitBullets = <PlaneBullet>[];
    for (final b in bullets) {
      for (final o in objects) {
        if (o.type != PlaneObjectType.fuel && (b.x - o.x).abs() < o.size && (b.y - o.y).abs() < o.size) {
          hitObjects.add(o); hitBullets.add(b); score += 60; current = PlaneEvent.hit;
          break;
        }
      }
    }
    objects.removeWhere(hitObjects.contains);
    bullets.removeWhere(hitBullets.contains);
    return current;
  }

  PlaneEvent _collisions(PlaneEvent current) {
    for (final o in List<PlaneObject>.from(objects)) {
      if ((planeX - o.x).abs() < o.size * 0.92 && (FuelPlaneConfig.planeY - o.y).abs() < o.size * 0.92) {
        if (o.type == PlaneObjectType.fuel) {
          fuel = min(100, fuel + FuelPlaneConfig.fuelGain);
          score += 100;
          objects.remove(o);
          current = PlaneEvent.fuel;
        } else {
          return PlaneEvent.dead;
        }
      }
    }
    return current;
  }
}

enum PlaneEvent { none, fuel, hit, dead }
