import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() => runApp(const RetroApp());

class RetroApp extends StatelessWidget {
  const RetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألعاب زمان V4.9',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xff040816),
        appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Color(0xff07111f)),
      ),
      home: const Directionality(textDirection: TextDirection.rtl, child: Home()),
    );
  }
}

class Sfx {
  static final AudioPlayer _p = AudioPlayer();
  static int _lastEngineTick = 0;
  static int _lastSpeedSoundTick = 0;
  static int _lastShotTick = 0;

  static Future<void> play(String path, double volume) async {
    try {
      await _p.stop();
      await _p.play(AssetSource(path), volume: volume);
    } catch (_) {}
  }

  static void start() => play('sounds/shared/game_start.wav', .55);
  static void gameOver() => play('sounds/shared/game_over.wav', .75);
  static void carCrash() => play('sounds/fuel_plane/plane_explosion.wav', .82);
  static void planeCrash() => play('sounds/fuel_plane/plane_explosion.wav', .78);
  static void fuel() => play('sounds/fuel_plane/fuel_pickup.wav', .62);
  static void shot(int tick) {
    if (tick - _lastShotTick > 8) {
      _lastShotTick = tick;
      play('sounds/fuel_plane/plane_shoot.wav', .28);
    }
  }
  static void pass() => play('sounds/retro_road/car_pass.wav', .38);
  static void steer() => play('sounds/retro_road/car_pass.wav', .22);
  static void stage() => play('sounds/retro_road/stage_clear.wav', .55);

  static void crashThenGameOver({bool plane = false}) {
    if (plane) {
      planeCrash();
    } else {
      carCrash();
    }
    Future.delayed(const Duration(milliseconds: 520), () => gameOver());
  }

  static void engine(int tick, double throttle) {
    final gap = (34 - throttle * 18).round().clamp(14, 34);
    if (tick - _lastEngineTick >= gap) {
      _lastEngineTick = tick;
      play('sounds/retro_road/car_pass.wav', .10 + throttle * .14);
    }
  }

  static void speedTap(int tick, double throttle) {
    if (tick - _lastSpeedSoundTick > 7) {
      _lastSpeedSoundTick = tick;
      play('sounds/retro_road/car_pass.wav', .22 + throttle * .18);
    }
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff020617), Color(0xff0b1028), Color(0xff082f49)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 18),
              const Text('ألعاب زمان V4.9', textAlign: TextAlign.center, style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: .5)),
              const SizedBox(height: 8),
              const Text('السيارات + طائرة الوقود بنظام أرواح وتحكم بالسحب ومؤثرات صوتية', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 28),
              _Tile(
                title: 'طريق التحمل',
                icon: '🏎️',
                text: 'تحكم بالسحب، سرعة، اصطدام، شاشة نهاية، وطقس.',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: RoadGame()))),
              ),
              const SizedBox(height: 16),
              _Tile(
                title: 'طائرة الوقود',
                icon: '✈️',
                text: 'تحكم بالسحب مثل السيارات، وقود، أرواح، أعداء، طلقات، ومؤثرات.',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: PlaneGame()))),
              ),
              const Spacer(),
              const Text('تصميم أصلي مستوحى من ألعاب التحمل القديمة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.icon, required this.text, required this.onTap});
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
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.08),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.lightBlueAccent.withOpacity(.18)),
            boxShadow: [BoxShadow(color: Colors.lightBlueAccent.withOpacity(.10), blurRadius: 28, spreadRadius: 1)],
          ),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 42)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(text, style: const TextStyle(color: Colors.white70)),
            ])),
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
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      );
}

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.title, required this.subtitle, required this.onTap, this.buttonText = 'ابدأ', this.danger = false});
  final String title, subtitle, buttonText;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(22),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.78),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: (danger ? Colors.redAccent : Colors.cyanAccent).withOpacity(.28)),
          boxShadow: [BoxShadow(color: (danger ? Colors.redAccent : Colors.cyanAccent).withOpacity(.16), blurRadius: 34)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(danger ? Icons.warning_amber_rounded : Icons.play_circle_fill, size: 52, color: danger ? Colors.redAccent : Colors.cyanAccent),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          RetroButton(text: buttonText, icon: Icons.play_arrow, onTap: onTap),
        ]),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white.withOpacity(.10), Colors.white.withOpacity(.035)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyanAccent.withOpacity(.16)),
        ),
        child: Column(children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        ]),
      );
}

