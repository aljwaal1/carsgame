import 'dart:math';
import 'fuel_plane_config.dart';
import 'fuel_plane_models.dart';

class FuelPlaneEngine {
  final Random random = Random();
  double planeX = 0.5;
  double fuel = FuelPlaneConfig.initialFuel;
  double speed = FuelPlaneConfig.initialSpeed;
  int score = 0;
  int distance = 0;
  int level = 1;
  int _fireCooldown = 0;
  int _scoreTick = 0;
  bool running = false;
  bool gameOver = false;
  final objects = <PlaneObject>[];
  final bullets = <PlaneBullet>[];

  void reset() {
    planeX = 0.5;
    fuel = FuelPlaneConfig.initialFuel;
    speed = FuelPlaneConfig.initialSpeed;
    score = 0;
    distance = 0;
    level = 1;
    _fireCooldown = 0;
    _scoreTick = 0;
    running = true;
    gameOver = false;
    objects.clear();
    bullets.clear();
  }

  void moveLeft() => planeX = max(0.08, planeX - FuelPlaneConfig.moveStep);
  void moveRight() => planeX = min(0.92, planeX + FuelPlaneConfig.moveStep);

  void dragTo(double localDx, double width) {
    if (!running || width <= 0) return;
    planeX = (localDx / width).clamp(0.08, 0.92).toDouble();
  }

  void fire() => bullets.add(PlaneBullet(planeX, FuelPlaneConfig.planeY - 0.075));

  PlaneEvent tick() {
    if (!running) return PlaneEvent.none;
    var event = PlaneEvent.none;

    distance++;
    _scoreTick++;
    if (_scoreTick >= 12) {
      score += FuelPlaneConfig.pointsPerDistanceTick;
      _scoreTick = 0;
    }

    fuel -= FuelPlaneConfig.fuelDrain;
    level = 1 + distance ~/ 1500;
    speed = min(FuelPlaneConfig.maxSpeed, FuelPlaneConfig.initialSpeed + level * 0.0009);

    if (_fireCooldown <= 0) {
      fire();
      _fireCooldown = max(7, 14 - min(5, level ~/ 2));
      event = PlaneEvent.shoot;
    } else {
      _fireCooldown--;
    }

    final spawnChance = 0.018 + min(0.018, level * 0.002);
    if (random.nextDouble() < spawnChance) {
      final roll = random.nextDouble();
      final type = roll < 0.25 ? PlaneObjectType.fuel : roll < 0.78 ? PlaneObjectType.rock : PlaneObjectType.enemy;
      objects.add(PlaneObject(x: 0.12 + random.nextDouble() * 0.76, y: -0.08, size: type == PlaneObjectType.fuel ? 0.052 : 0.066, type: type));
    }

    for (final obj in objects) { obj.y += speed; }
    for (final b in bullets) { b.y -= 0.040; }
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
          hitObjects.add(o);
          hitBullets.add(b);
          score += FuelPlaneConfig.pointsPerHit;
          current = PlaneEvent.hit;
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
          score += FuelPlaneConfig.pointsPerFuel;
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

enum PlaneEvent { none, shoot, fuel, hit, dead }
