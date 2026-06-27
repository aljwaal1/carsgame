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
      title: 'ألعاب زمان V4',
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
              const Text('ألعاب زمان V4', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('إعادة بناء من الصفر: أبطأ، أوضح، ونقاط منطقية', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 28),
              GameTile(title: 'طائرة الوقود', icon: '✈️', text: 'إطلاق تلقائي، تحكم بالسحب أو الشريط، وقود وعوائق واضحة.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: PlaneV4Screen())))),
              const SizedBox(height: 16),
              GameTile(title: 'طريق التحمل', icon: '🏎️', text: 'سباق أهدأ، منظور طريق أفضل، نقاط للتجاوز والمراحل.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: RoadV4Screen())))),
              const Spacer(),
              const Text('هذه نسخة أصلية بروح الألعاب القديمة، وليست نسخة حرفية من لعبة محمية.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
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
  int kind; // 0 fuel, 1 rock, 2 enemy
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

class RoadCarV4 {
  RoadCarV4({required this.x, required this.y, required this.lane, required this.speed});
  double x, y, speed;
  int lane;
}

class RoadV4Screen extends StatefulWidget {
  const RoadV4Screen({super.key});
  @override
  State<RoadV4Screen> createState() => _RoadV4ScreenState();
}

class _RoadV4ScreenState extends State<RoadV4Screen> {
  final rnd = math.Random();
  Timer? timer;
  double playerX = .5;
  int score = 0;
  int distance = 0;
  int passed = 0;
  int stage = 1;
  int tick = 0;
  bool running = false;
  bool gameOver = false;
  final cars = <RoadCarV4>[];
  final lanes = [.28, .40, .52, .64, .76];

  String get weather {
    final p = (passed % 36) / 36;
    if (p < .18) return 'نهار';
    if (p < .34) return 'غروب';
    if (p < .52) return 'ليل';
    if (p < .68) return 'ضباب';
    if (p < .84) return 'ثلج';
    return 'مطر';
  }

  void start() {
    timer?.cancel();
    playerX = .5;
    score = 0;
    distance = 0;
    passed = 0;
    stage = 1;
    tick = 0;
    running = true;
    gameOver = false;
    cars.clear();
    Sfx.start();
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) => step());
    setState(() {});
  }

  void step() {
    if (!running) return;
    tick++;
    distance++;
    if (tick % 10 == 0) score += 1;
    final speed = math.min(.017, .0055 + stage * .00055 + distance / 250000);
    if (rnd.nextDouble() < (.014 + stage * .0014).clamp(.014, .027)) {
      final lane = rnd.nextInt(lanes.length);
      cars.add(RoadCarV4(x: lanes[lane] + (rnd.nextDouble() - .5) * .018, y: -.12, lane: lane, speed: .72 + rnd.nextDouble() * .32));
    }
    for (final c in cars) c.y += speed * c.speed;
    final before = cars.length;
    cars.removeWhere((c) => c.y > 1.12);
    final removed = before - cars.length;
    if (removed > 0) {
      passed += removed;
      score += removed * 100;
      Sfx.pass();
      if (passed > 0 && passed % 36 == 0) {
        stage++;
        score += 700;
        cars.clear();
        Sfx.stage();
      }
    }
    for (final c in cars) {
      if ((playerX - c.x).abs() < .050 && (.84 - c.y).abs() < .065) {
        running = false;
        gameOver = true;
        Sfx.over();
      }
    }
    if (mounted) setState(() {});
  }

  void move(double dx) {
    if (!running) return;
    playerX = (playerX + dx).clamp(.16, .84).toDouble();
    setState(() {});
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('طريق التحمل V4')),
    body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text('النقاط: $score', style: const TextStyle(fontWeight: FontWeight.w900)),
        Text('تجاوز: $passed'),
        Text('الجو: $weather'),
      ])),
      Expanded(child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)),
        child: Stack(children: [
          CustomPaint(painter: RoadV4Painter(playerX: playerX, cars: cars, weather: weather, tick: tick, score: score), child: const SizedBox.expand()),
          if (!running) Center(child: _StartCard(title: gameOver ? 'حادث!' : 'طريق التحمل', subtitle: gameOver ? 'النقاط: $score' : 'تجاوز السيارات وأنهِ المراحل بهدوء', onTap: start)),
        ]),
      )),
      Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 12), child: Row(children: [
        Expanded(child: RetroButton(text: 'يسار', icon: Icons.keyboard_arrow_right, onTap: () => move(-.045))),
        const SizedBox(width: 12),
        Expanded(child: RetroButton(text: 'يمين', icon: Icons.keyboard_arrow_left, onTap: () => move(.045))),
      ])),
    ])),
  );
}

