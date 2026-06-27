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
    ).createShader(bg));

    _sunMoon(canvas, size);
    _mountains(canvas, size);
    _ground(canvas, size);
    _road(canvas, size);
    _laneMarks(canvas, size);
    _particles(canvas, size);

    for (final car in cars) {
      final c = Offset(car.x * w, car.y * h);
      _car(canvas, c, math.max(2.8, w * .010), enemy: true, lane: car.lane);
    }

    final pc = Offset(playerX * w, h * .82);
    if (weather == RoadWeather.night || weather == RoadWeather.fog || weather == RoadWeather.rain) {
      final light = Path()
        ..moveTo(pc.dx - 14, pc.dy - 8)
        ..lineTo(pc.dx - w * .20, pc.dy - h * .35)
        ..lineTo(pc.dx + w * .20, pc.dy - h * .35)
        ..lineTo(pc.dx + 14, pc.dy - 8)
        ..close();
      canvas.drawPath(light, Paint()..color = const Color(0xfffff3b0).withOpacity(.18));
    }
    _car(canvas, pc, math.max(3.2, w * .0115), enemy: false, lane: 0);
    _overlay(canvas, size);
    _crt(canvas, size);
  }

  List<Color> _skyColors() {
    switch (weather) {
      case RoadWeather.sunset: return const [Color(0xff3b0764), Color(0xfffb7185), Color(0xfff59e0b)];
      case RoadWeather.night: return const [Color(0xff020617), Color(0xff0f172a), Color(0xff111827)];
      case RoadWeather.fog: return const [Color(0xff64748b), Color(0xff94a3b8), Color(0xffcbd5e1)];
      case RoadWeather.snow: return const [Color(0xffbfdbfe), Color(0xffdbeafe), Color(0xfff8fafc)];
      case RoadWeather.rain: return const [Color(0xff111827), Color(0xff334155), Color(0xff475569)];
      case RoadWeather.day: return const [Color(0xff38bdf8), Color(0xff60a5fa), Color(0xffbbf7d0)];
    }
  }

  void _sunMoon(Canvas c, Size s) {
    if (weather == RoadWeather.night) {
      c.drawCircle(Offset(s.width * .78, s.height * .12), 22, Paint()..color = const Color(0xffe5e7eb));
    } else if (weather == RoadWeather.sunset) {
      c.drawCircle(Offset(s.width * .72, s.height * .16), 30, Paint()..color = const Color(0xffffd166));
    }
  }

  void _mountains(Canvas c, Size s) {
    final p = Paint()..color = weather == RoadWeather.night ? const Color(0xff111827) : const Color(0xff2563eb).withOpacity(.28);
    final path = Path()
      ..moveTo(0, s.height * .33)
      ..lineTo(s.width * .18, s.height * .22)
      ..lineTo(s.width * .34, s.height * .34)
      ..lineTo(s.width * .55, s.height * .20)
      ..lineTo(s.width * .78, s.height * .35)
      ..lineTo(s.width, s.height * .24)
      ..lineTo(s.width, s.height * .50)
      ..lineTo(0, s.height * .50)
      ..close();
    c.drawPath(path, p);
  }

  void _ground(Canvas c, Size s) {
    c.drawRect(Rect.fromLTWH(0, s.height * .38, s.width, s.height * .62), Paint()..color = weather == RoadWeather.snow ? const Color(0xfff8fafc) : const Color(0xff14532d));
  }

  void _road(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final road = Path()
      ..moveTo(w * .42, h * .34)
      ..lineTo(w * .58, h * .34)
      ..lineTo(w * .94, h)
      ..lineTo(w * .06, h)
      ..close();
    c.drawPath(road, Paint()..color = const Color(0xff1f2937));
    c.drawPath(road, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = Colors.white.withOpacity(.25));
  }

  void _laneMarks(Canvas c, Size s) {
    final p = Paint()..color = Colors.white.withOpacity(weather == RoadWeather.fog ? .25 : .55);
    for (var i = 0; i < 13; i++) {
      final y = ((i * 66 + score * 2) % (s.height + 80)).toDouble() - 40;
      final t = y / s.height;
      final x = s.width * .5;
      final len = 14 + t * 32;
      final width = 3 + t * 4;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: width, height: len), const Radius.circular(3)), p);
    }
  }

  void _particles(Canvas c, Size s) {
    if (weather != RoadWeather.snow && weather != RoadWeather.rain) return;
    final p = Paint()..color = weather == RoadWeather.snow ? Colors.white.withOpacity(.85) : const Color(0xff93c5fd).withOpacity(.65);
    for (var i = 0; i < 70; i++) {
      final x = ((i * 61 + score * 3) % s.width).toDouble();
      final y = ((i * 47 + score * 6) % s.height).toDouble();
      if (weather == RoadWeather.rain) {
        c.drawLine(Offset(x, y), Offset(x - 5, y + 13), p..strokeWidth = 1.4);
      } else {
        c.drawCircle(Offset(x, y), i % 3 == 0 ? 2.2 : 1.4, p);
      }
    }
  }

  void _car(Canvas c, Offset center, double px, {required bool enemy, required int lane}) {
    final body = enemy ? [const Color(0xffef4444), const Color(0xffffd166), const Color(0xff22c55e)][lane.abs() % 3] : const Color(0xff38bdf8);
    RetroPixels.draw(c, center, px, const [
      '..WW..', '.WBBW.', '.BBBB.', 'RBBBBR', 'BBBBBB', 'KBBBBK', '.B..B.'
    ], {
      'W': const Color(0xffe0f2fe),
      'B': body,
      'R': enemy ? const Color(0xfffff176) : const Color(0xffef4444),
      'K': const Color(0xff020617),
    }, shadow: 3);
  }

  void _overlay(Canvas c, Size s) {
    if (weather == RoadWeather.fog) c.drawRect(Offset.zero & s, Paint()..color = Colors.white.withOpacity(.34));
    if (weather == RoadWeather.night) c.drawRect(Offset.zero & s, Paint()..color = Colors.black.withOpacity(.26));
    if (weather == RoadWeather.rain) c.drawRect(Offset.zero & s, Paint()..color = Colors.blueGrey.withOpacity(.14));
  }

  void _crt(Canvas c, Size s) {
    final p = Paint()..color = Colors.black.withOpacity(.11);
    for (double y = 0; y < s.height; y += 5) {
      c.drawRect(Rect.fromLTWH(0, y, s.width, 1), p);
    }
  }

  @override
  bool shouldRepaint(covariant RetroRoadPainter oldDelegate) => true;
}
