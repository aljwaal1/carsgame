import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() => runApp(const RetroApp());

class RetroApp extends StatelessWidget {
  const RetroApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ألعاب زمان V5.1',
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xff040816),
          appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Color(0xff07111f)),
        ),
        home: const Directionality(textDirection: TextDirection.rtl, child: Home()),
      );
}

class Sfx {
  static final AudioPlayer _p = AudioPlayer();
  static int _engineTick = 0;
  static int _speedTick = 0;
  static int _shotTick = 0;

  static Future<void> play(String path, double volume) async {
    try {
      await _p.stop();
      await _p.play(AssetSource(path), volume: volume);
    } catch (_) {}
  }

  static void start() => play('sounds/shared/game_start.wav', .55);
  static void over() => play('sounds/shared/game_over.wav', .76);
  static void crash() => play('sounds/fuel_plane/plane_explosion.wav', .80);
  static void fuel() => play('sounds/fuel_plane/fuel_pickup.wav', .62);
  static void pass() => play('sounds/retro_road/car_pass.wav', .34);
  static void steer() => play('sounds/retro_road/car_pass.wav', .20);
  static void stage() => play('sounds/retro_road/stage_clear.wav', .55);

  static void crashThenOver() {
    crash();
    Future.delayed(const Duration(milliseconds: 520), over);
  }

  static void engine(int tick, double throttle) {
    final gap = (36 - throttle * 18).round().clamp(15, 36);
    if (tick - _engineTick >= gap) {
      _engineTick = tick;
      play('sounds/retro_road/car_pass.wav', .09 + throttle * .12);
    }
  }

  static void speedTap(int tick, double throttle) {
    if (tick - _speedTick > 8) {
      _speedTick = tick;
      play('sounds/retro_road/car_pass.wav', .20 + throttle * .16);
    }
  }

  static void shot(int tick) {
    if (tick - _shotTick > 10) {
      _shotTick = tick;
      play('sounds/fuel_plane/plane_shoot.wav', .24);
    }
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff020617), Color(0xff0b1028), Color(0xff082f49)]),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const SizedBox(height: 18),
                const Text('ألعاب زمان V5.1', textAlign: TextAlign.center, style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('السيارات + طائرة الوقود مع GAS على عبوة البنزين', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 28),
                GameTile(title: 'طريق التحمل', icon: '🏎️', text: 'تحكم بالسحب، سرعة، طقس، واصطدام.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: RoadGame())))),
                const SizedBox(height: 16),
                GameTile(title: 'طائرة الوقود', icon: '✈️', text: 'وقود أقل، أعداء أكثر، وعبوة مكتوب عليها GAS.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: PlaneGame())))),
                const Spacer(),
                const Text('تصميم أصلي مستوحى من ألعاب التحمل القديمة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
              ]),
            ),
          ),
        ),
      );
}

class GameTile extends StatelessWidget {
  const GameTile({super.key, required this.title, required this.icon, required this.text, required this.onTap});
  final String title;
  final String icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.lightBlueAccent.withOpacity(.18)), boxShadow: [BoxShadow(color: Colors.lightBlueAccent.withOpacity(.10), blurRadius: 28)]),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 42)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(text, style: const TextStyle(color: Colors.white70))])),
            const Icon(Icons.play_circle_fill, color: Colors.lightBlueAccent, size: 36),
          ]),
        ),
      );
}

class RetroButton extends StatelessWidget {
  const RetroButton({super.key, required this.text, required this.icon, required this.onTap});
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(onPressed: onTap, icon: Icon(icon), label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))));
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withOpacity(.10), Colors.white.withOpacity(.035)]), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.cyanAccent.withOpacity(.16))),
        child: Column(children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)), const SizedBox(height: 2), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900))]),
      );
}

class SpeedPad extends StatelessWidget {
  const SpeedPad({super.key, required this.throttle, required this.speed, required this.onUp, required this.onDown});
  final double throttle;
  final int speed;
  final VoidCallback onUp;
  final VoidCallback onDown;
  @override
  Widget build(BuildContext context) => Container(
        width: 50,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.black.withOpacity(.35), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.cyanAccent.withOpacity(.22))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          InkWell(onTap: onUp, child: const Icon(Icons.keyboard_arrow_up, size: 22, color: Colors.cyanAccent)),
          SizedBox(height: 45, child: RotatedBox(quarterTurns: 3, child: LinearProgressIndicator(value: throttle, minHeight: 6, backgroundColor: Colors.white12, color: Colors.cyanAccent))),
          Text('$speed', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          InkWell(onTap: onDown, child: const Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.orangeAccent)),
        ]),
      );
}

