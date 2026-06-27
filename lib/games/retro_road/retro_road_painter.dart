import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/graphics/retro_pixels.dart';
import 'retro_road_models.dart';
import 'retro_road_weather.dart';

class RetroRoadPainter extends CustomPainter {
  RetroRoadPainter({required this.playerX, required this.cars, required this.weather, required this.day, required this.score});

  final double playerX;
  final List<RoadCar> cars;
  final RoadWeather weather;
  final int day;
  final int score;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bg = Offset.zero & size;
    canvas.drawRect(bg, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: _skyColors(),
      stops: const [0, .42, 1],
    ).createShader(bg));

    _sunMoon(canvas, size);
    _horizon(canvas, size);
    _road(canvas, size);
    _roadSideDetails(canvas, size);
    _laneMarks(canvas, size);

    for (final car in cars) {
      final c = Offset(car.x * w, car.y * h);
      final scale = _scaleForY(car.y, w);
      _car(canvas, c, scale, enemy: true, lane: car.lane);
    }

    final pc = Offset(playerX * w, h * .84);
    if (weather == RoadWeather.night || weather == RoadWeather.fog || weather == RoadWeather.rain) {
      _headLights(canvas, size, pc);
    }
    _car(canvas, pc, math.max(5.2, w * .018), enemy: false, lane: 0);

    _weatherParticles(canvas, size);
    _weatherOverlay(canvas, size);
    _hudGlow(canvas, size);
    _crt(canvas, size);
  }

  double _scaleForY(double y, double w) {
    final t = y.clamp(0.0, 1.0);
    return math.max(2.2, w * (.006 + t * .014));
  }

  List<Color> _skyColors() {
    switch (weather) {
      case RoadWeather.sunset: return const [Color(0xff26113f), Color(0xffd94679), Color(0xfff59e0b)];
      case RoadWeather.night: return const [Color(0xff020617), Color(0xff0a1025), Color(0xff172033)];
      case RoadWeather.fog: return const [Color(0xff64748b), Color(0xffa3b1c2), Color(0xffd7dde6)];
      case RoadWeather.snow: return const [Color(0xff9cc8f5), Color(0xffdbeafe), Color(0xffffffff)];
      case RoadWeather.rain: return const [Color(0xff0f172a), Color(0xff334155), Color(0xff475569)];
      case RoadWeather.day: return const [Color(0xff0ea5e9), Color(0xff67e8f9), Color(0xff86efac)];
    }
  }

  void _sunMoon(Canvas c, Size s) {
    if (weather == RoadWeather.night) {
      c.drawCircle(Offset(s.width * .78, s.height * .13), 24, Paint()..color = const Color(0xffe5e7eb));
      c.drawCircle(Offset(s.width * .70, s.height * .11), 2, Paint()..color = Colors.white70);
      c.drawCircle(Offset(s.width * .26, s.height * .08), 2, Paint()..color = Colors.white60);
      c.drawCircle(Offset(s.width * .48, s.height * .17), 1.6, Paint()..color = Colors.white60);
    } else if (weather == RoadWeather.sunset) {
      c.drawCircle(Offset(s.width * .72, s.height * .19), 32, Paint()..color = const Color(0xffffd166));
    } else if (weather == RoadWeather.day) {
      c.drawCircle(Offset(s.width * .78, s.height * .16), 30, Paint()..color = const Color(0xfffff3b0));
    }
  }

  void _horizon(Canvas c, Size s) {
    final mountain = Paint()..color = weather == RoadWeather.night ? const Color(0xff0b1220) : const Color(0xff1d4ed8).withOpacity(.32);
    final far = Path()
      ..moveTo(0, s.height * .36)
      ..lineTo(s.width * .15, s.height * .25)
      ..lineTo(s.width * .31, s.height * .35)
      ..lineTo(s.width * .47, s.height * .22)
      ..lineTo(s.width * .67, s.height * .36)
      ..lineTo(s.width * .83, s.height * .26)
      ..lineTo(s.width, s.height * .34)
      ..lineTo(s.width, s.height * .48)
      ..lineTo(0, s.height * .48)
      ..close();
    c.drawPath(far, mountain);

    final groundColor = weather == RoadWeather.snow ? const Color(0xfff8fafc) : weather == RoadWeather.rain ? const Color(0xff1e3a2f) : const Color(0xff166534);
    c.drawRect(Rect.fromLTWH(0, s.height * .40, s.width, s.height * .60), Paint()..color = groundColor);
  }

  void _road(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final road = Path()
      ..moveTo(w * .46, h * .37)
      ..lineTo(w * .54, h * .37)
      ..lineTo(w * .96, h)
      ..lineTo(w * .04, h)
      ..close();

    c.drawPath(road, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xff111827), Color(0xff1f2937), Color(0xff020617)],
    ).createShader(Rect.fromLTWH(0, h * .37, w, h * .63)));

    c.drawPath(road, Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = Colors.white.withOpacity(.35));

    final shoulderLeft = Path()
      ..moveTo(w * .43, h * .37)
      ..lineTo(w * .46, h * .37)
      ..lineTo(w * .04, h)
      ..lineTo(0, h)
      ..close();
    final shoulderRight = Path()
      ..moveTo(w * .54, h * .37)
      ..lineTo(w * .57, h * .37)
      ..lineTo(w, h)
      ..lineTo(w * .96, h)
      ..close();
    final shoulderPaint = Paint()..color = weather == RoadWeather.snow ? const Color(0xffdbeafe) : const Color(0xff0f5132);
    c.drawPath(shoulderLeft, shoulderPaint);
    c.drawPath(shoulderRight, shoulderPaint);
  }

  void _roadSideDetails(Canvas c, Size s) {
    final w = s.width, h = s.height;
    for (var i = 0; i < 10; i++) {
      final y = ((i * 72 + score * 3) % (h + 120)).toDouble() - 60;
      if (y < h * .38) continue;
      final t = (y / h).clamp(0.0, 1.0);
      final leftX = w * (.43 - .37 * t);
      final rightX = w * (.57 + .37 * t);
      _post(c, Offset(leftX, y), 4 + t * 7);
      _post(c, Offset(rightX, y + 28), 4 + t * 7);
    }
  }

  void _post(Canvas c, Offset o, double s) {
    c.drawRect(Rect.fromCenter(center: o, width: s, height: s * 3.2), Paint()..color = const Color(0xfff8fafc));
    c.drawRect(Rect.fromCenter(center: o.translate(0, -s), width: s * 1.4, height: s * .7), Paint()..color = const Color(0xffef4444));
  }

  void _laneMarks(Canvas c, Size s) {
    final p = Paint()..color = Colors.white.withOpacity(weather == RoadWeather.fog ? .28 : .70);
    for (var i = 0; i < 11; i++) {
      final y = ((i * 78 + score * 3) % (s.height + 110)).toDouble() - 55;
      if (y < s.height * .38) continue;
      final t = (y / s.height).clamp(0.0, 1.0);
      final len = 16 + t * 48;
      final width = 3 + t * 7;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * .5, y), width: width, height: len), const Radius.circular(4)), p);
    }
  }

  void _headLights(Canvas c, Size s, Offset pc) {
    final light = Path()
      ..moveTo(pc.dx - 22, pc.dy - 12)
      ..lineTo(pc.dx - s.width * .23, pc.dy - s.height * .37)
      ..lineTo(pc.dx + s.width * .23, pc.dy - s.height * .37)
      ..lineTo(pc.dx + 22, pc.dy - 12)
      ..close();
    c.drawPath(light, Paint()..color = const Color(0xfffff3b0).withOpacity(weather == RoadWeather.fog ? .22 : .16));
  }

  void _weatherParticles(Canvas c, Size s) {
    if (weather != RoadWeather.snow && weather != RoadWeather.rain) return;
    for (var i = 0; i < 90; i++) {
      final x = ((i * 61 + score * 2) % s.width).toDouble();
      final y = ((i * 47 + score * 5) % s.height).toDouble();
      if (weather == RoadWeather.rain) {
        c.drawLine(Offset(x, y), Offset(x - 6, y + 18), Paint()..color = const Color(0xff93c5fd).withOpacity(.70)..strokeWidth = 1.5);
      } else {
        c.drawCircle(Offset(x, y), i % 3 == 0 ? 2.4 : 1.4, Paint()..color = Colors.white.withOpacity(.90));
      }
    }
  }

  void _car(Canvas c, Offset center, double px, {required bool enemy, required int lane}) {
    final colors = [const Color(0xffef4444), const Color(0xffffd166), const Color(0xff22c55e), const Color(0xffa78bfa), const Color(0xfff97316)];
    final body = enemy ? colors[lane.abs() % colors.length] : const Color(0xff38bdf8);
    final glass = enemy ? const Color(0xffdbeafe) : const Color(0xffe0f2fe);
    RetroPixels.draw(c, center, px, const [
      '...WW...',
      '..WBBW..',
      '.WBBBBW.',
      'RBBBBBBR',
      'BBBBBBBB',
      'KBBBBBBK',
      'KBB..BBK',
      '.BB..BB.',
    ], {
      'W': glass,
      'B': body,
      'R': enemy ? const Color(0xfffff176) : const Color(0xffef4444),
      'K': const Color(0xff020617),
    }, shadow: 4);
  }

  void _weatherOverlay(Canvas c, Size s) {
    if (weather == RoadWeather.fog) c.drawRect(Offset.zero & s, Paint()..color = Colors.white.withOpacity(.30));
    if (weather == RoadWeather.night) c.drawRect(Offset.zero & s, Paint()..color = Colors.black.withOpacity(.18));
    if (weather == RoadWeather.rain) c.drawRect(Offset.zero & s, Paint()..color = Colors.blueGrey.withOpacity(.12));
  }

  void _hudGlow(Canvas c, Size s) {
    c.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), Paint()..style = PaintingStyle.stroke..strokeWidth = 10..color = Colors.black.withOpacity(.20));
  }

  void _crt(Canvas c, Size s) {
    final p = Paint()..color = Colors.black.withOpacity(.10);
    for (double y = 0; y < s.height; y += 5) {
      c.drawRect(Rect.fromLTWH(0, y, s.width, 1), p);
    }
  }

  @override
  bool shouldRepaint(covariant RetroRoadPainter oldDelegate) => true;
}