class GameOverCard extends StatelessWidget {
  const GameOverCard({super.key, required this.title, required this.score, required this.extra, required this.onTap, this.plane = false});
  final String title, extra;
  final int score;
  final VoidCallback onTap;
  final bool plane;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xdd1f0202), Color(0xee050505)]),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.redAccent.withOpacity(.42), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(.20), blurRadius: 40)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 122, child: CustomPaint(painter: EndScenePainter(plane: plane), child: const SizedBox.expand())),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.redAccent, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text('النقاط: $score   |   $extra', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          RetroButton(text: 'إعادة اللعب', icon: Icons.replay, onTap: onTap),
        ]),
      );
}

class EndScenePainter extends CustomPainter {
  EndScenePainter({required this.plane});
  final bool plane;
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .60);
    c.drawOval(Rect.fromCenter(center: center.translate(0, 16), width: s.width * .66, height: 20), Paint()..color = Colors.black.withOpacity(.55));
    c.drawCircle(Offset(s.width * .50, s.height * .50), 54, Paint()..color = Colors.redAccent.withOpacity(.18)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    if (plane) {
      final body = Path()
        ..moveTo(center.dx, center.dy - 48)
        ..lineTo(center.dx - 18, center.dy + 32)
        ..lineTo(center.dx + 18, center.dy + 32)
        ..close();
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(-0.35);
      c.translate(-center.dx, -center.dy);
      c.drawPath(body, Paint()..color = const Color(0xff38bdf8));
      c.drawPath(Path()..moveTo(center.dx - 14, center.dy - 4)..lineTo(center.dx - 70, center.dy + 14)..lineTo(center.dx - 10, center.dy + 20)..close(), Paint()..color = const Color(0xff2563eb));
      c.drawPath(Path()..moveTo(center.dx + 14, center.dy - 4)..lineTo(center.dx + 70, center.dy + 14)..lineTo(center.dx + 10, center.dy + 20)..close(), Paint()..color = const Color(0xff2563eb));
      c.drawPath(body, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.white.withOpacity(.50));
      c.drawLine(center.translate(-10, -28), center.translate(10, 18), Paint()..color = Colors.black.withOpacity(.55)..strokeWidth = 3);
      c.restore();
    } else {
      final body = Path()
        ..moveTo(center.dx - 70, center.dy + 2)
        ..lineTo(center.dx - 48, center.dy - 25)
        ..lineTo(center.dx - 12, center.dy - 35)
        ..lineTo(center.dx + 42, center.dy - 20)
        ..lineTo(center.dx + 72, center.dy + 5)
        ..lineTo(center.dx + 50, center.dy + 28)
        ..lineTo(center.dx - 58, center.dy + 25)
        ..close();
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(-0.13);
      c.translate(-center.dx, -center.dy);
      c.drawPath(body, Paint()..color = const Color(0xffef4444));
      c.drawPath(body, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.white.withOpacity(.45));
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(-4, -13), width: 42, height: 22), const Radius.circular(8)), Paint()..color = const Color(0xffdbeafe));
      c.drawCircle(center.translate(-48, 25), 13, Paint()..color = const Color(0xff020617));
      c.drawCircle(center.translate(45, 25), 13, Paint()..color = const Color(0xff020617));
      c.restore();
    }
    final spark = Paint()..color = Colors.orangeAccent.withOpacity(.90)..strokeWidth = 2;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final o = Offset(center.dx + math.cos(a) * 42, center.dy - 18 + math.sin(a) * 24);
      c.drawLine(o, Offset(o.dx + math.cos(a) * 15, o.dy + math.sin(a) * 15), spark);
    }
    c.drawCircle(center.translate(58, -18), 10, Paint()..color = Colors.yellowAccent.withOpacity(.80));
  }
  @override
  bool shouldRepaint(covariant EndScenePainter oldDelegate) => false;
}

// ------------------------ Plane Game ------------------------

class PlaneObj {
  PlaneObj({required this.x, required this.y, required this.kind, required this.speed});
  double x, y, speed;
  int kind; // 0 fuel, 1 enemy, 2 cloud, 3 coin
}

