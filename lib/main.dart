import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RetroV43App());
}

class RetroV43App extends StatelessWidget {
  const RetroV43App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألعاب زمان V4.3',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xff07111f),
        appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Color(0xff0b1220)),
      ),
      home: const Directionality(textDirection: TextDirection.rtl, child: HomeScreen()),
    );
  }
}

class Sfx {
  static final AudioPlayer _player = AudioPlayer();
  static int _lastShotTick = 0;

  static Future<void> play(String path, {double volume = 0.65}) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(path), volume: volume);
    } catch (_) {}
  }

  static void start() => play('sounds/shared/game_start.wav');
  static void over() => play('sounds/shared/game_over.wav');
  static void fuel() => play('sounds/fuel_plane/fuel_pickup.wav');
  static void boom() => play('sounds/fuel_plane/plane_explosion.wav');
  static void pass() => play('sounds/retro_road/car_pass.wav', volume: 0.42);
  static void steer() => play('sounds/retro_road/car_pass.wav', volume: 0.24);
  static void stage() => play('sounds/retro_road/stage_clear.wav');
  static void shot(int tick) {
    if (tick - _lastShotTick > 10) {
      _lastShotTick = tick;
      play('sounds/fuel_plane/plane_shoot.wav', volume: 0.35);
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff020617), Color(0xff0f172a), Color(0xff082f49)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 8),
              const Text('ألعاب زمان V4.3', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('أزرار صحيحة، صوت حركة، 3 أرواح، وسيارة رياضية أوضح', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 28),
              GameTile(
                title: 'طائرة الوقود',
                icon: '✈️',
                text: 'إطلاق تلقائي وتحكم بالسحب أو الشريط.',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: PlaneGame()))),
              ),
              const SizedBox(height: 16),
              GameTile(
                title: 'طريق التحمل',
                icon: '🏎️',
                text: 'ثلاث أرواح، استكمال بعد الاصطدام، وشكل سيارة رياضي أعرض.',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: RoadGame()))),
              ),
              const Spacer(),
              const Text('نسخة أصلية بروح ألعاب التحمل القديمة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }
}

class GameTile extends StatelessWidget {
  const GameTile({super.key, required this.title, required this.icon, required this.text, required this.onTap});
  final String title;
  final String icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white12)),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 42)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(text, style: const TextStyle(color: Colors.white70)),
          ])),
          const Icon(Icons.play_circle_fill, size: 34, color: Colors.lightBlueAccent),
        ]),
      ),
    );
  }
}

class RetroButton extends StatelessWidget {
  const RetroButton({super.key, required this.text, required this.onTap, this.icon});
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon ?? Icons.play_arrow),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
    );
  }
}

class StartCard extends StatelessWidget {
  const StartCard({super.key, required this.title, required this.subtitle, required this.onTap, this.buttonText = 'ابدأ'});
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(22),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.70), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white24)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 18),
        RetroButton(text: buttonText, icon: Icons.play_arrow, onTap: onTap),
      ]),
    );
  }
}

class PixelArt {
  static void draw(Canvas canvas, Offset center, double px, List<String> rows, Map<String, Color> pal, {double shadow = 0}) {
    final maxCols = rows.map((e) => e.length).fold<int>(0, math.max);
    final origin = Offset(center.dx - maxCols * px / 2, center.dy - rows.length * px / 2);
    if (shadow > 0) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx + shadow, origin.dy + shadow, maxCols * px, rows.length * px), Radius.circular(px)), Paint()..color = Colors.black.withOpacity(0.36));
    }
    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < rows[y].length; x++) {
        final color = pal[rows[y][x]];
        if (color == null) continue;
        canvas.drawRect(Rect.fromLTWH(origin.dx + x * px, origin.dy + y * px, px + 0.12, px + 0.12), Paint()..color = color);
      }
    }
  }
}

class PlaneObj {
  PlaneObj({required this.x, required this.y, required this.kind, required this.size});
  double x;
  double y;
  double size;
  int kind;
}

class Bullet {
  Bullet(this.x, this.y);
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
  double planeX = 0.5;
  double fuel = 100;
  int score = 0;
  int distance = 0;
  int tick = 0;
  int level = 1;
  bool running = false;
  bool gameOver = false;
  final objects = <PlaneObj>[];
  final bullets = <Bullet>[];