class HintBox extends StatelessWidget {
  const HintBox({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(color: Colors.black.withOpacity(.30), borderRadius: BorderRadius.circular(13), border: Border.all(color: Colors.white12)),
        child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      );
}

class OverlayCard extends StatelessWidget {
  const OverlayCard({super.key, required this.title, required this.subtitle, required this.button, required this.onTap, this.danger = false});
  final String title;
  final String subtitle;
  final String button;
  final VoidCallback onTap;
  final bool danger;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(22),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.black.withOpacity(.78), borderRadius: BorderRadius.circular(24), border: Border.all(color: (danger ? Colors.redAccent : Colors.cyanAccent).withOpacity(.28)), boxShadow: [BoxShadow(color: (danger ? Colors.redAccent : Colors.cyanAccent).withOpacity(.16), blurRadius: 34)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(danger ? Icons.warning_amber_rounded : Icons.play_circle_fill, size: 52, color: danger ? Colors.redAccent : Colors.cyanAccent),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          RetroButton(text: button, icon: Icons.play_arrow, onTap: onTap),
        ]),
      );
}

class EndCard extends StatelessWidget {
  const EndCard({super.key, required this.title, required this.score, required this.extra, required this.onTap, required this.plane});
  final String title;
  final int score;
  final String extra;
  final VoidCallback onTap;
  final bool plane;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xdd1f0202), Color(0xee050505)]), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.redAccent.withOpacity(.42), width: 1.5), boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(.20), blurRadius: 40)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 115, child: CustomPaint(painter: EndPainter(plane: plane), child: const SizedBox.expand())),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.redAccent)),
          const SizedBox(height: 6),
          Text('النقاط: $score   |   $extra', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          RetroButton(text: 'إعادة اللعب', icon: Icons.replay, onTap: onTap),
        ]),
      );
}

class EndPainter extends CustomPainter {
  EndPainter({required this.plane});
  final bool plane;
  @override
  void paint(Canvas c, Size s) {
    final o = Offset(s.width * .5, s.height * .58);
    c.drawOval(Rect.fromCenter(center: o.translate(0, 18), width: s.width * .66, height: 20), Paint()..color = Colors.black.withOpacity(.55));
    c.drawCircle(o.translate(0, -8), 56, Paint()..color = Colors.redAccent.withOpacity(.18)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    if (plane) {
      c.save();
      c.translate(o.dx, o.dy);
      c.rotate(-.35);
      c.translate(-o.dx, -o.dy);
      c.drawPath(Path()..moveTo(o.dx, o.dy - 48)..lineTo(o.dx - 18, o.dy + 32)..lineTo(o.dx + 18, o.dy + 32)..close(), Paint()..color = const Color(0xff38bdf8));
      c.drawPath(Path()..moveTo(o.dx - 14, o.dy - 4)..lineTo(o.dx - 70, o.dy + 14)..lineTo(o.dx - 10, o.dy + 20)..close(), Paint()..color = const Color(0xff2563eb));
      c.drawPath(Path()..moveTo(o.dx + 14, o.dy - 4)..lineTo(o.dx + 70, o.dy + 14)..lineTo(o.dx + 10, o.dy + 20)..close(), Paint()..color = const Color(0xff2563eb));
      c.restore();
    } else {
      c.save();
      c.translate(o.dx, o.dy);
      c.rotate(-.13);
      c.translate(-o.dx, -o.dy);
      c.drawPath(Path()..moveTo(o.dx - 70, o.dy + 2)..lineTo(o.dx - 48, o.dy - 25)..lineTo(o.dx - 12, o.dy - 35)..lineTo(o.dx + 42, o.dy - 20)..lineTo(o.dx + 72, o.dy + 5)..lineTo(o.dx + 50, o.dy + 28)..lineTo(o.dx - 58, o.dy + 25)..close(), Paint()..color = const Color(0xffef4444));
      c.drawCircle(o.translate(-48, 25), 13, Paint()..color = const Color(0xff020617));
      c.drawCircle(o.translate(45, 25), 13, Paint()..color = const Color(0xff020617));
      c.restore();
    }
    final spark = Paint()..color = Colors.orangeAccent.withOpacity(.90)..strokeWidth = 2;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final p = Offset(o.dx + math.cos(a) * 42, o.dy - 18 + math.sin(a) * 24);
      c.drawLine(p, Offset(p.dx + math.cos(a) * 15, p.dy + math.sin(a) * 15), spark);
    }
  }
  @override
  bool shouldRepaint(covariant EndPainter oldDelegate) => false;
}

class PlaneObj {
  PlaneObj({required this.x, required this.y, required this.kind, required this.speed});
  double x;
  double y;
  double speed;
  int kind;
}

class PlaneBullet {
  PlaneBullet(this.x, this.y);
  double x;
  double y;
}

class PlaneGame extends StatefulWidget {
  const PlaneGame({super.key});
  @override
  State<PlaneGame> createState() => _PlaneGameState();
}

class _PlaneGameState extends State<PlaneGame> {
  final rnd = math.Random();
  Timer? timer;
  double x = .5;
  double y = .78;
  double throttle = .55;
  double fuel = 100;
  double dx = 0;
  double dy = 0;
  int score = 0;
  int tick = 0;
  int distance = 0;
  int lives = 3;
  int level = 1;
  int crashFlash = 0;
  bool running = false;
  bool stopped = false;
  bool gameOver = false;
  final objects = <PlaneObj>[];
  final bullets = <PlaneBullet>[];
  int get speed => (70 + throttle * 170).round();