class PlaneBullet {
  PlaneBullet(this.x, this.y);
  double x, y;
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
  double _dx = 0;
  double _dy = 0;
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
    level = 1 + distance ~/ 1400;
    Sfx.engine(tick, throttle);
    fuel -= .028 + throttle * .028;
    if (tick % 9 == 0) {
      bullets.add(PlaneBullet(x - .022, y - .065));
      bullets.add(PlaneBullet(x + .022, y - .065));
      Sfx.shot(tick);
    }
    final spawn = (.018 + level * .0015 + throttle * .010).clamp(.018, .050).toDouble();
    if (rnd.nextDouble() < spawn) {
      final r = rnd.nextDouble();
      final kind = r < .22 ? 0 : r < .68 ? 1 : r < .86 ? 2 : 3;
      objects.add(PlaneObj(x: .10 + rnd.nextDouble() * .80, y: -.08, kind: kind, speed: .0045 + rnd.nextDouble() * .003 + throttle * .004));
    }
    for (final b in bullets) b.y -= .035 + throttle * .010;
    bullets.removeWhere((b) => b.y < -.08);
    for (final o in objects) o.y += o.speed;
    objects.removeWhere((o) => o.y > 1.12);

    final deadObjects = <PlaneObj>[];
    final deadBullets = <PlaneBullet>[];
    for (final b in bullets) {
      for (final o in objects) {
        if (o.kind == 1 && (b.x - o.x).abs() < .045 && (b.y - o.y).abs() < .055) {
          deadObjects.add(o);
          deadBullets.add(b);
          score += 70;
          Sfx.planeCrash();
          break;
        }
      }
    }
    objects.removeWhere(deadObjects.contains);
    bullets.removeWhere(deadBullets.contains);

    for (final o in List<PlaneObj>.from(objects)) {
      if ((x - o.x).abs() < .060 && (y - o.y).abs() < .070) {
        if (o.kind == 0) {
          fuel = math.min(100, fuel + 24).toDouble();
          score += 130;
          objects.remove(o);
          Sfx.fuel();
        } else if (o.kind == 3) {
          score += 180;
          objects.remove(o);
          Sfx.stage();
        } else if (o.kind == 1 || o.kind == 2) {
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
      fuel = math.max(25, fuel).toDouble();
      Sfx.planeCrash();
    } else {
      lives = 0;
      stopped = false;
      gameOver = true;
      Sfx.crashThenGameOver(plane: true);
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
    _dx = 0;
    _dy = 0;
  }

  void onPanUpdate(DragUpdateDetails d) {
    if (!running) return;
    _dx += d.delta.dx;
    _dy += d.delta.dy;
    x = (x + d.delta.dx / 260).clamp(.08, .92).toDouble();
    y = (y + d.delta.dy / 420).clamp(.22, .88).toDouble();
    if (_dy.abs() > 18 && _dy.abs() > _dx.abs()) {
      changeThrottle(_dy < 0 ? .05 : -.05);
      _dx = 0;
      _dy = 0;
    }
    setState(() {});
  }

  void onPanEnd(DragEndDetails d) {
    _dx = 0;
    _dy = 0;
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
      appBar: AppBar(title: const Text('طائرة الوقود V4.9')),
      body: SafeArea(child: Column(children: [
        _PlaneHud(score: score, fuel: fuel, lives: lives, level: level, speed: speed),
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
              Positioned(right: 12, bottom: 14, child: _ThrottlePad(throttle: throttle, speed: speed, onUp: () => changeThrottle(.08), onDown: () => changeThrottle(-.08))),
              Positioned(left: 12, bottom: 14, child: _PlaneHintBox()),
              if (overlay && gameOver) Center(child: GameOverCard(title: 'PLANE DOWN', score: score, extra: 'مرحلة: $level', plane: true, onTap: start)),
              if (overlay && !gameOver) Center(child: GameCard(title: stopped ? 'ضربة!' : 'طائرة الوقود', subtitle: stopped ? 'تبقى لديك $lives أرواح — تابع من نفس الجولة' : 'اسحب للتحرك، أعلى/أسفل للسرعة، اجمع الوقود وتجنب الخطر', buttonText: stopped ? 'تابع' : 'ابدأ', danger: stopped, onTap: stopped ? resume : start)),
            ]),
          ),
        )),
      ])),
    );
  }
}

class _PlaneHud extends StatelessWidget {
  const _PlaneHud({required this.score, required this.fuel, required this.lives, required this.level, required this.speed});
  final int score, lives, level, speed;
  final double fuel;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
    child: Column(children: [
      Row(children: [
        Expanded(child: _Chip(label: 'النقاط', value: '$score')),
        const SizedBox(width: 6),
        Expanded(child: _Chip(label: 'الوقود', value: '${fuel.clamp(0, 100).round()}%')),
        const SizedBox(width: 6),
        Expanded(child: _Chip(label: 'الأرواح', value: '$lives')),
        const SizedBox(width: 6),
        Expanded(child: _Chip(label: 'السرعة', value: '$speed')),
      ]),
      const SizedBox(height: 7),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: fuel.clamp(0, 100).toDouble() / 100, minHeight: 8, backgroundColor: Colors.white12, color: fuel > 35 ? Colors.cyanAccent : Colors.orangeAccent)),
    ]),
  );
}