  void start() {
    timer?.cancel();
    planeX = 0.5;
    fuel = 100;
    score = 0;
    distance = 0;
    tick = 0;
    level = 1;
    running = true;
    gameOver = false;
    objects.clear();
    bullets.clear();
    Sfx.start();
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) => step());
    setState(() {});
  }

  void step() {
    if (!running) return;
    tick++;
    distance++;
    level = 1 + distance ~/ 1800;
    final speed = math.min(0.014, 0.0048 + level * 0.00065).toDouble();
    fuel -= 0.032;
    if (tick % 12 == 0) score++;
    if (tick % 9 == 0) {
      bullets.add(Bullet(planeX - 0.018, 0.735));
      bullets.add(Bullet(planeX + 0.018, 0.735));
      Sfx.shot(tick);
    }
    if (rnd.nextDouble() < (0.014 + level * 0.0015).clamp(0.014, 0.030).toDouble()) {
      final r = rnd.nextDouble();
      final kind = r < 0.27 ? 0 : r < 0.76 ? 1 : 2;
      objects.add(PlaneObj(x: 0.12 + rnd.nextDouble() * 0.76, y: -0.08, kind: kind, size: kind == 0 ? 0.048 : 0.062));
    }
    for (final b in bullets) b.y -= 0.034;
    for (final o in objects) o.y += speed;
    bullets.removeWhere((b) => b.y < -0.05);
    objects.removeWhere((o) => o.y > 1.12);

    final hitO = <PlaneObj>[];
    final hitB = <Bullet>[];
    for (final b in bullets) {
      for (final o in objects) {
        if (o.kind != 0 && (b.x - o.x).abs() < o.size * 0.8 && (b.y - o.y).abs() < o.size) {
          hitO.add(o);
          hitB.add(b);
          score += 60;
          Sfx.boom();
          break;
        }
      }
    }
    objects.removeWhere(hitO.contains);
    bullets.removeWhere(hitB.contains);

    for (final o in List<PlaneObj>.from(objects)) {
      if ((planeX - o.x).abs() < o.size * 0.86 && (0.80 - o.y).abs() < o.size * 0.95) {
        if (o.kind == 0) {
          fuel = math.min(100, fuel + 20).toDouble();
          score += 120;
          objects.remove(o);
          Sfx.fuel();
        } else {
          running = false;
          gameOver = true;
          Sfx.over();
        }
      }
    }
    if (fuel <= 0) {
      running = false;
      gameOver = true;
      Sfx.over();
    }
    if (mounted) setState(() {});
  }

  void setPlane(double value) {
    if (!running) return;
    planeX = value.clamp(0.08, 0.92).toDouble();
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fuelColor = fuel > 45 ? Colors.greenAccent : fuel > 20 ? Colors.orangeAccent : Colors.redAccent;
    return Scaffold(
      appBar: AppBar(title: const Text('طائرة الوقود')),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text('النقاط: $score', style: const TextStyle(fontWeight: FontWeight.w900)),
            Text('المسافة: ${distance ~/ 30}'),
            Text('مرحلة: $level'),
          ]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: fuel.clamp(0, 100).toDouble() / 100, minHeight: 12, valueColor: AlwaysStoppedAnimation(fuelColor), backgroundColor: Colors.white12)),
        ])),
        Expanded(child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)),
          child: LayoutBuilder(builder: (context, c) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (d) => setPlane(d.localPosition.dx / c.maxWidth),
            onPanUpdate: (d) => setPlane(d.localPosition.dx / c.maxWidth),
            child: Stack(children: [
              CustomPaint(painter: PlanePainter(planeX: planeX, objects: objects, bullets: bullets, tick: tick), child: const SizedBox.expand()),
              if (!running) Center(child: StartCard(title: gameOver ? 'انتهت الجولة' : 'طائرة الوقود', subtitle: gameOver ? 'النقاط: $score' : 'إطلاق تلقائي وتحكم بالسحب أو الشريط', onTap: start)),
            ]),
          )),
        )),
        Container(
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
          child: Column(children: [
            const Text('شريط تحكم مثل الماوس', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            Slider(value: planeX.clamp(0.08, 0.92).toDouble(), min: 0.08, max: 0.92, onChanged: running ? setPlane : null),
          ]),
        ),
      ])),
    );
  }
}

