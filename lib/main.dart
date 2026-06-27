import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RetroV4App());
}

class RetroV4App extends StatelessWidget {
  const RetroV4App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألعاب زمان V4.1',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xff07111f),
        appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Color(0xff0b1220)),
      ),
      home: const Directionality(textDirection: TextDirection.rtl, child: HomeV4()),
    );
  }
}

class Sfx {
  static final AudioPlayer _p = AudioPlayer();
  static int _lastShot = 0;
  static Future<void> play(String path) async {
    try {
      await _p.stop();
      await _p.play(AssetSource(path), volume: .75);
    } catch (_) {}
  }
  static void start() => play('sounds/shared/game_start.wav');
  static void over() => play('sounds/shared/game_over.wav');
  static void fuel() => play('sounds/fuel_plane/fuel_pickup.wav');
  static void boom() => play('sounds/fuel_plane/plane_explosion.wav');
  static void pass() => play('sounds/retro_road/car_pass.wav');
  static void stage() => play('sounds/retro_road/stage_clear.wav');
  static void shot(int tick) {
    if (tick - _lastShot > 10) {
      _lastShot = tick;
      play('sounds/fuel_plane/plane_shoot.wav');
    }
  }
}

class HomeV4 extends StatelessWidget {
  const HomeV4({super.key});

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
              const Text('ألعاب زمان V4.1', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('السيارات الآن بمنطق سباق تحمّل: أنت تلحق وتتجاوز', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 28),
              GameTile(title: 'طائرة الوقود', icon: '✈️', text: 'إطلاق تلقائي، تحكم بالسحب أو الشريط، وقود وعوائق واضحة.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: PlaneV4Screen())))),
              const SizedBox(height: 16),
              GameTile(title: 'طريق التحمل', icon: '🏎️', text: 'أنت تمشي للأمام، تلحق السيارات وتتجاوزها، مع ليل وطقس ومراحل.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: RoadV4Screen())))),
              const Spacer(),
              const Text('نسخة أصلية بروح ألعاب التحمل القديمة، وليست نسخة حرفية من لعبة محمية.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }
}

class GameTile extends StatelessWidget {
  const GameTile({super.key, required this.title, required this.icon, required this.text, required this.onTap});
  final String title, icon, text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white12)),
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

class PixelArt {
  static void draw(Canvas canvas, Offset center, double px, List<String> sprite, Map<String, Color> pal, {double shadow = 0}) {
    final rows = sprite.length;
    final cols = sprite.map((e) => e.length).fold<int>(0, math.max);
    final origin = Offset(center.dx - cols * px / 2, center.dy - rows * px / 2);
    if (shadow > 0) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx + shadow, origin.dy + shadow, cols * px, rows * px), Radius.circular(px)), Paint()..color = Colors.black.withOpacity(.38));
    }
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < sprite[y].length; x++) {
        final c = pal[sprite[y][x]];
        if (c == null) continue;
        canvas.drawRect(Rect.fromLTWH(origin.dx + x * px, origin.dy + y * px, px + .15, px + .15), Paint()..color = c);
      }
    }
  }
}

class PlaneObj {
  PlaneObj({required this.x, required this.y, required this.kind, required this.size});
  double x, y, size;
  int kind;
}

class Bullet {
  Bullet(this.x, this.y);
  double x, y;
}

class PlaneV4Screen extends StatefulWidget {
  const PlaneV4Screen({super.key});
  @override
  State<PlaneV4Screen> createState() => _PlaneV4ScreenState();
}

class _PlaneV4ScreenState extends State<PlaneV4Screen> {
  final rnd = math.Random();
  Timer? timer;
  double planeX = .5;
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
    planeX = .5;
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
    final speed = math.min(.014, .0048 + level * .00065);
    fuel -= .032;
    if (tick % 12 == 0) score += 1;
    if (tick % 9 == 0) {
      bullets.add(Bullet(planeX - .018, .735));
      bullets.add(Bullet(planeX + .018, .735));
      Sfx.shot(tick);
    }
    if (rnd.nextDouble() < (.014 + level * .0015).clamp(.014, .030)) {
      final r = rnd.nextDouble();
      final kind = r < .27 ? 0 : r < .76 ? 1 : 2;
      objects.add(PlaneObj(x: .12 + rnd.nextDouble() * .76, y: -.08, kind: kind, size: kind == 0 ? .048 : .062));
    }
    for (final b in bullets) b.y -= .034;
    for (final o in objects) o.y += speed;
    bullets.removeWhere((b) => b.y < -.05);
    objects.removeWhere((o) => o.y > 1.12);