  void start() {
    timer?.cancel();
    x = .5;
    y = .78;
    throttle = .55;
    fuel = 100;
    score = 0;
    tick = 0;
    distance = 0;
    lives = 3;
    level = 1;
    crashFlash = 0;
    running = true;
    stopped = false;
    gameOver = false;
    objects.clear();
    bullets.clear();
    Sfx.start();
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) => step());
    setState(() {});
  }

  void resume() {
    stopped = false;
    running = true;
    crashFlash = 0;
    Sfx.start();
    setState(() {});
  }

  void step() {
    if (crashFlash > 0) crashFlash--;
    if (!running) {
      if (mounted) setState(() {});
      return;
    }
    tick++;
    distance++;
    level = 1 + distance ~/ 1350;
    Sfx.engine(tick, throttle);
    fuel -= .026 + throttle * .031;
    if (tick % 10 == 0) {
      bullets.add(PlaneBullet(x, y - .070));
      Sfx.shot(tick);
    }
    final spawn = (.020 + level * .0020 + throttle * .013).clamp(.020, .058).toDouble();
    if (rnd.nextDouble() < spawn) {
      final r = rnd.nextDouble();
      final kind = r < .10 ? 0 : r < .78 ? 1 : r < .88 ? 2 : 3;
      objects.add(PlaneObj(x: .10 + rnd.nextDouble() * .80, y: -.08, kind: kind, speed: .0048 + rnd.nextDouble() * .0035 + throttle * .0045));
    }
    for (final b in bullets) b.y -= .037 + throttle * .010;
    bullets.removeWhere((b) => b.y < -.08);
    for (final o in objects) o.y += o.speed;
    objects.removeWhere((o) => o.y > 1.12);
    final deadO = <PlaneObj>[];
    final deadB = <PlaneBullet>[];
    for (final b in bullets) {
      for (final o in objects) {
        if (o.kind == 1 && (b.x - o.x).abs() < .045 && (b.y - o.y).abs() < .055) {
          deadO.add(o);
          deadB.add(b);
          score += 75;
          Sfx.crash();
          break;
        }
      }
    }
    objects.removeWhere(deadO.contains);
    bullets.removeWhere(deadB.contains);
    for (final o in List<PlaneObj>.from(objects)) {
      if ((x - o.x).abs() < .060 && (y - o.y).abs() < .070) {
        if (o.kind == 0) {
          fuel = math.min(100, fuel + 22).toDouble();
          score += 130;
          objects.remove(o);
          Sfx.fuel();
        } else if (o.kind == 3) {
          score += 180;
          objects.remove(o);
          Sfx.stage();
        } else {
          objects.remove(o);
          crash();
          break;
        }
      }
    }
    if (fuel <= 0) crash(finalCrash: true);
    if (tick % 12 == 0) score += (1 + throttle * 2).round();
    if (mounted) setState(() {});
  }

  void crash({bool finalCrash = false}) {
    running = false;
    crashFlash = 16;
    if (lives > 1 && !finalCrash) {
      lives--;
      stopped = true;
      throttle = math.max(.35, throttle - .18).toDouble();
      fuel = math.max(22, fuel).toDouble();
      Sfx.crash();
    } else {
      lives = 0;
      stopped = false;
      gameOver = true;
      Sfx.crashThenOver();
    }
  }

  void changeThrottle(double delta) {
    if (!running) return;
    final old = throttle;
    throttle = (throttle + delta).clamp(.20, 1.0).toDouble();
    if ((old - throttle).abs() > .025) Sfx.speedTap(tick, throttle);
    setState(() {});
  }

  void onPanStart(DragStartDetails d) {
    dx = 0;
    dy = 0;
  }

  void onPanUpdate(DragUpdateDetails d) {
    if (!running) return;
    dx += d.delta.dx;
    dy += d.delta.dy;
    x = (x + d.delta.dx / 260).clamp(.08, .92).toDouble();
    y = (y + d.delta.dy / 420).clamp(.22, .88).toDouble();
    if (dy.abs() > 18 && dy.abs() > dx.abs()) {
      changeThrottle(dy < 0 ? .05 : -.05);
      dx = 0;
      dy = 0;
    }
    setState(() {});
  }

  void onPanEnd(DragEndDetails d) {
    dx = 0;
    dy = 0;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = !running || stopped || gameOver;
    return Scaffold(
      appBar: AppBar(title: const Text('طائرة الوقود V5.1')),
      body: SafeArea(child: Column(children: [
        PlaneHud(score: score, fuel: fuel, lives: lives, speed: speed),
        Expanded(child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.lightBlueAccent.withOpacity(.22)), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(.10), blurRadius: 28)]),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: onPanStart,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            child: Stack(children: [
              CustomPaint(painter: PlanePainter(x: x, y: y, objects: objects, bullets: bullets, tick: tick, throttle: throttle, crashFlash: crashFlash), child: const SizedBox.expand()),
              Positioned(right: 10, bottom: 12, child: SpeedPad(throttle: throttle, speed: speed, onUp: () => changeThrottle(.08), onDown: () => changeThrottle(-.08))),
              const Positioned(left: 10, bottom: 12, child: HintBox(text: 'اسحب لتحريك الطائرة\n↑ تسارع ↓ تهدئة\nGAS للوقود')),
              if (overlay && gameOver) Center(child: EndCard(title: 'PLANE DOWN', score: score, extra: 'مرحلة: $level', plane: true, onTap: start)),
              if (overlay && !gameOver) Center(child: OverlayCard(title: stopped ? 'ضربة!' : 'طائرة الوقود', subtitle: stopped ? 'تبقى لديك $lives أرواح — تابع' : 'اسحب للتحرك، اجمع GAS، واضرب الأعداء', button: stopped ? 'تابع' : 'ابدأ', danger: stopped, onTap: stopped ? resume : start)),
            ]),
          ),
        )),
      ])),
    );
  }
}