class PlanePainter extends CustomPainter {
  PlanePainter({required this.planeX, required this.objects, required this.bullets, required this.tick});
  final double planeX;
  final List<PlaneObj> objects;
  final List<Bullet> bullets;
  final int tick;

  @override
  void paint(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;
    final bg = Offset.zero & s;
    c.drawRect(bg, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff00111d), Color(0xff06334f), Color(0xff00111d)]).createShader(bg));
    final river = Path()
      ..moveTo(w * 0.27, 0)
      ..cubicTo(w * 0.12, h * 0.23, w * 0.38, h * 0.42, w * 0.24, h * 0.66)
      ..cubicTo(w * 0.14, h * 0.82, w * 0.17, h, w * 0.10, h)
      ..lineTo(w * 0.90, h)
      ..cubicTo(w * 0.83, h * 0.82, w * 0.86, h * 0.66, w * 0.76, h * 0.50)
      ..cubicTo(w * 0.62, h * 0.30, w * 0.88, h * 0.18, w * 0.73, 0)
      ..close();
    c.drawPath(river, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff155e75), Color(0xff0891b2), Color(0xff0e7490)]).createShader(bg));
    final bank = Paint()..color = const Color(0xff14532d);
    for (var i = 0; i < 16; i++) {
      final y = ((i * 64 + tick * 2) % (h + 80)).toDouble() - 40;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, y, w * 0.13, 20), const Radius.circular(6)), bank);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.87, y + 22, w * 0.13, 20), const Radius.circular(6)), bank);
    }
    for (final b in bullets) {
      final o = Offset(b.x * w, b.y * h);
      c.drawCircle(o, 5, Paint()..color = const Color(0xfffff176));
      c.drawCircle(o, 11, Paint()..color = const Color(0xfffff176).withOpacity(0.15));
    }
    for (final o in objects) _drawObject(c, s, o);
    PixelArt.draw(c, Offset(planeX * w, h * 0.80), math.max(4.0, w * 0.014), const ['.....C.....', '....CCC....', '....YYY....', 'B..YYYYY..B', 'BBYYYYYYYBB', '..RYYYR..', '...Y.Y...', '..B...B..'], {'C': const Color(0xffe0f2fe), 'Y': const Color(0xff38bdf8), 'B': const Color(0xff2563eb), 'R': const Color(0xffef4444)}, shadow: 5);
    final scan = Paint()..color = Colors.black.withOpacity(0.08);
    for (double y = 0; y < h; y += 5) c.drawRect(Rect.fromLTWH(0, y, w, 1), scan);
  }

  void _drawObject(Canvas c, Size s, PlaneObj o) {
    final center = Offset(o.x * s.width, o.y * s.height);
    final px = math.max(3.0, s.width * o.size / 8);
    if (o.kind == 0) {
      PixelArt.draw(c, center, px, const ['..GG..', '..YY..', '.YYYY.', '.YRR.', '.YRR.', '.YYYY.', '..GG..'], {'G': const Color(0xff22c55e), 'Y': const Color(0xffffd166), 'R': const Color(0xffef4444)}, shadow: 4);
    } else if (o.kind == 2) {
      PixelArt.draw(c, center, px, const ['...R...', '..RRR..', '.RBRBR.', 'RRBBBBR', '..BBB..', '.B...B.'], {'R': const Color(0xffef4444), 'B': const Color(0xff334155)}, shadow: 4);
    } else {
      PixelArt.draw(c, center, px, const ['..SS..', '.SSSS.', 'SSSSSS', 'SDSDSS', '.SSSS.', '..SS..'], {'S': const Color(0xff94a3b8), 'D': const Color(0xff334155)}, shadow: 4);
    }
  }

  @override
  bool shouldRepaint(covariant PlanePainter oldDelegate) => true;
}

class RoadOpponent {
  RoadOpponent({required this.lane, required this.depth, required this.color, required this.speedBias});
  int lane;
  double depth;
  Color color;
  double speedBias;
}

class RoadGame extends StatefulWidget {
  const RoadGame({super.key});
  @override
  State<RoadGame> createState() => _RoadGameState();
}