    final hitObjs = <PlaneObj>[];
    final hitBullets = <Bullet>[];
    for (final b in bullets) {
      for (final o in objects) {
        if (o.kind != 0 && (b.x - o.x).abs() < o.size * .8 && (b.y - o.y).abs() < o.size) {
          hitObjs.add(o);
          hitBullets.add(b);
          score += 60;
          Sfx.boom();
          break;
        }
      }
    }
    objects.removeWhere(hitObjs.contains);
    bullets.removeWhere(hitBullets.contains);

    for (final o in List<PlaneObj>.from(objects)) {
      if ((planeX - o.x).abs() < o.size * .86 && (.80 - o.y).abs() < o.size * .95) {
        if (o.kind == 0) {
          fuel = math.min(100, fuel + 20);
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
    planeX = value.clamp(.08, .92).toDouble();
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
      appBar: AppBar(title: const Text('طائرة الوقود V4')),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text('النقاط: $score', style: const TextStyle(fontWeight: FontWeight.w900)),
            Text('المسافة: ${distance ~/ 30}'),
            Text('مرحلة: $level'),
          ]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: fuel.clamp(0, 100) / 100, minHeight: 12, valueColor: AlwaysStoppedAnimation(fuelColor), backgroundColor: Colors.white12)),
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
              CustomPaint(painter: PlaneV4Painter(planeX: planeX, objects: objects, bullets: bullets, tick: tick, level: level), child: const SizedBox.expand()),
              if (!running) Center(child: _StartCard(title: gameOver ? 'انتهت الجولة' : 'طائرة الوقود', subtitle: gameOver ? 'النقاط: $score' : 'إطلاق تلقائي وتحكم بالسحب أو الشريط', onTap: start)),
            ]),
          )),
        )),
        Container(
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
          child: Column(children: [
            const Text('شريط تحكم مثل الماوس', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            Slider(value: planeX.clamp(.08, .92), min: .08, max: .92, onChanged: running ? setPlane : null),
          ]),
        ),
      ])),
    );
  }
}

class _StartCard extends StatelessWidget {
  const _StartCard({required this.title, required this.subtitle, required this.onTap});
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(22),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.black.withOpacity(.68), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white24)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
      const SizedBox(height: 18),
      RetroButton(text: 'ابدأ', icon: Icons.play_arrow, onTap: onTap),
    ]),
  );
}