class PlaneHud extends StatelessWidget {
  const PlaneHud({super.key, required this.score, required this.fuel, required this.lives, required this.speed});
  final int score;
  final double fuel;
  final int lives;
  final int speed;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(children: [
          Row(children: [Expanded(child: InfoChip(label: 'النقاط', value: '$score')), const SizedBox(width: 6), Expanded(child: InfoChip(label: 'الوقود', value: '${fuel.clamp(0, 100).round()}%')), const SizedBox(width: 6), Expanded(child: InfoChip(label: 'الأرواح', value: '$lives')), const SizedBox(width: 6), Expanded(child: InfoChip(label: 'السرعة', value: '$speed'))]),
          const SizedBox(height: 7),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: fuel.clamp(0, 100).toDouble() / 100, minHeight: 8, backgroundColor: Colors.white12, color: fuel > 35 ? Colors.cyanAccent : Colors.orangeAccent)),
        ]),
      );
}

class PlanePainter extends CustomPainter {
  PlanePainter({required this.x, required this.y, required this.objects, required this.bullets, required this.tick, required this.throttle, required this.crashFlash});
  final double x;
  final double y;
  final double throttle;
  final List<PlaneObj> objects;
  final List<PlaneBullet> bullets;
  final int tick;
  final int crashFlash;