class RoadV4Painter extends CustomPainter {
  RoadV4Painter({required this.playerX, required this.cars, required this.weather, required this.tick, required this.score});
  final double playerX;
  final List<RoadCarV4> cars;
  final String weather;
  final int tick, score;

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final colors = _sky();
    c.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(Offset.zero & s));
    _sun(c, s);
    _mountains(c, s);
    _road(c, s);
    _posts(c, s);
    _lanes(c, s);
    for (final car in cars) _car(c, Offset(car.x * w, car.y * h), math.max(2.6, w * (.006 + car.y.clamp(0, 1) * .015)), true, car.lane);
    final pc = Offset(playerX * w, h * .84);
    if (weather == 'ليل' || weather == 'ضباب' || weather == 'مطر') _lights(c, s, pc);
    _car(c, pc, math.max(5.4, w * .018), false, 0);
    _weather(c, s);
    _scan(c, s);
  }

  List<Color> _sky() {
    switch (weather) {
      case 'غروب': return const [Color(0xff301150), Color(0xffe11d48), Color(0xfff59e0b)];
      case 'ليل': return const [Color(0xff020617), Color(0xff111827), Color(0xff172033)];
      case 'ضباب': return const [Color(0xff64748b), Color(0xffa8b3c4), Color(0xffdbe2eb)];
      case 'ثلج': return const [Color(0xff93c5fd), Color(0xffdbeafe), Color(0xffffffff)];
      case 'مطر': return const [Color(0xff0f172a), Color(0xff334155), Color(0xff475569)];
      default: return const [Color(0xff0ea5e9), Color(0xff67e8f9), Color(0xff86efac)];
    }
  }

  void _sun(Canvas c, Size s) {
    if (weather == 'ليل') c.drawCircle(Offset(s.width * .78, s.height * .12), 23, Paint()..color = Colors.white70);
    if (weather == 'غروب' || weather == 'نهار') c.drawCircle(Offset(s.width * .72, s.height * .17), 30, Paint()..color = const Color(0xfffff3b0));
  }

  void _mountains(Canvas c, Size s) {
    final p = Paint()..color = weather == 'ليل' ? const Color(0xff0b1220) : const Color(0xff1d4ed8).withOpacity(.28);
    final path = Path()..moveTo(0, s.height*.36)..lineTo(s.width*.18, s.height*.24)..lineTo(s.width*.35, s.height*.36)..lineTo(s.width*.52, s.height*.22)..lineTo(s.width*.72, s.height*.37)..lineTo(s.width, s.height*.26)..lineTo(s.width, s.height*.47)..lineTo(0, s.height*.47)..close();
    c.drawPath(path, p);
    final ground = weather == 'ثلج' ? const Color(0xfff8fafc) : const Color(0xff166534);
    c.drawRect(Rect.fromLTWH(0, s.height*.40, s.width, s.height*.60), Paint()..color = weather == 'مطر' ? const Color(0xff1e3a2f) : ground);
  }

  void _road(Canvas c, Size s) {
    final w=s.width,h=s.height;
    final road = Path()..moveTo(w*.46,h*.37)..lineTo(w*.54,h*.37)..lineTo(w*.96,h)..lineTo(w*.04,h)..close();
    c.drawPath(road, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff111827), Color(0xff1f2937), Color(0xff020617)]).createShader(Rect.fromLTWH(0,h*.37,w,h*.63)));
    c.drawPath(road, Paint()..style=PaintingStyle.stroke..strokeWidth=5..color=Colors.white.withOpacity(.35));
  }

  void _posts(Canvas c, Size s) {
    for (var i=0;i<10;i++) {
      final y=((i*72+tick*3)%(s.height+110)).toDouble()-55;
      if (y<s.height*.38) continue;
      final t=(y/s.height).clamp(0.0,1.0);
      final lx=s.width*(.43-.37*t), rx=s.width*(.57+.37*t);
      _post(c,Offset(lx,y),4+t*7); _post(c,Offset(rx,y+26),4+t*7);
    }
  }
  void _post(Canvas c, Offset o, double size) {
    c.drawRect(Rect.fromCenter(center:o,width:size,height:size*3),Paint()..color=Colors.white70);
    c.drawRect(Rect.fromCenter(center:o.translate(0,-size),width:size*1.4,height:size*.7),Paint()..color=Colors.redAccent);
  }

  void _lanes(Canvas c, Size s) {
    final p=Paint()..color=Colors.white.withOpacity(weather=='ضباب'?.30:.72);
    for(var i=0;i<11;i++){
      final y=((i*78+tick*4)%(s.height+110)).toDouble()-55;
      if(y<s.height*.38)continue;
      final t=(y/s.height).clamp(0.0,1.0);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(s.width*.5,y),width:3+t*7,height:16+t*48),const Radius.circular(4)),p);
    }
  }

  void _lights(Canvas c, Size s, Offset pc){
    final path=Path()..moveTo(pc.dx-22,pc.dy-12)..lineTo(pc.dx-s.width*.23,pc.dy-s.height*.37)..lineTo(pc.dx+s.width*.23,pc.dy-s.height*.37)..lineTo(pc.dx+22,pc.dy-12)..close();
    c.drawPath(path,Paint()..color=const Color(0xfffff3b0).withOpacity(.16));
  }

  void _car(Canvas c, Offset center, double px, bool enemy, int lane){
    final palette=[const Color(0xffef4444),const Color(0xffffd166),const Color(0xff22c55e),const Color(0xffa78bfa),const Color(0xfff97316)];
    final body=enemy?palette[lane%palette.length]:const Color(0xff38bdf8);
    PixelArt.draw(c, center, px, const ['...WW...','..WBBW..','.WBBBBW.','RBBBBBBR','BBBBBBBB','KBBBBBBK','KBB..BBK','.BB..BB.'], {'W':const Color(0xffe0f2fe),'B':body,'R':enemy?const Color(0xfffff176):const Color(0xffef4444),'K':const Color(0xff020617)}, shadow:4);
  }

  void _weather(Canvas c, Size s){
    if(weather=='ضباب') c.drawRect(Offset.zero&s,Paint()..color=Colors.white.withOpacity(.30));
    if(weather=='ليل') c.drawRect(Offset.zero&s,Paint()..color=Colors.black.withOpacity(.18));
    if(weather=='مطر'||weather=='ثلج'){
      for(var i=0;i<90;i++){
        final x=((i*61+tick*2)%s.width).toDouble(); final y=((i*47+tick*5)%s.height).toDouble();
        if(weather=='مطر') c.drawLine(Offset(x,y),Offset(x-6,y+18),Paint()..color=const Color(0xff93c5fd).withOpacity(.7)..strokeWidth=1.5);
        else c.drawCircle(Offset(x,y),i%3==0?2.4:1.4,Paint()..color=Colors.white.withOpacity(.9));
      }
    }
  }

  void _scan(Canvas c, Size s){ final p=Paint()..color=Colors.black.withOpacity(.10); for(double y=0;y<s.height;y+=5){c.drawRect(Rect.fromLTWH(0,y,s.width,1),p);} }
  @override
  bool shouldRepaint(covariant RoadV4Painter oldDelegate)=>true;
}