class PlaneV4Painter extends CustomPainter {
  PlaneV4Painter({required this.planeX, required this.objects, required this.bullets, required this.tick, required this.level});
  final double planeX;
  final List<PlaneObj> objects;
  final List<Bullet> bullets;
  final int tick, level;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final bg = Offset.zero & s;
    canvas.drawRect(bg, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff00111d), Color(0xff06334f), Color(0xff00111d)]).createShader(bg));
    _stars(canvas, s);
    _river(canvas, s);
    _banks(canvas, s);
    _bullets(canvas, s);
    for (final o in objects) _object(canvas, s, o);
    _plane(canvas, Offset(planeX * w, h * .80), math.max(4.0, w * .014));
    _scan(canvas, s);
  }

  void _stars(Canvas c, Size s) {
    final p = Paint()..color = Colors.white.withOpacity(.45);
    for (var i = 0; i < 54; i++) {
      final x = ((i * 73 + tick) % s.width).toDouble();
      final y = ((i * 39 + tick ~/ 2) % (s.height * .42)).toDouble();
      c.drawRect(Rect.fromLTWH(x, y, i % 7 == 0 ? 3 : 2, i % 7 == 0 ? 3 : 2), p);
    }
  }

  void _river(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final offset = (tick % 90).toDouble();
    final path = Path()
      ..moveTo(w * .27, 0)
      ..cubicTo(w * .12, h * .23, w * .38, h * .42, w * .24, h * .66)
      ..cubicTo(w * .14, h * .82, w * .17, h, w * .10, h)
      ..lineTo(w * .90, h)
      ..cubicTo(w * .83, h * .82, w * .86, h * .66, w * .76, h * .50)
      ..cubicTo(w * .62, h * .30, w * .88, h * .18, w * .73, 0)
      ..close();
    c.drawPath(path, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff155e75), Color(0xff0891b2), Color(0xff0e7490)]).createShader(Rect.fromLTWH(0, 0, w, h)));
    final wave = Paint()..color = Colors.white.withOpacity(.18)..strokeWidth = 2;
    for (double y = -90 + offset; y < h + 80; y += 58) {
      c.drawLine(Offset(w * .38, y), Offset(w * .62, y + 28), wave);
    }
  }

  void _banks(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final p = Paint()..color = const Color(0xff14532d);
    for (var i = 0; i < 16; i++) {
      final y = ((i * 64 + tick * 2) % (h + 80)).toDouble() - 40;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, y, w * .13, 20), const Radius.circular(6)), p);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .87, y + 22, w * .13, 20), const Radius.circular(6)), p);
    }
  }

  void _bullets(Canvas c, Size s) {
    for (final b in bullets) {
      final o = Offset(b.x * s.width, b.y * s.height);
      c.drawCircle(o, 5, Paint()..color = const Color(0xfffff176));
      c.drawCircle(o, 11, Paint()..color = const Color(0xfffff176).withOpacity(.15));
    }
  }

  void _object(Canvas c, Size s, PlaneObj o) {
    final center = Offset(o.x * s.width, o.y * s.height);
    final px = math.max(3.0, s.width * o.size / 8);
    if (o.kind == 0) {
      PixelArt.draw(c, center, px, const ['..GG..','..YY..','.YYYY.','.YRR.','.YRR.','.YYYY.','..GG..'], {'G': const Color(0xff22c55e), 'Y': const Color(0xffffd166), 'R': const Color(0xffef4444)}, shadow: 4);
    } else if (o.kind == 2) {
      PixelArt.draw(c, center, px, const ['...R...','..RRR..','.RBRBR.','RRBBBBR','..BBB..','.B...B.'], {'R': const Color(0xffef4444), 'B': const Color(0xff334155)}, shadow: 4);
    } else {
      PixelArt.draw(c, center, px, const ['..SS..','.SSSS.','SSSSSS','SDSDSS','.SSSS.','..SS..'], {'S': const Color(0xff94a3b8), 'D': const Color(0xff334155)}, shadow: 4);
    }
  }

  void _plane(Canvas c, Offset o, double px) {
    PixelArt.draw(c, o, px, const [
      '.....C.....','....CCC....','....YYY....','B..YYYYY..B','BBYYYYYYYBB','..RYYYR..','...Y.Y...','..B...B..'
    ], {'C': const Color(0xffe0f2fe), 'Y': const Color(0xff38bdf8), 'B': const Color(0xff2563eb), 'R': const Color(0xffef4444)}, shadow: 5);
    c.drawCircle(o.translate(0, 42), 8 + (tick % 3).toDouble(), Paint()..color = const Color(0xffff7a18).withOpacity(.75));
  }

  void _scan(Canvas c, Size s) {
    final p = Paint()..color = Colors.black.withOpacity(.10);
    for (double y = 0; y < s.height; y += 5) c.drawRect(Rect.fromLTWH(0, y, s.width, 1), p);
  }

  @override
  bool shouldRepaint(covariant PlaneV4Painter oldDelegate) => true;
}

class RoadOpponent {
  RoadOpponent({required this.lane, required this.depth, required this.color, required this.speedBias});
  int lane;
  double depth;
  Color color;
  double speedBias;
}

class RoadV4Screen extends StatefulWidget {
  const RoadV4Screen({super.key});
  @override
  State<RoadV4Screen> createState() => _RoadV4ScreenState();
}