  @override
  void paint(Canvas c, Size s) {
    final bg = Offset.zero & s;
    c.drawRect(bg, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff020617), Color(0xff075985), Color(0xff0e7490)]).createShader(bg));
    drawWorld(c, s);
    drawSpeedLines(c, s);
    for (final o in objects) drawObject(c, s, o);
    for (final b in bullets) drawBullet(c, s, b);
    drawPlane(c, Offset(x * s.width, y * s.height), s.width * .115);
    if (crashFlash > 0) drawCrash(c, s);
    drawScan(c, s);
  }

  void drawWorld(Canvas c, Size s) {
    final river = Path()
      ..moveTo(s.width * .28, 0)
      ..cubicTo(s.width * .10, s.height * .22, s.width * .38, s.height * .42, s.width * .23, s.height * .66)
      ..cubicTo(s.width * .12, s.height * .86, s.width * .15, s.height, s.width * .08, s.height)
      ..lineTo(s.width * .92, s.height)
      ..cubicTo(s.width * .85, s.height * .82, s.width * .88, s.height * .66, s.width * .76, s.height * .50)
      ..cubicTo(s.width * .62, s.height * .30, s.width * .88, s.height * .18, s.width * .72, 0)
      ..close();
    c.drawPath(river, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff155e75), Color(0xff0891b2), Color(0xff0e7490)]).createShader(Offset.zero & s));
    final bank = Paint()..color = const Color(0xff14532d);
    for (var i = 0; i < 18; i++) {
      final yy = ((i * 68 + tick * (2 + throttle * 3).round()) % (s.height + 90)).toDouble() - 45;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, yy, s.width * .14, 22), const Radius.circular(6)), bank);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * .86, yy + 28, s.width * .14, 22), const Radius.circular(6)), bank);
    }
  }

  void drawSpeedLines(Canvas c, Size s) {
    final p = Paint()..color = Colors.white.withOpacity(.10 + throttle * .10)..strokeWidth = 1.2 + throttle * 1.5;
    for (var i = 0; i < 20; i++) {
      final xx = ((i * 53 + tick * 4) % s.width).toDouble();
      final yy = ((i * 77 + tick * (8 + throttle * 12).round()) % s.height).toDouble();
      c.drawLine(Offset(xx, yy), Offset(xx, yy + 26 + throttle * 36), p);
    }
  }

  void drawObject(Canvas c, Size s, PlaneObj o) {
    final center = Offset(o.x * s.width, o.y * s.height);
    if (o.kind == 0) {
      final can = Rect.fromCenter(center: center, width: 34, height: 44);
      c.drawRRect(RRect.fromRectAndRadius(can, const Radius.circular(8)), Paint()..color = const Color(0xffffd166));
      c.drawRect(Rect.fromCenter(center: center.translate(0, 4), width: 12, height: 24), Paint()..color = const Color(0xffef4444));
      c.drawCircle(center.translate(0, -13), 5, Paint()..color = Colors.white.withOpacity(.80));
      final gasText = TextPainter(
        text: const TextSpan(text: 'GAS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .4)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      gasText.paint(c, Offset(center.dx - gasText.width / 2, center.dy - gasText.height / 2 + 6));
    } else if (o.kind == 3) {
      c.drawCircle(center, 18, Paint()..color = Colors.amberAccent.withOpacity(.95));
      c.drawCircle(center, 10, Paint()..color = Colors.orangeAccent.withOpacity(.90));
    } else if (o.kind == 2) {
      c.drawCircle(center.translate(-12, 0), 18, Paint()..color = Colors.white.withOpacity(.46));
      c.drawCircle(center.translate(8, -6), 22, Paint()..color = Colors.white.withOpacity(.50));
      c.drawCircle(center.translate(22, 4), 15, Paint()..color = Colors.white.withOpacity(.44));
    } else {
      drawEnemy(c, center, 46);
    }
  }

  void drawEnemy(Canvas c, Offset o, double w) {
    c.drawPath(Path()..moveTo(o.dx, o.dy - w * .45)..lineTo(o.dx - w * .18, o.dy + w * .30)..lineTo(o.dx + w * .18, o.dy + w * .30)..close(), Paint()..color = const Color(0xff94a3b8));
    c.drawPath(Path()..moveTo(o.dx - w * .16, o.dy)..lineTo(o.dx - w * .60, o.dy + w * .22)..lineTo(o.dx - w * .10, o.dy + w * .24)..close(), Paint()..color = const Color(0xff334155));
    c.drawPath(Path()..moveTo(o.dx + w * .16, o.dy)..lineTo(o.dx + w * .60, o.dy + w * .22)..lineTo(o.dx + w * .10, o.dy + w * .24)..close(), Paint()..color = const Color(0xff334155));
    c.drawCircle(o.translate(0, -w * .24), 5, Paint()..color = Colors.redAccent);
  }

  void drawBullet(Canvas c, Size s, PlaneBullet b) {
    final o = Offset(b.x * s.width, b.y * s.height);
    c.drawCircle(o, 4, Paint()..color = const Color(0xfffff176));
    c.drawCircle(o, 10, Paint()..color = const Color(0xfffff176).withOpacity(.13));
  }

  void drawPlane(Canvas c, Offset o, double w) {
    c.drawOval(Rect.fromCenter(center: o.translate(0, w * .32), width: w * 1.2, height: w * .38), Paint()..color = Colors.black.withOpacity(.26));
    c.drawPath(Path()..moveTo(o.dx, o.dy - w * .62)..lineTo(o.dx - w * .18, o.dy + w * .45)..lineTo(o.dx + w * .18, o.dy + w * .45)..close(), Paint()..color = const Color(0xff38bdf8));
    c.drawPath(Path()..moveTo(o.dx - w * .14, o.dy - w * .02)..lineTo(o.dx - w * .80, o.dy + w * .24)..lineTo(o.dx - w * .10, o.dy + w * .30)..close(), Paint()..color = const Color(0xff2563eb));
    c.drawPath(Path()..moveTo(o.dx + w * .14, o.dy - w * .02)..lineTo(o.dx + w * .80, o.dy + w * .24)..lineTo(o.dx + w * .10, o.dy + w * .30)..close(), Paint()..color = const Color(0xff2563eb));
    c.drawCircle(o.translate(0, -w * .40), w * .105, Paint()..color = const Color(0xffe0f2fe));
    c.drawPath(Path()..moveTo(o.dx, o.dy + w * .26)..lineTo(o.dx - w * .32, o.dy + w * .55)..lineTo(o.dx - w * .08, o.dy + w * .45)..close(), Paint()..color = const Color(0xff1d4ed8));
    c.drawPath(Path()..moveTo(o.dx, o.dy + w * .26)..lineTo(o.dx + w * .32, o.dy + w * .55)..lineTo(o.dx + w * .08, o.dy + w * .45)..close(), Paint()..color = const Color(0xff1d4ed8));
    c.drawPath(Path()..moveTo(o.dx, o.dy - w * .62)..lineTo(o.dx - w * .18, o.dy + w * .45)..lineTo(o.dx + w * .18, o.dy + w * .45)..close(), Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.white.withOpacity(.45));
  }

  void drawCrash(Canvas c, Size s) {
    final op = (crashFlash / 16).clamp(0.0, 1.0).toDouble();
    c.drawRect(Offset.zero & s, Paint()..color = Colors.redAccent.withOpacity(.16 * op));
    final center = Offset(x * s.width, y * s.height);
    final spark = Paint()..color = Colors.orangeAccent.withOpacity(op)..strokeWidth = 2;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      c.drawLine(center, Offset(center.dx + math.cos(a) * (36 + 16 * op), center.dy + math.sin(a) * (26 + 14 * op)), spark);
    }
  }

  void drawScan(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..style = PaintingStyle.stroke..strokeWidth = 14..color = Colors.black.withOpacity(.18));
    final scan = Paint()..color = Colors.black.withOpacity(.035);
    for (double yy = 0; yy < s.height; yy += 5) c.drawRect(Rect.fromLTWH(0, yy, s.width, 1), scan);
  }

  @override
  bool shouldRepaint(covariant PlanePainter oldDelegate) => true;
}