class _RoadGameState extends State<RoadGame> {
  final rnd = math.Random();
  Timer? timer;
  int playerLane = 2;
  int score = 0;
  int distance = 0;
  int passed = 0;
  int target = 40;
  int day = 1;
  int tick = 0;
  int lives = 3;
  bool running = false;
  bool gameOver = false;
  bool crashed = false;
  final opponents = <RoadOpponent>[];
  final colors = const [Color(0xffef4444), Color(0xffffd166), Color(0xff22c55e), Color(0xffa78bfa), Color(0xfff97316)];

  String get weather {
    final p = (passed % target) / target;
    if (p < 0.18) return 'نهار';
    if (p < 0.34) return 'غروب';
    if (p < 0.52) return 'ليل';
    if (p < 0.68) return 'ضباب';
    if (p < 0.84) return 'ثلج';
    return 'مطر';
  }

  void start() {
    timer?.cancel();
    playerLane = 2;
    score = 0;
    distance = 0;
    passed = 0;
    target = 40;
    day = 1;
    tick = 0;
    lives = 3;
    running = true;
    gameOver = false;
    crashed = false;
    opponents.clear();
    Sfx.start();
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) => step());
    setState(() {});
  }

  void resumeAfterCrash() {
    if (gameOver) return;
    crashed = false;
    running = true;
    Sfx.start();
    setState(() {});
  }

  void step() {
    if (!running) return;
    tick++;
    distance++;
    if (tick % 12 == 0) score++;
    final roadSpeed = math.min(0.0135, 0.0048 + day * 0.00055 + distance / 260000).toDouble();
    final spawn = (0.010 + day * 0.0012).clamp(0.010, 0.024).toDouble();
    if (rnd.nextDouble() < spawn && opponents.length < 5) {
      final lane = rnd.nextInt(5);
      final close = opponents.any((o) => o.lane == lane && o.depth < 0.24);
      if (!close) opponents.add(RoadOpponent(lane: lane, depth: 0.045, color: colors[rnd.nextInt(colors.length)], speedBias: 0.82 + rnd.nextDouble() * 0.28));
    }
    for (final o in opponents) o.depth += roadSpeed * o.speedBias;
    final done = opponents.where((o) => o.depth > 1.08).length;
    if (done > 0) {
      passed += done;
      score += done * 100;
      Sfx.pass();
      opponents.removeWhere((o) => o.depth > 1.08);
    }
    if (passed >= target) {
      day++;
      passed = 0;
      target = math.min(90, target + 12);
      score += 800;
      opponents.clear();
      Sfx.stage();
    }
    for (final o in List<RoadOpponent>.from(opponents)) {
      if (o.depth > 0.78 && o.depth < 0.96 && o.lane == playerLane) {
        opponents.remove(o);
        running = false;
        Sfx.over();
        if (lives > 1) {
          lives--;
          crashed = true;
        } else {
          lives = 0;
          crashed = false;
          gameOver = true;
        }
        break;
      }
    }
    if (mounted) setState(() {});
  }

  void left() {
    if (!running) return;
    final old = playerLane;
    playerLane = math.max(0, playerLane - 1);
    if (playerLane != old) Sfx.steer();
    setState(() {});
  }

  void right() {
    if (!running) return;
    final old = playerLane;
    playerLane = math.min(4, playerLane + 1);
    if (playerLane != old) Sfx.steer();
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = gameOver || crashed || !running;
    final title = gameOver ? 'انتهت اللعبة' : crashed ? 'اصطدام!' : 'طريق التحمل';
    final subtitle = gameOver ? 'النقاط: $score' : crashed ? 'تبقى لديك $lives أرواح — تابع من نفس الجولة' : 'أنت تلحق السيارات أمامك وتتجاوزها. الهدف: $target سيارة';
    final action = gameOver || (!running && !crashed) ? start : resumeAfterCrash;
    final buttonText = crashed ? 'تابع' : 'ابدأ';
    return Scaffold(
      appBar: AppBar(title: const Text('طريق التحمل V4.3')),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text('النقاط: $score', style: const TextStyle(fontWeight: FontWeight.w900)),
            Text('اليوم: $day'),
            Text('الأرواح: $lives'),
            Text('تجاوز: $passed / $target'),
          ]),
          const SizedBox(height: 7),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (passed / target).clamp(0, 1).toDouble(), minHeight: 10, backgroundColor: Colors.white12)),
        ])),
        Expanded(child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)),
          child: Stack(children: [
            CustomPaint(painter: RoadPainter(playerLane: playerLane, opponents: opponents, weather: weather, tick: tick, day: day), child: const SizedBox.expand()),
            Positioned(top: 10, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(14)), child: Text(weather, style: const TextStyle(fontWeight: FontWeight.bold)))),
            if (overlay) Center(child: StartCard(title: title, subtitle: subtitle, buttonText: buttonText, onTap: action)),
          ]),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 12), child: Row(textDirection: TextDirection.ltr, children: [
          Expanded(child: RetroButton(text: 'يسار', icon: Icons.arrow_back, onTap: left)),
          const SizedBox(width: 12),
          Expanded(child: RetroButton(text: 'يمين', icon: Icons.arrow_forward, onTap: right)),
        ])),
      ])),
    );
  }
}