class _PlaneHintBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: Colors.black.withOpacity(.34), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
    child: const Text('اسحب لتحريك الطائرة\n↑ تسارع  ↓ تهدئة\nاجمع الوقود', style: TextStyle(fontSize: 11, color: Colors.white70)),
  );
}

class PlanePainter extends CustomPainter {
  PlanePainter({required this.x, required this.y, required this.objects, required this.bullets, required this.tick, required this.throttle, required this.crashFlash});
  final double x, y, throttle;
  final List<PlaneObj> objects;
  final List<PlaneBullet> bullets;
  final int tick, crashFlash;

  @override
  void paint(Canvas c, Size s) {
    final bg = Offset.zero & s;
    c.drawRect(bg, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff020617), Color(0xff075985), Color(0xff0e7490)]).createShader(bg));
    drawWater(c, s);
    drawSpeedLines(c, s);
    for (final o in objects) drawObject(c, s, o);
    for (final b in bullets) drawBullet(c, s, b);
    drawPlane(c, Offset(x * s.width, y * s.height), s.width * .115);
    if (crashFlash > 0) drawCrash(c, s);
    drawScan(c, s);
  }

  void drawWater(Canvas c, Size s) {
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
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 34, height: 44), const Radius.circular(8)), Paint()..color = const Color(0xffffd166));
      c.drawRect(Rect.fromCenter(center: center.translate(0, 4), width: 12, height: 24), Paint()..color = const Color(0xffef4444));
      c.drawCircle(center.translate(0, -13), 5, Paint()..color = Colors.white.withOpacity(.80));
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
    final body = Path()
      ..moveTo(o.dx, o.dy - w * .45)
      ..lineTo(o.dx - w * .18, o.dy + w * .30)
      ..lineTo(o.dx + w * .18, o.dy + w * .30)
      ..close();
    c.drawPath(body, Paint()..color = const Color(0xff94a3b8));
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