class RoadCar {
  RoadCar({required this.lane, required this.depth, required this.color, required this.speed});
  int lane;
  double depth;
  Color color;
  double speed;
}

class RoadGame extends StatefulWidget {
  const RoadGame({super.key});
  @override
  State<RoadGame> createState() => _RoadGameState();
}

class _RoadGameState extends State<RoadGame> {
  final rnd = math.Random();
  Timer? timer;
  int lane = 2;
  int score = 0;
  int passed = 0;
  int target = 40;
  int day = 1;
  int tick = 0;
  int lives = 3;
  int distance = 0;
  int crashFlash = 0;
  double throttle = .55;
  double gx = 0;
  double gy = 0;
  bool running = false;
  bool stopped = false;
  bool gameOver = false;
  final cars = <RoadCar>[];
  final colors = const [Color(0xffef4444), Color(0xffffd166), Color(0xff22c55e), Color(0xffa78bfa), Color(0xfff97316)];
  String get weather {
    final p = (passed % target) / target;
    if (p < .18) return 'نهار';
    if (p < .34) return 'غروب';
    if (p < .52) return 'ليل';
    if (p < .68) return 'ضباب';
    if (p < .84) return 'ثلج';
    return 'مطر';
  }
  int get speedKmh => (60 + throttle * 180).round();
  double get speedFactor => .68 + throttle * .84;

  void start() {
    timer?.cancel();
    lane = 2;
    score = 0;
    passed = 0;
    target = 40;
    day = 1;
    tick = 0;
    lives = 3;
    distance = 0;
    crashFlash = 0;
    throttle = .55;
    cars.clear();
    running = true;
    stopped = false;
    gameOver = false;
    Sfx.start();
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) => step());
    setState(() {});
  }

  void resume() {
    stopped = false;
    running = true;
    crashFlash = 0;
    Sfx.start();
    setState(() {});
  }

  void step() {
    if (crashFlash > 0) crashFlash--;
    if (!running) {
      if (mounted) setState(() {});
      return;
    }
    tick++;
    distance++;
    Sfx.engine(tick, throttle);
    if (tick % 12 == 0) score += (1 + throttle * 2).round();
    final base = math.min(.0145, .0049 + day * .00058 + distance / 250000).toDouble();
    final speed = base * speedFactor;
    final spawn = (.010 + day * .0011 + throttle * .006).clamp(.010, .031).toDouble();
    if (rnd.nextDouble() < spawn && cars.length < 6) {
      final l = rnd.nextInt(5);
      if (!cars.any((c) => c.lane == l && c.depth < .25)) cars.add(RoadCar(lane: l, depth: .04, color: colors[rnd.nextInt(colors.length)], speed: .80 + rnd.nextDouble() * .30));
    }
    for (final c in cars) c.depth += speed * c.speed;
    final done = cars.where((c) => c.depth > 1.08).length;
    if (done > 0) {
      passed += done;
      score += done * (90 + (throttle * 40).round());
      cars.removeWhere((c) => c.depth > 1.08);
      Sfx.pass();
    }
    if (passed >= target) {
      day++;
      passed = 0;
      target = math.min(90, target + 12).toInt();
      cars.clear();
      score += 800;
      Sfx.stage();
    }
    for (final c in List<RoadCar>.from(cars)) {
      if (c.depth > .78 && c.depth < .96 && c.lane == lane) {
        cars.remove(c);
        running = false;
        crashFlash = 16;
        if (lives > 1) {
          lives--;
          stopped = true;
          throttle = math.max(.35, throttle - .20).toDouble();
          Sfx.crash();
        } else {
          lives = 0;
          gameOver = true;
          stopped = false;
          Sfx.crashThenOver();
        }
        break;
      }
    }
    if (mounted) setState(() {});
  }

  void changeThrottle(double delta) {
    if (!running) return;
    final old = throttle;
    throttle = (throttle + delta).clamp(.20, 1.0).toDouble();
    if ((old - throttle).abs() > .025) Sfx.speedTap(tick, throttle);
    setState(() {});
  }

  void onPanStart(DragStartDetails d) {
    gx = 0;
    gy = 0;
  }

  void onPanUpdate(DragUpdateDetails d) {
    if (!running) return;
    gx += d.delta.dx;
    gy += d.delta.dy;
    final ax = gx.abs();
    final ay = gy.abs();
    if (ax > ay && ax > 26) {
      if (gx > 0) {
        right();
      } else {
        left();
      }
      gx = 0;
      gy = 0;
      return;
    }
    if (ay > ax && ay > 18) {
      changeThrottle(gy < 0 ? .06 : -.06);
      gx = 0;
      gy = 0;
    }
  }

  void onPanEnd(DragEndDetails d) {
    gx = 0;
    gy = 0;
  }

  void left() {
    if (!running) return;
    final old = lane;
    lane = math.max(0, lane - 1);
    if (old != lane) Sfx.steer();
    setState(() {});
  }

  void right() {
    if (!running) return;
    final old = lane;
    lane = math.min(4, lane + 1);
    if (old != lane) Sfx.steer();
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = !running || stopped || gameOver;
    return Scaffold(
      appBar: AppBar(title: const Text('طريق التحمل V5.1')),
      body: SafeArea(child: Column(children: [
        RoadHud(score: score, speed: speedKmh, lives: lives, weather: weather, passed: passed, target: target),
        Expanded(child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.lightBlueAccent.withOpacity(.22)), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(.10), blurRadius: 28)]),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: onPanStart,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            child: Stack(children: [
              CustomPaint(painter: RoadPainter(playerLane: lane, cars: cars, weather: weather, tick: tick, throttle: throttle, crashFlash: crashFlash), child: const SizedBox.expand()),
              Positioned(right: 10, bottom: 12, child: SpeedPad(throttle: throttle, speed: speedKmh, onUp: () => changeThrottle(.08), onDown: () => changeThrottle(-.08))),
              const Positioned(left: 10, bottom: 12, child: HintBox(text: '← → تغيير المسار\n↑ تسارع\n↓ تهدئة')),
              if (overlay && gameOver) Center(child: EndCard(title: 'GAME OVER', score: score, extra: 'اليوم: $day', plane: false, onTap: start)),
              if (overlay && !gameOver) Center(child: OverlayCard(title: stopped ? 'اصطدام!' : 'طريق التحمل', subtitle: stopped ? 'تبقى لديك $lives أرواح — تابع' : 'اسحب يمين/يسار للمسار، وأعلى/أسفل للسرعة', button: stopped ? 'تابع' : 'ابدأ', danger: stopped, onTap: stopped ? resume : start)),
            ]),
          ),
        )),
      ])),
    );
  }
}

