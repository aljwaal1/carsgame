import 'package:flutter/material.dart';
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
    canvas.drawRect(Offset.zero & size, Paint()..color = _skyColor());

    final road = Path()
      ..moveTo(w * 0.20, 0)
      ..lineTo(w * 0.80, 0)
      ..lineTo(w * 0.94, h)
      ..lineTo(w * 0.06, h)
      ..close();
    canvas.drawPath(road, Paint()..color = _roadColor());

    final edge = Paint()..color = Colors.white30..strokeWidth = 2;
    canvas.drawLine(Offset(w * 0.20, 0), Offset(w * 0.06, h), edge);
    canvas.drawLine(Offset(w * 0.80, 0), Offset(w * 0.94, h), edge);

    final dash = Paint()..color = Colors.white24..strokeWidth = 3;
    for (int lane = 1; lane <= 3; lane++) {
      final x = w * (0.25 + lane * 0.125);
      for (int i = 0; i < 8; i++) {
        final y = ((i * 95 + score * 0.35) % (h + 100)) - 60;
        canvas.drawLine(Offset(x, y), Offset(x, y + 35), dash);
      }
    }

    if (weather == RoadWeather.snow) _drawSnow(canvas, size);
    if (weather == RoadWeather.rain) _drawRain(canvas, size);

    for (final car in cars) {
      _drawCar(canvas, Offset(car.x * w, car.y * h), w * 0.105, false);
    }
    _drawCar(canvas, Offset(playerX * w, h * 0.82), w * 0.12, true);

    if (weather == RoadWeather.night) {
      canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black.withOpacity(0.38));
      _drawHeadLights(canvas, Offset(playerX * w, h * 0.82), w, h);
    }
    if (weather == RoadWeather.fog) {
      canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white.withOpacity(0.42));
      canvas.drawRect(Rect.fromLTWH(0, h * 0.55, w, h * 0.45), Paint()..color = Colors.transparent..blendMode = BlendMode.clear);
    }
  }

  Color _skyColor() {
    switch (weather) {
      case RoadWeather.day: return const Color(0xff2b6cb0);
      case RoadWeather.sunset: return const Color(0xff7c2d12);
      case RoadWeather.night: return const Color(0xff020617);
      case RoadWeather.fog: return const Color(0xff64748b);
      case RoadWeather.snow: return const Color(0xffdbeafe);
      case RoadWeather.rain: return const Color(0xff1e293b);
    }
  }

  Color _roadColor() => weather == RoadWeather.snow ? const Color(0xff94a3b8) : const Color(0xff263244);

  void _drawCar(Canvas canvas, Offset c, double s, bool player) {
    final body = Paint()..color = player ? Colors.cyanAccent : Colors.redAccent;
    final shade = Paint()..color = Colors.black45;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: s * 0.72, height: s * 1.25), Radius.circular(s * 0.12)), body);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c.translate(0, -s * 0.18), width: s * 0.45, height: s * 0.35), Radius.circular(s * 0.08)), shade);
    canvas.drawCircle(c.translate(-s * 0.32, s * 0.34), s * 0.09, shade);
    canvas.drawCircle(c.translate(s * 0.32, s * 0.34), s * 0.09, shade);
    if (!player && weather == RoadWeather.night) {
      final light = Paint()..color = Colors.redAccent.withOpacity(0.9);
      canvas.drawCircle(c.translate(-s * 0.20, s * 0.52), 3, light);
      canvas.drawCircle(c.translate(s * 0.20, s * 0.52), 3, light);
    }
  }

  void _drawHeadLights(Canvas canvas, Offset c, double w, double h) {
    final light = Paint()..color = Colors.yellowAccent.withOpacity(0.13);
    final beam = Path()
      ..moveTo(c.dx - 18, c.dy - 25)
      ..lineTo(w * 0.20, 0)
      ..lineTo(w * 0.80, 0)
      ..lineTo(c.dx + 18, c.dy - 25)
      ..close();
    canvas.drawPath(beam, light);
  }

  void _drawSnow(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.75);
    for (int i = 0; i < 70; i++) {
      final x = ((i * 47 + score * 0.35) % size.width).toDouble();
      final y = ((i * 83 + score * 0.8) % size.height).toDouble();
      canvas.drawCircle(Offset(x, y), 1.6, paint);
    }
  }

  void _drawRain(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.lightBlueAccent.withOpacity(0.45)..strokeWidth = 1.2;
    for (int i = 0; i < 60; i++) {
      final x = ((i * 55 + score * 1.1) % size.width).toDouble();
      final y = ((i * 77 + score * 1.5) % size.height).toDouble();
      canvas.drawLine(Offset(x, y), Offset(x - 8, y + 16), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RetroRoadPainter oldDelegate) => true;
}