// ------------------------ Road Game ------------------------

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
  int lane = 2, score = 0, passed = 0, target = 40, day = 1, tick = 0, lives = 3, distance = 0, crashFlash = 0;
  double throttle = .55, _gestureDx = 0, _gestureDy = 0;
  bool running = false, stopped = false, gameOver = false, justCrashed = false;
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
    lane = 2; score = 0; passed = 0; target = 40; day = 1; tick = 0; lives = 3; distance = 0; crashFlash = 0; throttle = .55;
    cars.clear(); running = true; stopped = false; gameOver = false; justCrashed = false; Sfx.start();
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) => step());
    setState(() {});
  }
  void resume() { if (!gameOver) { stopped = false; running = true; justCrashed = false; crashFlash = 0; Sfx.start(); setState(() {}); } }

  void step() {
    if (crashFlash > 0) crashFlash--;
    if (!running) { if (mounted) setState(() {}); return; }
    tick++; distance++; Sfx.engine(tick, throttle);
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
    if (done > 0) { passed += done; score += done * (90 + (throttle * 40).round()); cars.removeWhere((c) => c.depth > 1.08); Sfx.pass(); }
    if (passed >= target) { day++; passed = 0; target = math.min(90, target + 12).toInt(); cars.clear(); score += 800; Sfx.stage(); }
    for (final c in List<RoadCar>.from(cars)) {
      if (c.depth > .78 && c.depth < .96 && c.lane == lane) {
        cars.remove(c); running = false; justCrashed = true; crashFlash = 16;
        if (lives > 1) { lives--; stopped = true; throttle = math.max(.35, throttle - .20).toDouble(); Sfx.carCrash(); }
        else { lives = 0; gameOver = true; stopped = false; Sfx.crashThenGameOver(); }
        break;
      }
    }
    if (mounted) setState(() {});
  }

  void changeThrottle(double delta) { if (!running) return; final old = throttle; throttle = (throttle + delta).clamp(.20, 1.0).toDouble(); if ((old - throttle).abs() > .025) Sfx.speedTap(tick, throttle); setState(() {}); }
  void onPanStart(DragStartDetails d) { _gestureDx = 0; _gestureDy = 0; }
  void onPanUpdate(DragUpdateDetails d) {
    if (!running) return; _gestureDx += d.delta.dx; _gestureDy += d.delta.dy; final ax = _gestureDx.abs(); final ay = _gestureDy.abs();
    if (ax > ay && ax > 26) { if (_gestureDx > 0) right(); else left(); _gestureDx = 0; _gestureDy = 0; return; }
    if (ay > ax && ay > 18) { changeThrottle(_gestureDy < 0 ? .06 : -.06); _gestureDx = 0; _gestureDy = 0; }
  }
  void onPanEnd(DragEndDetails d) { _gestureDx = 0; _gestureDy = 0; }
  void left() { if (!running) return; final old = lane; lane = math.max(0, lane - 1); if (old != lane) Sfx.steer(); setState(() {}); }
  void right() { if (!running) return; final old = lane; lane = math.min(4, lane + 1); if (old != lane) Sfx.steer(); setState(() {}); }
  @override void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final overlay = !running || stopped || gameOver;
    return Scaffold(
      appBar: AppBar(title: const Text('طريق التحمل V4.9')),
      body: SafeArea(child: Column(children: [
        _RoadHud(score: score, speed: speedKmh, lives: lives, weather: weather, passed: passed, target: target),
        Expanded(child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 12), clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.lightBlueAccent.withOpacity(.22)), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(.10), blurRadius: 28)]),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, onPanStart: onPanStart, onPanUpdate: onPanUpdate, onPanEnd: onPanEnd,
            child: Stack(children: [
              CustomPaint(painter: RoadPainter(playerLane: lane, cars: cars, weather: weather, tick: tick, throttle: throttle, crashFlash: crashFlash), child: const SizedBox.expand()),
              Positioned(right: 12, bottom: 14, child: _ThrottlePad(throttle: throttle, speed: speedKmh, onUp: () => changeThrottle(.08), onDown: () => changeThrottle(-.08))),
              Positioned(left: 12, bottom: 14, child: _HintBox()),
              if (overlay && gameOver) Center(child: GameOverCard(title: 'GAME OVER', score: score, extra: 'اليوم: $day   |   تجاوزت: $passed', onTap: start)),
              if (overlay && !gameOver) Center(child: GameCard(title: stopped ? 'اصطدام!' : 'طريق التحمل', subtitle: stopped ? 'تبقى لديك $lives أرواح — تابع من نفس الجولة' : 'اسحب يمين/يسار للمسار، وأعلى/أسفل للسرعة', buttonText: stopped ? 'تابع' : 'ابدأ', danger: stopped, onTap: stopped ? resume : start)),
            ]),
          ),
        )),
      ])),
    );
  }
}

class _RoadHud extends StatelessWidget {
  const _RoadHud({required this.score, required this.speed, required this.lives, required this.weather, required this.passed, required this.target});
  final int score, speed, lives, passed, target;
  final String weather;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
    child: Column(children: [
      Row(children: [Expanded(child: _Chip(label: 'النقاط', value: '$score')), const SizedBox(width: 6), Expanded(child: _Chip(label: 'السرعة', value: '$speed')), const SizedBox(width: 6), Expanded(child: _Chip(label: 'الأرواح', value: '$lives')), const SizedBox(width: 6), Expanded(child: _Chip(label: 'الجو', value: weather))]),
      const SizedBox(height: 7),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (passed / target).clamp(0, 1).toDouble(), minHeight: 8, backgroundColor: Colors.white12, color: Colors.cyanAccent)),
    ]),
  );
}

class _ThrottlePad extends StatelessWidget {
  const _ThrottlePad({required this.throttle, required this.speed, required this.onUp, required this.onDown});
  final double throttle;
  final int speed;
  final VoidCallback onUp, onDown;
  @override
  Widget build(BuildContext context) => Container(width: 72, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(.42), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.cyanAccent.withOpacity(.25))), child: Column(mainAxisSize: MainAxisSize.min, children: [InkWell(onTap: onUp, child: const Icon(Icons.keyboard_arrow_up, size: 30, color: Colors.cyanAccent)), SizedBox(height: 78, child: RotatedBox(quarterTurns: 3, child: LinearProgressIndicator(value: throttle, minHeight: 9, backgroundColor: Colors.white12, color: Colors.cyanAccent))), Text('$speed', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)), InkWell(onTap: onDown, child: const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.orangeAccent))]));
}

class _HintBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: Colors.black.withOpacity(.34), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)), child: const Text('← → تغيير المسار\n↑ تسارع\n↓ تهدئة', style: TextStyle(fontSize: 11, color: Colors.white70)));
}

