import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/graphics/retro_pixels.dart';
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
    final bg = Offset.zero & size;
    canvas.drawRect(bg, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xff061022), Color(0xff0a2e4f), Color(0xff061022)],
    ).createShader(bg));

    final star = Paint()..color = Colors.white.withOpacity(.55);
    for (var i = 0; i < 48; i++) {
      final x = ((i * 73 + level * 17) % w).toDouble();
      final y = ((i * 41 + level * 13) % (h * .45)).toDouble();
      canvas.drawRect(Rect.fromLTWH(x, y, i % 6 == 0 ? 3 : 2, i % 6 == 0 ? 3 : 2), star);
    }

    final river = Path()
      ..moveTo(w * .22, 0)
      ..quadraticBezierTo(w * .13, h * .26, w * .28, h * .50)
      ..quadraticBezierTo(w * .42, h * .72, w * .16, h)
      ..lineTo(w * .84, h)
      ..quadraticBezierTo(w * .58, h * .72, w * .72, h * .50)
      ..quadraticBezierTo(w * .87, h * .26, w * .78, 0)
      ..close();
    canvas.drawPath(river, Paint()..color = const Color(0xff145d87));
    canvas.drawPath(river, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xff7dd3fc).withOpacity(.35));

    final bank = Paint()..color = const Color(0xff0f3b1d);
    for (var i = 0; i < 14; i++) {
      final y = ((i * 64 + level * 9) % (h + 80)).toDouble() - 40;
      canvas.drawRect(Rect.fromLTWH(0, y, w * .12, 18), bank);
      canvas.drawRect(Rect.fromLTWH(w * .88, y + 28, w * .12, 18), bank);
    }

    for (final b in bullets) {
      canvas.drawCircle(Offset(b.x * w, b.y * h), 5, Paint()..color = const Color(0xfffff176));
      canvas.drawCircle(Offset(b.x * w, b.y * h), 11, Paint()..color = const Color(0xfffff176).withOpacity(.16));
    }

    for (final o in objects) {
      final c = Offset(o.x * w, o.y * h);
      final p = math.max(2.2, o.size * w / 9);
      if (o.type == PlaneObjectType.fuel) {
        RetroPixels.draw(canvas, c, p, const [
          '..GG..','..YY..','.YYYY.','.YRR.','.YRR.','.YYYY.','..GG..'
        ], {'G': const Color(0xff22c55e), 'Y': const Color(0xffffd166), 'R': const Color(0xffef4444)}, shadow: 3);
      } else if (o.type == PlaneObjectType.enemy) {
        RetroPixels.draw(canvas, c, p, const [
          '...R...','..RRR..','.RBRBR.','RRBBB R','..BBB..','.B...B.'
        ], {'R': const Color(0xffef4444), 'B': const Color(0xff374151)}, shadow: 3);
      } else {
        RetroPixels.draw(canvas, c, p, const [
          '..SS..','.SSSS.','SSSSSS','SDSDSS','.SSSS.','..SS..'
        ], {'S': const Color(0xff94a3b8), 'D': const Color(0xff334155)}, shadow: 3);
      }
    }

    final pc = Offset(planeX * w, h * .82);
    RetroPixels.draw(canvas, pc, math.max(3, w * .012), const [
      '.....C.....','....CCC....','....YYY....','B..YYYYY..B','BBYYYYYYYBB','..RYYYR..','...Y.Y...','..B...B..'
    ], {'C': const Color(0xffe0f2fe), 'Y': const Color(0xff38bdf8), 'B': const Color(0xff2563eb), 'R': const Color(0xffef4444)}, shadow: 4);

    final flame = Paint()..color = const Color(0xffff7a18).withOpacity(.75);
    canvas.drawCircle(Offset(pc.dx, pc.dy + 38), 8 + (level % 3).toDouble(), flame);

    final scan = Paint()..color = Colors.black.withOpacity(.12);
    for (double y = 0; y < h; y += 5) {
      canvas.drawRect(Rect.fromLTWH(0, y, w, 1), scan);
    }
  }

  @override
  bool shouldRepaint(covariant FuelPlanePainter oldDelegate) => true;
}