class RoadPainter extends CustomPainter {
  RoadPainter({required this.playerLane, required this.opponents, required this.weather, required this.tick, required this.day});
  final int playerLane;
  final int tick;
  final int day;
  final List<RoadOpponent> opponents;
  final String weather;

  double _ease(double d) => math.pow(d.clamp(0.0, 1.0), 1.12).toDouble();
  double _y(Size s, double d) => s.height * (0.40 + 0.61 * _ease(d));
  double _rw(Size s, double d) => s.width * (0.16 + 0.84 * _ease(d));
  double _laneX(Size s, int lane, double d) {
    final w = _rw(s, d);
    final left = s.width * 0.5 - w / 2;
    return left + w * ((lane + 0.5) / 5.0);
  }

  @override
  void paint(Canvas c, Size s) {
    _sky(c, s);
    _horizon(c, s);
    _road(c, s);
    _sideShoulders(c, s);
    _motion(c, s);
    _posts(c, s);
    final sorted = List<RoadOpponent>.from(opponents)..sort((a, b) => a.depth.compareTo(b.depth));
    for (final o in sorted) _opponentCar(c, s, o);
    _playerCar(c, s);
    _weather(c, s);
    _vignette(c, s);
  }

  void _sky(Canvas c, Size s) {
    late final List<Color> colors;
    switch (weather) {
      case 'غروب': colors = const [Color(0xff35104f), Color(0xffe11d48), Color(0xfff59e0b)]; break;
      case 'ليل': colors = const [Color(0xff020617), Color(0xff0f172a), Color(0xff1e293b)]; break;
      case 'ضباب': colors = const [Color(0xff64748b), Color(0xffa8b3c4), Color(0xffdbe2eb)]; break;
      case 'ثلج': colors = const [Color(0xff93c5fd), Color(0xffdbeafe), Color(0xffffffff)]; break;
      case 'مطر': colors = const [Color(0xff0f172a), Color(0xff334155), Color(0xff475569)]; break;
      default: colors = const [Color(0xff0ea5e9), Color(0xff67e8f9), Color(0xff86efac)];
    }
    c.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(Offset.zero & s));
    if (weather == 'ليل') {
      c.drawCircle(Offset(s.width * 0.78, s.height * 0.13), 22, Paint()..color = Colors.white70);
      for (var i = 0; i < 22; i++) {
        c.drawCircle(Offset((i * 53 % s.width).toDouble(), (18 + i * 19 % (s.height * 0.24)).toDouble()), 1.2, Paint()..color = Colors.white54);
      }
    } else {
      c.drawCircle(Offset(s.width * 0.76, s.height * 0.17), 30, Paint()..color = const Color(0xfffff3b0));
    }
  }

  void _horizon(Canvas c, Size s) {
    final mountain = Path()
      ..moveTo(0, s.height * 0.36)
      ..lineTo(s.width * 0.18, s.height * 0.25)
      ..lineTo(s.width * 0.35, s.height * 0.36)
      ..lineTo(s.width * 0.55, s.height * 0.23)
      ..lineTo(s.width * 0.78, s.height * 0.36)
      ..lineTo(s.width, s.height * 0.27)
      ..lineTo(s.width, s.height * 0.44)
      ..lineTo(0, s.height * 0.44)
      ..close();
    c.drawPath(mountain, Paint()..color = weather == 'ليل' ? const Color(0xff0b1220) : const Color(0xff2563eb).withOpacity(0.22));
    final ground = weather == 'ثلج' ? const Color(0xfff8fafc) : weather == 'مطر' ? const Color(0xff14532d) : const Color(0xff16a34a);
    c.drawRect(Rect.fromLTWH(0, s.height * 0.40, s.width, s.height * 0.60), Paint()..color = ground);
  }

  void _road(Canvas c, Size s) {
    final road = Path()
      ..moveTo(s.width * 0.455, s.height * 0.40)
      ..lineTo(s.width * 0.545, s.height * 0.40)
      ..lineTo(s.width * 0.985, s.height)
      ..lineTo(s.width * 0.015, s.height)
      ..close();
    c.drawPath(road, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff4b5563), Color(0xff1f2937), Color(0xff020617)]).createShader(Rect.fromLTWH(0, s.height * 0.40, s.width, s.height * 0.60)));
    c.drawPath(road, Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = Colors.white.withOpacity(0.42));
  }

  void _sideShoulders(Canvas c, Size s) {
    for (var i = 0; i < 16; i++) {
      final d = (((i * 64 + tick * 5) % 760) / 760).clamp(0.03, 0.98).toDouble();
      final y = _y(s, d);
      final rw = _rw(s, d);
      final center = s.width * 0.5;
      final left = center - rw / 2;
      final right = center + rw / 2;
      final size = 6 + d * 18;
      final p = Paint()..color = (i.isEven ? Colors.white : Colors.redAccent).withOpacity(0.85);
      c.drawRect(Rect.fromCenter(center: Offset(left - 4 * d, y), width: size, height: 4 + d * 8), p);
      c.drawRect(Rect.fromCenter(center: Offset(right + 4 * d, y), width: size, height: 4 + d * 8), p);
    }
  }

  void _motion(Canvas c, Size s) {
    final laneOpacity = weather == 'ضباب' ? 0.25 : 0.72;
    final lane = Paint()..color = Colors.white.withOpacity(laneOpacity);
    for (var i = 0; i < 17; i++) {
      final d = (((i * 60 + tick * 6) % 780) / 780).clamp(0.025, 0.98).toDouble();
      final y = _y(s, d);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * 0.5, y), width: 2 + d * 7, height: 12 + d * 46), const Radius.circular(4)), lane);
    }
  }

  void _posts(Canvas c, Size s) {
    for (var i = 0; i < 10; i++) {
      final d = (((i * 83 + tick * 4) % 820) / 820).clamp(0.06, 0.99).toDouble();
      final y = _y(s, d);
      final rw = _rw(s, d);
      final left = s.width * 0.5 - rw / 2 - 14 * d;
      final right = s.width * 0.5 + rw / 2 + 14 * d;
      final size = 3 + d * 8;
      _post(c, Offset(left, y), size);
      _post(c, Offset(right, y + 20 * d), size);
    }
  }

  void _post(Canvas c, Offset o, double size) {
    c.drawRect(Rect.fromCenter(center: o, width: size, height: size * 3.2), Paint()..color = Colors.white70);
    c.drawRect(Rect.fromCenter(center: o.translate(0, -size), width: size * 1.4, height: size * 0.7), Paint()..color = Colors.redAccent);
  }

  void _opponentCar(Canvas c, Size s, RoadOpponent o) {
    final x = _laneX(s, o.lane, o.depth);
    final y = _y(s, o.depth);
    final scale = 0.32 + o.depth * 1.28;
    _drawSportCar(c, Offset(x, y), s.width * 0.070 * scale, o.color, true);
  }

  void _playerCar(Canvas c, Size s) {
    final x = _laneX(s, playerLane, 0.88);
    final y = s.height * 0.84;
    if (weather == 'ليل' || weather == 'ضباب' || weather == 'مطر') {
      final lightOpacity = weather == 'ضباب' ? 0.20 : 0.14;
      final light = Path()
        ..moveTo(x - 26, y - 10)
        ..lineTo(x - s.width * 0.23, y - s.height * 0.28)
        ..lineTo(x + s.width * 0.23, y - s.height * 0.28)
        ..lineTo(x + 26, y - 10)
        ..close();
      c.drawPath(light, Paint()..color = const Color(0xfffff3b0).withOpacity(lightOpacity));
    }
    _drawSportCar(c, Offset(x, y), s.width * 0.115, const Color(0xff38bdf8), false);
  }

  void _drawSportCar(Canvas c, Offset center, double width, Color body, bool opponent) {
    final height = width * 0.95;
    final shadow = RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, height * 0.18), width: width * 1.22, height: height * 0.78), Radius.circular(width * 0.28));
    c.drawRRect(shadow, Paint()..color = Colors.black.withOpacity(0.35));

    final bodyPath = Path()
      ..moveTo(center.dx - width * 0.50, center.dy + height * 0.23)
      ..lineTo(center.dx - width * 0.40, center.dy - height * 0.34)
      ..quadraticBezierTo(center.dx - width * 0.20, center.dy - height * 0.54, center.dx, center.dy - height * 0.58)
      ..quadraticBezierTo(center.dx + width * 0.20, center.dy - height * 0.54, center.dx + width * 0.40, center.dy - height * 0.34)
      ..lineTo(center.dx + width * 0.50, center.dy + height * 0.23)
      ..quadraticBezierTo(center.dx + width * 0.22, center.dy + height * 0.45, center.dx, center.dy + height * 0.48)
      ..quadraticBezierTo(center.dx - width * 0.22, center.dy + height * 0.45, center.dx - width * 0.50, center.dy + height * 0.23)
      ..close();
    c.drawPath(bodyPath, Paint()..color = body);
    c.drawPath(bodyPath, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(1.2, width * 0.045)..color = Colors.white.withOpacity(0.55));

    final nose = Path()
      ..moveTo(center.dx, center.dy - height * 0.50)
      ..lineTo(center.dx - width * 0.22, center.dy - height * 0.08)
      ..lineTo(center.dx + width * 0.22, center.dy - height * 0.08)
      ..close();
    c.drawPath(nose, Paint()..color = Colors.white.withOpacity(0.18));

    final cabin = RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, -height * 0.02), width: width * 0.42, height: height * 0.34), Radius.circular(width * 0.10));
    c.drawRRect(cabin, Paint()..color = const Color(0xffdbeafe));
    c.drawRRect(cabin, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xff0f172a).withOpacity(0.60));

    final wheel = Paint()..color = const Color(0xff020617);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - width * 0.63, center.dy - height * 0.14, width * 0.17, height * 0.34), Radius.circular(width * 0.06)), wheel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + width * 0.46, center.dy - height * 0.14, width * 0.17, height * 0.34), Radius.circular(width * 0.06)), wheel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - width * 0.58, center.dy + height * 0.20, width * 0.18, height * 0.24), Radius.circular(width * 0.06)), wheel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + width * 0.40, center.dy + height * 0.20, width * 0.18, height * 0.24), Radius.circular(width * 0.06)), wheel);

    final lamp = Paint()..color = opponent ? const Color(0xfffff176) : const Color(0xffef4444);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - width * 0.36, center.dy + height * 0.31, width * 0.22, height * 0.08), const Radius.circular(2)), lamp);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + width * 0.14, center.dy + height * 0.31, width * 0.22, height * 0.08), const Radius.circular(2)), lamp);
  }

  void _weather(Canvas c, Size s) {
    if (weather == 'ضباب') c.drawRect(Offset.zero & s, Paint()..color = Colors.white.withOpacity(0.25));
    if (weather == 'ليل') c.drawRect(Offset.zero & s, Paint()..color = Colors.black.withOpacity(0.10));
    if (weather == 'مطر' || weather == 'ثلج') {
      for (var i = 0; i < 90; i++) {
        final x = ((i * 61 + tick * 2) % s.width).toDouble();
        final y = ((i * 47 + tick * 5) % s.height).toDouble();
        if (weather == 'مطر') {
          c.drawLine(Offset(x, y), Offset(x - 6, y + 18), Paint()..color = const Color(0xff93c5fd).withOpacity(0.70)..strokeWidth = 1.5);
        } else {
          c.drawCircle(Offset(x, y), i % 3 == 0 ? 2.4 : 1.4, Paint()..color = Colors.white.withOpacity(0.90));
        }
      }
    }
  }

  void _vignette(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..style = PaintingStyle.stroke..strokeWidth = 12..color = Colors.black.withOpacity(0.20));
    final scan = Paint()..color = Colors.black.withOpacity(0.055);
    for (double y = 0; y < s.height; y += 5) c.drawRect(Rect.fromLTWH(0, y, s.width, 1), scan);
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) => true;
}