class RoadPainter extends CustomPainter {
  RoadPainter({required this.playerLane, required this.cars, required this.weather, required this.tick, required this.throttle, required this.crashFlash});
  final int playerLane, tick, crashFlash;
  final List<RoadCar> cars;
  final String weather;
  final double throttle;
  double ease(double d) => math.pow(d.clamp(0, 1), 1.13).toDouble();
  double yOf(Size s, double d) => s.height * (.38 + .63 * ease(d));
  double roadW(Size s, double d) => s.width * (.13 + .92 * ease(d));
  double laneX(Size s, int lane, double d) { final rw = roadW(s, d); final left = s.width * .5 - rw / 2; return left + rw * ((lane + .5) / 5); }
  double vis(double d) { if (weather == 'نهار') return 1; if (weather == 'غروب') return (1 - d * .16).clamp(.70, 1).toDouble(); if (weather == 'ليل') return (.12 + d * .88).clamp(.15, 1).toDouble(); if (weather == 'ضباب') return (.06 + d * .94).clamp(.08, 1).toDouble(); if (weather == 'مطر') return (.28 + d * .72).clamp(.28, 1).toDouble(); if (weather == 'ثلج') return (.35 + d * .65).clamp(.35, 1).toDouble(); return 1; }

  @override
  void paint(Canvas c, Size s) {
    drawSky(c, s); drawWorld(c, s); drawRoad(c, s); drawRoadDetails(c, s);
    final sorted = List<RoadCar>.from(cars)..sort((a, b) => a.depth.compareTo(b.depth));
    for (final car in sorted) drawOpponent(c, s, car);
    drawHeadlights(c, s); drawPlayer(c, s); drawSpeedFx(c, s); drawWeather(c, s); drawCrashFlash(c, s); drawPostFx(c, s);
  }