class _RoadV4ScreenState extends State<RoadV4Screen> {
  final rnd = math.Random();
  Timer? timer;
  int playerLane = 2;
  int score = 0;
  int distance = 0;
  int passed = 0;
  int target = 40;
  int day = 1;
  int tick = 0;
  bool running = false;
  bool gameOver = false;
  final opponents = <RoadOpponent>[];
  final carColors = const [Color(0xffef4444), Color(0xffffd166), Color(0xff22c55e), Color(0xffa78bfa), Color(0xfff97316)];

  String get weather {
    final p = (passed % target) / target;
    if (p < .18) return 'نهار';
    if (p < .34) return 'غروب';
    if (p < .52) return 'ليل';
    if (p < .68) return 'ضباب';
    if (p < .84) return 'ثلج';
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
    running = true;
    gameOver = false;
    opponents.clear();
    Sfx.start();
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) => step());
    setState(() {});
  }

  void step() {
    if (!running) return;
    tick++;
    distance++;
    if (tick % 12 == 0) score += 1;

    final roadSpeed = math.min(.0135, .0048 + day * .00055 + distance / 260000);
    final spawnChance = (.010 + day * .0012).clamp(.010, .024);
    if (rnd.nextDouble() < spawnChance && opponents.length < 5) {
      final lane = rnd.nextInt(5);
      final tooClose = opponents.any((o) => o.lane == lane && o.depth < .22);
      if (!tooClose) {
        opponents.add(RoadOpponent(
          lane: lane,
          depth: .045,
          color: carColors[rnd.nextInt(carColors.length)],
          speedBias: .82 + rnd.nextDouble() * .28,
        ));
      }
    }

    for (final o in opponents) {
      o.depth += roadSpeed * o.speedBias;
    }

    final passedNow = opponents.where((o) => o.depth > 1.08).length;
    if (passedNow > 0) {
      passed += passedNow;
      score += passedNow * 100;
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

    for (final o in opponents) {
      if (o.depth > .78 && o.depth < .96 && o.lane == playerLane) {
        running = false;
        gameOver = true;
        Sfx.over();
      }
    }

    if (mounted) setState(() {});
  }

  void moveLeft() {
    if (!running) return;
    playerLane = math.max(0, playerLane - 1);
    setState(() {});
  }

  void moveRight() {
    if (!running) return;
    playerLane = math.min(4, playerLane + 1);
    setState(() {});
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('طريق التحمل V4.1')),
    body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text('النقاط: $score', style: const TextStyle(fontWeight: FontWeight.w900)),
          Text('اليوم: $day'),
          Text('تجاوز: $passed / $target'),
        ]),
        const SizedBox(height: 7),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (passed / target).clamp(0, 1), minHeight: 10, backgroundColor: Colors.white12)),
      ])),
      Expanded(child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)),
        child: Stack(children: [
          CustomPaint(painter: RoadEnduroPainter(playerLane: playerLane, opponents: opponents, weather: weather, tick: tick, day: day), child: const SizedBox.expand()),
          Positioned(top: 10, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(.35), borderRadius: BorderRadius.circular(14)), child: Text(weather, style: const TextStyle(fontWeight: FontWeight.bold)))),
          if (!running) Center(child: _StartCard(title: gameOver ? 'حادث!' : 'طريق التحمل', subtitle: gameOver ? 'النقاط: $score' : 'أنت تلحق السيارات أمامك وتتجاوزها. الهدف: $target سيارة', onTap: start)),
        ]),
      )),
      Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 12), child: Row(children: [
        Expanded(child: RetroButton(text: 'يسار', icon: Icons.keyboard_arrow_right, onTap: moveLeft)),
        const SizedBox(width: 12),
        Expanded(child: RetroButton(text: 'يمين', icon: Icons.keyboard_arrow_left, onTap: moveRight)),
      ])),
    ])),
  );
}

class RoadEnduroPainter extends CustomPainter {
  RoadEnduroPainter({required this.playerLane, required this.opponents, required this.weather, required this.tick, required this.day});
  final int playerLane;
  final List<RoadOpponent> opponents;
  final String weather;
  final int tick;
  final int day;

  double _ease(double d) => math.pow(d.clamp(0.0, 1.0), 1.18).toDouble();
  double _y(Size s, double depth) => s.height * (.40 + .62 * _ease(depth));
  double _roadWidth(Size s, double depth) => s.width * (.12 + .86 * _ease(depth));
  double _laneX(Size s, int lane, double depth) {
    final center = s.width * .5;
    final width = _roadWidth(s, depth);
    final left = center - width / 2;
    return left + width * ((lane + .5) / 5.0);
  }