class RoadHud extends StatelessWidget {
  const RoadHud({super.key, required this.score, required this.speed, required this.lives, required this.weather, required this.passed, required this.target});
  final int score;
  final int speed;
  final int lives;
  final String weather;
  final int passed;
  final int target;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(children: [
          Row(children: [Expanded(child: InfoChip(label: 'النقاط', value: '$score')), const SizedBox(width: 6), Expanded(child: InfoChip(label: 'السرعة', value: '$speed')), const SizedBox(width: 6), Expanded(child: InfoChip(label: 'الأرواح', value: '$lives')), const SizedBox(width: 6), Expanded(child: InfoChip(label: 'الجو', value: weather))]),
          const SizedBox(height: 7),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (passed / target).clamp(0, 1).toDouble(), minHeight: 8, backgroundColor: Colors.white12, color: Colors.cyanAccent)),
        ]),
      );
}

class RoadPainter extends CustomPainter {
  RoadPainter({required this.playerLane, required this.cars, required this.weather, required this.tick, required this.throttle, required this.crashFlash});
  final int playerLane;
  final int tick;
  final int crashFlash;
  final List<RoadCar> cars;
  final String weather;
  final double throttle;

  double ease(double d) => math.pow(d.clamp(0, 1), 1.13).toDouble();
  double yOf(Size s, double d) => s.height * (.38 + .63 * ease(d));
  double roadW(Size s, double d) => s.width * (.13 + .92 * ease(d));
  double laneX(Size s, int lane, double d) {
    final rw = roadW(s, d);
    final left = s.width * .5 - rw / 2;
    return left + rw * ((lane + .5) / 5);
  }

  @override
  void paint(Canvas c, Size s) {
    sky(c, s);
    road(c, s);
    details(c, s);
    for (final car in List<RoadCar>.from(cars)..sort((a, b) => a.depth.compareTo(b.depth))) drawOpponent(c, s, car);
    drawCar(c, Offset(laneX(s, playerLane, .88), s.height * .84), s.width * .145, const Color(0xff38bdf8), 1);
    speedFx(c, s);
    if (crashFlash > 0) crashFx(c, s);
    scan(c, s);
  }

