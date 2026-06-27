import 'package:flutter/material.dart';
import 'fuel_plane_models.dart';

class FuelPlanePainter extends CustomPainter {
  FuelPlanePainter({required this.planeX, required this.objects, required this.bullets, required this.level});
  final double planeX;
  final List<PlaneObject> objects;
  final List<PlaneBullet> bullets;
  final int level;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sky = Paint()..color = const Color(0xff07111f);
    canvas.drawRect(Offset.zero & size, sky);

    final road = Path()
      ..moveTo(w * 0.18, 0)
      ..lineTo(w * 0.82, 0)
      ..lineTo(w * 0.94, h)
      ..lineTo(w * 0.06, h)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xff123148));
    final edge = Paint()..color = Colors.white24..strokeWidth = 2;
    canvas.drawLine(Offset(w * 0.18, 0), Offset(w * 0.06, h), edge);
    canvas.drawLine(Offset(w * 0.82, 0), Offset(w * 0.94, h), edge);

    final marker = Paint()..color = Colors.white12..strokeWidth = 3;
    for (int i = 0; i < 8; i++) {
      final y = ((i * 90 + level * 11) % (h + 100)).toDouble() - 70;
      canvas.drawLine(Offset(w * 0.50, y), Offset(w * 0.50, y + 34), marker);
    }

    for (final b in bullets) {
      canvas.drawCircle(Offset(b.x * w, b.y * h), 5, Paint()..color = Colors.yellowAccent);
    }

    for (final o in objects) {
      final center = Offset(o.x * w, o.y * h);
      final s = o.size * w;
      if (o.type == PlaneObjectType.fuel) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: s, height: s * 1.25), const Radius.circular(7)), Paint()..color = Colors.greenAccent);
        canvas.drawRect(Rect.fromCenter(center: center.translate(0, -s * 0.7), width: s * 0.45, height: 5), Paint()..color = Colors.white70);
      } else if (o.type == PlaneObjectType.enemy) {
        final p = Paint()..color = Colors.orangeAccent;
        final enemy = Path()
          ..moveTo(center.dx, center.dy + s * 0.55)
          ..lineTo(center.dx - s * 0.6, center.dy - s * 0.2)
          ..lineTo(center.dx, center.dy)
          ..lineTo(center.dx + s * 0.6, center.dy - s * 0.2)
          ..close();
        canvas.drawPath(enemy, p);
      } else {
        canvas.drawCircle(center, s * 0.55, Paint()..color = Colors.redAccent);
        canvas.drawCircle(center.translate(-s * 0.16, -s * 0.16), s * 0.18, Paint()..color = Colors.black26);
      }
    }

    final px = planeX * w;
    final py = h * 0.82;
    final body = Paint()..color = Colors.lightBlueAccent;
    final wings = Paint()..color = Colors.blueAccent;
    final plane = Path()
      ..moveTo(px, py - 34)
      ..lineTo(px - 16, py + 26)
      ..lineTo(px, py + 12)
      ..lineTo(px + 16, py + 26)
      ..close();
    canvas.drawPath(plane, body);
    final wingPath = Path()
      ..moveTo(px - 8, py)
      ..lineTo(px - 42, py + 16)
      ..lineTo(px - 8, py + 18)
      ..moveTo(px + 8, py)
      ..lineTo(px + 42, py + 16)
      ..lineTo(px + 8, py + 18);
    canvas.drawPath(wingPath, wings);
  }

  @override
  bool shouldRepaint(covariant FuelPlanePainter oldDelegate) => true;
}