  @override
  void paint(Canvas c, Size s) {
    _sky(c, s);
    _horizon(c, s);
    _road(c, s);
    _roadMotion(c, s);
    _sidePosts(c, s);
    final sorted = List<RoadOpponent>.from(opponents)..sort((a, b) => a.depth.compareTo(b.depth));
    for (final o in sorted) _opponentCar(c, s, o);
    _playerCar(c, s);
    _weather(c, s);
    _scan(c, s);
  }

  void _sky(Canvas c, Size s) {
    List<Color> colors;
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
      c.drawCircle(Offset(s.width * .78, s.height * .13), 22, Paint()..color = Colors.white70);
      for (var i = 0; i < 18; i++) c.drawCircle(Offset((i * 53 % s.width).toDouble(), (18 + i * 19 % (s.height * .22)).toDouble()), 1.4, Paint()..color = Colors.white54);
    } else {
      c.drawCircle(Offset(s.width * .76, s.height * .17), 30, Paint()..color = const Color(0xfffff3b0));
    }
  }

  void _horizon(Canvas c, Size s) {
    final mountain = Path()
      ..moveTo(0, s.height * .36)
      ..lineTo(s.width * .18, s.height * .25)
      ..lineTo(s.width * .35, s.height * .36)
      ..lineTo(s.width * .55, s.height * .23)
      ..lineTo(s.width * .78, s.height * .36)
      ..lineTo(s.width, s.height * .27)
      ..lineTo(s.width, s.height * .44)
      ..lineTo(0, s.height * .44)
      ..close();
    c.drawPath(mountain, Paint()..color = weather == 'ليل' ? const Color(0xff0b1220) : const Color(0xff2563eb).withOpacity(.24));
    final ground = weather == 'ثلج' ? const Color(0xfff8fafc) : weather == 'مطر' ? const Color(0xff14532d) : const Color(0xff16a34a);
    c.drawRect(Rect.fromLTWH(0, s.height * .40, s.width, s.height * .60), Paint()..color = ground);
  }

  void _road(Canvas c, Size s) {
    final road = Path()
      ..moveTo(s.width * .46, s.height * .40)
      ..lineTo(s.width * .54, s.height * .40)
      ..lineTo(s.width * .98, s.height)
      ..lineTo(s.width * .02, s.height)
      ..close();
    c.drawPath(road, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff374151), Color(0xff111827), Color(0xff020617)]).createShader(Rect.fromLTWH(0, s.height * .40, s.width, s.height * .60)));
    c.drawPath(road, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = Colors.white.withOpacity(.35));
  }

  void _roadMotion(Canvas c, Size s) {
    final paint = Paint()..color = Colors.white.withOpacity(weather == 'ضباب' ? .28 : .68);
    for (var i = 0; i < 16; i++) {
      final raw = ((i * 64 + tick * 5) % 760) / 760.0;
      final d = raw.clamp(.02, .98);
      final y = _y(s, d);
      final h = 10 + d * 42;
      final w = 2 + d * 7;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * .5, y), width: w, height: h), const Radius.circular(4)), paint);
    }
  }

  void _sidePosts(Canvas c, Size s) {
    for (var i = 0; i < 12; i++) {
      final d = (((i * 77 + tick * 4) % 820) / 820.0).clamp(.05, .99);
      final y = _y(s, d);
      final rw = _roadWidth(s, d);
      final left = s.width * .5 - rw / 2 - 10 * d;
      final right = s.width * .5 + rw / 2 + 10 * d;
      final size = 3 + d * 8;
      _post(c, Offset(left, y), size);
      _post(c, Offset(right, y + 20 * d), size);
    }
  }

  void _post(Canvas c, Offset o, double size) {
    c.drawRect(Rect.fromCenter(center: o, width: size, height: size * 3.2), Paint()..color = Colors.white70);
    c.drawRect(Rect.fromCenter(center: o.translate(0, -size), width: size * 1.4, height: size * .7), Paint()..color = Colors.redAccent);
  }

  void _opponentCar(Canvas c, Size s, RoadOpponent o) {
    final x = _laneX(s, o.lane, o.depth);
    final y = _y(s, o.depth);
    final scale = .25 + o.depth * 1.15;
    _drawCar(c, Offset(x, y), s.width * .060 * scale, o.color, true, depth: o.depth);
  }

  void _playerCar(Canvas c, Size s) {
    final x = _laneX(s, playerLane, .88);
    final y = s.height * .84;
    if (weather == 'ليل' || weather == 'ضباب' || weather == 'مطر') {
      final light = Path()
        ..moveTo(x - 18, y - 18)
        ..lineTo(x - s.width * .18, y - s.height * .28)
        ..lineTo(x + s.width * .18, y - s.height * .28)
        ..lineTo(x + 18, y - 18)
        ..close();
      c.drawPath(light, Paint()..color = const Color(0xfffff3b0).withOpacity(.16));
    }
    _drawCar(c, Offset(x, y), s.width * .085, const Color(0xff38bdf8), false, depth: .95);
  }

  void _drawCar(Canvas c, Offset center, double width, Color body, bool opponent, {required double depth}) {
    final height = width * 1.45;
    final shadow = RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, height * .13), width: width * 1.08, height: height * .90), Radius.circular(width * .18));
    c.drawRRect(shadow, Paint()..color = Colors.black.withOpacity(.28));

    final bodyRect = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: width, height: height), Radius.circular(width * .16));
    c.drawRRect(bodyRect, Paint()..color = body);
    c.drawRRect(bodyRect, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(1, width * .045)..color = Colors.white.withOpacity(.55));

    final cabin = RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, -height * .18), width: width * .54, height: height * .30), Radius.circular(width * .08));
    c.drawRRect(cabin, Paint()..color = const Color(0xffdbeafe));
    c.drawRRect(cabin, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xff0f172a).withOpacity(.5));

    final wheelPaint = Paint()..color = const Color(0xff020617);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - width * .58, center.dy - height * .18, width * .18, height * .36), Radius.circular(width * .05)), wheelPaint);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + width * .40, center.dy - height * .18, width * .18, height * .36), Radius.circular(width * .05)), wheelPaint);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - width * .58, center.dy + height * .20, width * .18, height * .28), Radius.circular(width * .05)), wheelPaint);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + width * .40, center.dy + height * .20, width * .18, height * .28), Radius.circular(width * .05)), wheelPaint);

    final lamp = Paint()..color = opponent ? const Color(0xfffff176) : const Color(0xffef4444);
    c.drawRect(Rect.fromLTWH(center.dx - width * .32, center.dy + height * .38, width * .18, height * .07), lamp);
    c.drawRect(Rect.fromLTWH(center.dx + width * .14, center.dy + height * .38, width * .18, height * .07), lamp);
  }

  void _weather(Canvas c, Size s) {
    if (weather == 'ضباب') c.drawRect(Offset.zero & s, Paint()..color = Colors.white.withOpacity(.28));
    if (weather == 'ليل') c.drawRect(Offset.zero & s, Paint()..color = Colors.black.withOpacity(.12));
    if (weather == 'مطر' || weather == 'ثلج') {
      for (var i = 0; i < 90; i++) {
        final x = ((i * 61 + tick * 2) % s.width).toDouble();
        final y = ((i * 47 + tick * 5) % s.height).toDouble();
        if (weather == 'مطر') {
          c.drawLine(Offset(x, y), Offset(x - 6, y + 18), Paint()..color = const Color(0xff93c5fd).withOpacity(.70)..strokeWidth = 1.5);
        } else {
          c.drawCircle(Offset(x, y), i % 3 == 0 ? 2.4 : 1.4, Paint()..color = Colors.white.withOpacity(.90));
        }
      }
    }
  }

  void _scan(Canvas c, Size s) {
    final p = Paint()..color = Colors.black.withOpacity(.08);
    for (double y = 0; y < s.height; y += 5) c.drawRect(Rect.fromLTWH(0, y, s.width, 1), p);
  }

  @override
  bool shouldRepaint(covariant RoadEnduroPainter oldDelegate) => true;
}