  void drawSky(Canvas c, Size s) {
    late final List<Color> colors;
    switch (weather) { case 'غروب': colors = const [Color(0xff22063f), Color(0xff9f1239), Color(0xfffb923c)]; break; case 'ليل': colors = const [Color(0xff01030d), Color(0xff081021), Color(0xff111827)]; break; case 'ضباب': colors = const [Color(0xff64748b), Color(0xff94a3b8), Color(0xffdbeafe)]; break; case 'ثلج': colors = const [Color(0xff93c5fd), Color(0xffdbeafe), Color(0xffffffff)]; break; case 'مطر': colors = const [Color(0xff030712), Color(0xff1f2937), Color(0xff475569)]; break; default: colors = const [Color(0xff0284c7), Color(0xff67e8f9), Color(0xff86efac)]; }
    c.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(Offset.zero & s));
    if (weather == 'ليل') c.drawCircle(Offset(s.width * .78, s.height * .13), 22, Paint()..color = Colors.white70); else { c.drawCircle(Offset(s.width * .76, s.height * .17), 34, Paint()..color = const Color(0xfffff3b0)); c.drawCircle(Offset(s.width * .76, s.height * .17), 58, Paint()..color = const Color(0xfffff3b0).withOpacity(.10)); }
  }
  void drawWorld(Canvas c, Size s) { final mountain = Path()..moveTo(0, s.height * .36)..lineTo(s.width * .15, s.height * .23)..lineTo(s.width * .34, s.height * .36)..lineTo(s.width * .54, s.height * .22)..lineTo(s.width * .76, s.height * .36)..lineTo(s.width, s.height * .25)..lineTo(s.width, s.height * .44)..lineTo(0, s.height * .44)..close(); c.drawPath(mountain, Paint()..color = weather == 'ليل' ? const Color(0xff050816) : const Color(0xff1e3a8a).withOpacity(weather == 'ضباب' ? .08 : .22)); final ground = weather == 'ثلج' ? const Color(0xffeef2ff) : weather == 'مطر' ? const Color(0xff0f3d23) : weather == 'ليل' ? const Color(0xff052e16) : const Color(0xff16a34a); c.drawRect(Rect.fromLTWH(0, s.height * .40, s.width, s.height * .60), Paint()..color = ground); }
  void drawRoad(Canvas c, Size s) { final top = s.height * .38; final road = Path()..moveTo(s.width * .462, top)..lineTo(s.width * .538, top)..lineTo(s.width * 1.02, s.height)..lineTo(-s.width * .02, s.height)..close(); final roadColors = weather == 'ثلج' ? const [Color(0xffa1a1aa), Color(0xff6b7280), Color(0xff374151)] : weather == 'مطر' ? const [Color(0xff1f2937), Color(0xff0f172a), Color(0xff020617)] : weather == 'ليل' ? const [Color(0xff111827), Color(0xff030712), Color(0xff000000)] : const [Color(0xff52525b), Color(0xff27272a), Color(0xff09090b)]; c.drawPath(road, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: roadColors).createShader(Rect.fromLTWH(0, top, s.width, s.height - top))); c.drawPath(road, Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = Colors.white.withOpacity(weather == 'ليل' ? .18 : .40)); }
  void drawRoadDetails(Canvas c, Size s) { for (var i = 0; i < 20; i++) { final d = (((i * 58 + tick * (5 + throttle * 5).round()) % 820) / 820).clamp(.025, .99).toDouble(); final y = yOf(s, d); final rw = roadW(s, d); final left = s.width * .5 - rw / 2; final right = s.width * .5 + rw / 2; final v = vis(d); final stripe = Paint()..color = (i.isEven ? Colors.white : Colors.redAccent).withOpacity(v * (weather == 'ليل' ? .42 : .82)); final size = 6 + d * 22; c.drawRect(Rect.fromCenter(center: Offset(left - 5 * d, y), width: size, height: 4 + d * 9), stripe); c.drawRect(Rect.fromCenter(center: Offset(right + 5 * d, y), width: size, height: 4 + d * 9), stripe); if (i % 2 == 0) { final lanePaint = Paint()..color = Colors.white.withOpacity(v * (weather == 'ليل' ? .36 : weather == 'ضباب' ? .28 : .70)); c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * .5, y), width: 2 + d * 8, height: 12 + d * 48), const Radius.circular(4)), lanePaint); } } }
  void drawOpponent(Canvas c, Size s, RoadCar car) { final v = vis(car.depth); if (v < .12) return; final x = laneX(s, car.lane, car.depth); final y = yOf(s, car.depth); final scale = .32 + car.depth * 1.35; if (weather == 'ليل' && car.depth < .55) { final p = Paint()..color = const Color(0xfffff176).withOpacity(v); final r = s.width * .026 * scale; c.drawCircle(Offset(x - r * 2.1, y), r, p); c.drawCircle(Offset(x + r * 2.1, y), r, p); return; } drawSuperCar(c, Offset(x, y), s.width * .082 * scale, Color.lerp(const Color(0xff111827), car.color, v) ?? car.color, true, v); }
  void drawHeadlights(Canvas c, Size s) { if (weather != 'ليل' && weather != 'ضباب' && weather != 'مطر') return; final x = laneX(s, playerLane, .88); final y = s.height * .84; final op = weather == 'ليل' ? .24 : weather == 'ضباب' ? .17 : .12; final cone = Path()..moveTo(x - 40, y - 12)..lineTo(s.width * .31, s.height * .40)..lineTo(s.width * .69, s.height * .40)..lineTo(x + 40, y - 12)..close(); c.drawPath(cone, Paint()..color = const Color(0xfffff3b0).withOpacity(op)); }
  void drawPlayer(Canvas c, Size s) { drawSuperCar(c, Offset(laneX(s, playerLane, .88), s.height * .84), s.width * .145, const Color(0xff38bdf8), false, 1); }
  void drawSpeedFx(Canvas c, Size s) { if (throttle < .58) return; final p = Paint()..color = Colors.cyanAccent.withOpacity((throttle - .55) * .18); for (var i = 0; i < 10; i++) { final x = (i * 43 + tick * 9) % s.width; final y = s.height * (.48 + (i % 5) * .11); c.drawLine(Offset(x.toDouble(), y), Offset(x.toDouble() - 18 - throttle * 24, y + 18 + throttle * 18), p..strokeWidth = 1.5 + throttle * 2); } }
  void drawCrashFlash(Canvas c, Size s) { if (crashFlash <= 0) return; final op = (crashFlash / 16).clamp(0.0, 1.0).toDouble(); c.drawRect(Offset.zero & s, Paint()..color = Colors.redAccent.withOpacity(.18 * op)); final center = Offset(laneX(s, playerLane, .88), s.height * .78); final spark = Paint()..color = Colors.orangeAccent.withOpacity(op)..strokeWidth = 2.2; for (var i = 0; i < 12; i++) { final a = i * math.pi / 6; final start = Offset(center.dx + math.cos(a) * 18, center.dy + math.sin(a) * 12); final end = Offset(center.dx + math.cos(a) * (36 + 18 * op), center.dy + math.sin(a) * (25 + 14 * op)); c.drawLine(start, end, spark); } }
  void drawSuperCar(Canvas c, Offset o, double w, Color body, bool opponent, double opacity) { final h = w * .66; c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, h * .22), width: w * 1.22, height: h * .62), Radius.circular(w * .35)), Paint()..color = Colors.black.withOpacity(.36 * opacity)); c.drawOval(Rect.fromCenter(center: o, width: w * 1.22, height: h * .95), Paint()..color = body.withOpacity(.10 * opacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)); final bodyPath = Path()..moveTo(o.dx - w * .56, o.dy + h * .12)..quadraticBezierTo(o.dx - w * .50, o.dy - h * .22, o.dx - w * .28, o.dy - h * .40)..quadraticBezierTo(o.dx - w * .10, o.dy - h * .54, o.dx, o.dy - h * .55)..quadraticBezierTo(o.dx + w * .10, o.dy - h * .54, o.dx + w * .28, o.dy - h * .40)..quadraticBezierTo(o.dx + w * .50, o.dy - h * .22, o.dx + w * .56, o.dy + h * .12)..lineTo(o.dx + w * .45, o.dy + h * .34)..quadraticBezierTo(o.dx, o.dy + h * .50, o.dx - w * .45, o.dy + h * .34)..close(); c.drawPath(bodyPath, Paint()..color = body.withOpacity(opacity)); c.drawPath(bodyPath, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(1.1, w * .038)..color = Colors.white.withOpacity(.50 * opacity)); final cabin = RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, -h * .01), width: w * .34, height: h * .30), Radius.circular(w * .10)); c.drawRRect(cabin, Paint()..color = const Color(0xffdbeafe).withOpacity(.92 * opacity)); final wheel = Paint()..color = const Color(0xff020617).withOpacity(opacity); c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w * .64, o.dy - h * .09, w * .18, h * .29), Radius.circular(w * .06)), wheel); c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx + w * .46, o.dy - h * .09, w * .18, h * .29), Radius.circular(w * .06)), wheel); c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w * .57, o.dy + h * .17, w * .19, h * .19), Radius.circular(w * .06)), wheel); c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx + w * .38, o.dy + h * .17, w * .19, h * .19), Radius.circular(w * .06)), wheel); final lamp = Paint()..color = (opponent ? const Color(0xfffff176) : const Color(0xffef4444)).withOpacity(opacity); c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w * .39, o.dy + h * .26, w * .25, h * .08), const Radius.circular(2)), lamp); c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx + w * .14, o.dy + h * .26, w * .25, h * .08), const Radius.circular(2)), lamp); }
  void drawWeather(Canvas c, Size s) { if (weather == 'ليل') c.drawRect(Offset.zero & s, Paint()..color = Colors.black.withOpacity(.30)); if (weather == 'ضباب') c.drawRect(Offset.zero & s, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xCCFFFFFF), Color(0x66FFFFFF), Color(0x18FFFFFF)]).createShader(Offset.zero & s)); if (weather == 'مطر') { c.drawRect(Offset.zero & s, Paint()..color = Colors.blueGrey.withOpacity(.13)); for (var i = 0; i < 86; i++) { final x = ((i * 61 + tick * 2) % s.width).toDouble(); final y = ((i * 47 + tick * 5) % s.height).toDouble(); c.drawLine(Offset(x, y), Offset(x - 6, y + 18), Paint()..color = const Color(0xff93c5fd).withOpacity(.62)..strokeWidth = 1.4); } } if (weather == 'ثلج') { c.drawRect(Offset.zero & s, Paint()..color = Colors.white.withOpacity(.10)); for (var i = 0; i < 74; i++) { final x = ((i * 67 + tick) % s.width).toDouble(); final y = ((i * 41 + tick * 2) % s.height).toDouble(); c.drawCircle(Offset(x, y), i.isEven ? 2.2 : 1.4, Paint()..color = Colors.white.withOpacity(.90)); } } if (weather == 'غروب') c.drawRect(Offset.zero & s, Paint()..color = const Color(0xffff7a18).withOpacity(.08)); }
  void drawPostFx(Canvas c, Size s) { c.drawRect(Offset.zero & s, Paint()..style = PaintingStyle.stroke..strokeWidth = 14..color = Colors.black.withOpacity(.20)); final scan = Paint()..color = Colors.black.withOpacity(.040); for (double y = 0; y < s.height; y += 5) c.drawRect(Rect.fromLTWH(0, y, s.width, 1), scan); }
  @override bool shouldRepaint(covariant RoadPainter oldDelegate) => true;
}