  void sky(Canvas c, Size s) {
    final colors = weather == 'ليل'
        ? const [Color(0xff01030d), Color(0xff081021), Color(0xff111827)]
        : weather == 'ضباب'
            ? const [Color(0xff64748b), Color(0xff94a3b8), Color(0xffdbeafe)]
            : weather == 'مطر'
                ? const [Color(0xff030712), Color(0xff1f2937), Color(0xff475569)]
                : weather == 'ثلج'
                    ? const [Color(0xff93c5fd), Color(0xffdbeafe), Color(0xffffffff)]
                    : weather == 'غروب'
                        ? const [Color(0xff22063f), Color(0xff9f1239), Color(0xfffb923c)]
                        : const [Color(0xff0284c7), Color(0xff67e8f9), Color(0xff86efac)];
    c.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(Offset.zero & s));
    c.drawRect(Rect.fromLTWH(0, s.height * .40, s.width, s.height * .60), Paint()..color = weather == 'ثلج' ? const Color(0xffeef2ff) : weather == 'ليل' ? const Color(0xff052e16) : const Color(0xff16a34a));
  }

  void road(Canvas c, Size s) {
    final top = s.height * .38;
    final path = Path()..moveTo(s.width * .462, top)..lineTo(s.width * .538, top)..lineTo(s.width * 1.02, s.height)..lineTo(-s.width * .02, s.height)..close();
    c.drawPath(path, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff52525b), Color(0xff27272a), Color(0xff09090b)]).createShader(Rect.fromLTWH(0, top, s.width, s.height - top)));
    c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = Colors.white.withOpacity(weather == 'ليل' ? .18 : .40));
  }

  void details(Canvas c, Size s) {
    for (var i = 0; i < 20; i++) {
      final d = (((i * 58 + tick * (5 + throttle * 5).round()) % 820) / 820).clamp(.025, .99).toDouble();
      final y = yOf(s, d);
      final rw = roadW(s, d);
      final left = s.width * .5 - rw / 2;
      final right = s.width * .5 + rw / 2;
      final stripe = Paint()..color = (i.isEven ? Colors.white : Colors.redAccent).withOpacity(.65);
      final size = 6 + d * 22;
      c.drawRect(Rect.fromCenter(center: Offset(left - 5 * d, y), width: size, height: 4 + d * 9), stripe);
      c.drawRect(Rect.fromCenter(center: Offset(right + 5 * d, y), width: size, height: 4 + d * 9), stripe);
      if (i % 2 == 0) c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * .5, y), width: 2 + d * 8, height: 12 + d * 48), const Radius.circular(4)), Paint()..color = Colors.white.withOpacity(.55));
    }
  }

  void drawOpponent(Canvas c, Size s, RoadCar car) {
    final x = laneX(s, car.lane, car.depth);
    final y = yOf(s, car.depth);
    final scale = .32 + car.depth * 1.35;
    drawCar(c, Offset(x, y), s.width * .082 * scale, car.color, 1);
  }

  void drawCar(Canvas c, Offset o, double w, Color body, double opacity) {
    final h = w * .66;
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, h * .22), width: w * 1.22, height: h * .62), Radius.circular(w * .35)), Paint()..color = Colors.black.withOpacity(.36 * opacity));
    final path = Path()..moveTo(o.dx - w * .56, o.dy + h * .12)..quadraticBezierTo(o.dx - w * .50, o.dy - h * .22, o.dx - w * .28, o.dy - h * .40)..quadraticBezierTo(o.dx, o.dy - h * .60, o.dx + w * .28, o.dy - h * .40)..quadraticBezierTo(o.dx + w * .50, o.dy - h * .22, o.dx + w * .56, o.dy + h * .12)..lineTo(o.dx + w * .45, o.dy + h * .34)..quadraticBezierTo(o.dx, o.dy + h * .50, o.dx - w * .45, o.dy + h * .34)..close();
    c.drawPath(path, Paint()..color = body.withOpacity(opacity));
    c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(1.1, w * .038)..color = Colors.white.withOpacity(.50));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, -h * .01), width: w * .34, height: h * .30), Radius.circular(w * .10)), Paint()..color = const Color(0xffdbeafe).withOpacity(.92));
  }

  void speedFx(Canvas c, Size s) {
    if (throttle < .58) return;
    final p = Paint()..color = Colors.cyanAccent.withOpacity((throttle - .55) * .18)..strokeWidth = 1.5 + throttle * 2;
    for (var i = 0; i < 10; i++) {
      final x = (i * 43 + tick * 9) % s.width;
      final y = s.height * (.48 + (i % 5) * .11);
      c.drawLine(Offset(x.toDouble(), y), Offset(x.toDouble() - 18 - throttle * 24, y + 18 + throttle * 18), p);
    }
  }

  void crashFx(Canvas c, Size s) {
    final op = (crashFlash / 16).clamp(0.0, 1.0).toDouble();
    c.drawRect(Offset.zero & s, Paint()..color = Colors.redAccent.withOpacity(.18 * op));
  }

  void scan(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..style = PaintingStyle.stroke..strokeWidth = 14..color = Colors.black.withOpacity(.20));
    final scan = Paint()..color = Colors.black.withOpacity(.040);
    for (double y = 0; y < s.height; y += 5) c.drawRect(Rect.fromLTWH(0, y, s.width, 1), scan);
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) => true;
}
