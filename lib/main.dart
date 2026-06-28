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
      title: 'ألعاب زمان V4.5',
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

  static Future<void> play(String path, double volume) async {
    try {
      await _p.stop();
      await _p.play(AssetSource(path), volume: volume);
    } catch (_) {}
  }

  static void start() => play('sounds/shared/game_start.wav', .55);
  static void stop() => play('sounds/shared/game_over.wav', .65);
  static void pass() => play('sounds/retro_road/car_pass.wav', .38);
  static void steer() => play('sounds/retro_road/car_pass.wav', .22);
  static void stage() => play('sounds/retro_road/stage_clear.wav', .55);
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff020617), Color(0xff0b1028), Color(0xff082f49)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 18),
              const Text('ألعاب زمان V4.5', textAlign: TextAlign.center, style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: .5)),
              const SizedBox(height: 8),
              const Text('ستايل كونسول قديم: طريق 3D، إضاءة، ضباب، وسيارة رياضية منخفضة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 28),
              _Tile(
                title: 'طريق التحمل',
                icon: '🏎️',
                text: 'إحساس PlayStation 2: ظل، لمعان، طريق عميق، وطقس يؤثر على الرؤية.',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: RoadGame()))),
              ),
              const SizedBox(height: 16),
              _Tile(
                title: 'طائرة الوقود',
                icon: '✈️',
                text: 'مؤجلة قليلًا حتى نثبت لعبة السيارات بأفضل شكل.',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: PlaneMini()))),
              ),
              const Spacer(),
              const Text('تصميم أصلي مستوحى من ألعاب التحمل القديمة، بدون نسخ لعبة محمية.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
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
  Widget build(BuildContext context) {
    return InkWell(
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
}

class PlaneMini extends StatelessWidget {
  const PlaneMini({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('طائرة الوقود')),
        body: const Center(child: Text('التركيز الآن على تحسين لعبة السيارات.')),
      );
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
    cars.clear();
    running = true;
    stopped = false;
    gameOver = false;
    Sfx.start();
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) => step());
    setState(() {});
  }

  void resume() {
    if (!gameOver) {
      stopped = false;
      running = true;
      Sfx.start();
      setState(() {});
    }
  }

  void step() {
    if (!running) return;
    tick++;
    distance++;
    if (tick % 12 == 0) score++;
    final speed = math.min(.0145, .0049 + day * .00058 + distance / 250000).toDouble();
    final spawn = (.011 + day * .0012).clamp(.011, .025).toDouble();
    if (rnd.nextDouble() < spawn && cars.length < 5) {
      final l = rnd.nextInt(5);
      if (!cars.any((c) => c.lane == l && c.depth < .25)) {
        cars.add(RoadCar(lane: l, depth: .04, color: colors[rnd.nextInt(colors.length)], speed: .82 + rnd.nextDouble() * .28));
      }
    }
    for (final c in cars) {
      c.depth += speed * c.speed;
    }
    final done = cars.where((c) => c.depth > 1.08).length;
    if (done > 0) {
      passed += done;
      score += done * 100;
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
        Sfx.stop();
        if (lives > 1) {
          lives--;
          stopped = true;
        } else {
          lives = 0;
          gameOver = true;
          stopped = false;
        }
        break;
      }
    }
    if (mounted) setState(() {});
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
    final title = gameOver ? 'انتهت اللعبة' : stopped ? 'اصطدام!' : 'طريق التحمل';
    final sub = gameOver ? 'النقاط: $score' : stopped ? 'تبقى لديك $lives أرواح — تابع من نفس الجولة' : 'رؤية متغيرة + طريق 3D. الهدف: $target سيارة';
    return Scaffold(
      appBar: AppBar(title: const Text('طريق التحمل V4.5')),
      body: SafeArea(child: Column(children: [
        _Hud(score: score, day: day, lives: lives, passed: passed, target: target, weather: weather),
        Expanded(child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.lightBlueAccent.withOpacity(.22)),
            boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(.10), blurRadius: 28)],
          ),
          child: Stack(children: [
            CustomPaint(painter: RoadPainter(playerLane: lane, cars: cars, weather: weather, tick: tick), child: const SizedBox.expand()),
            if (overlay) Center(child: StartCard(title: title, subtitle: sub, buttonText: stopped ? 'تابع' : 'ابدأ', onTap: stopped ? resume : start)),
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

class _Hud extends StatelessWidget {
  const _Hud({required this.score, required this.day, required this.lives, required this.passed, required this.target, required this.weather});
  final int score, day, lives, passed, target;
  final String weather;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(children: [
        Row(children: [
          Expanded(child: _Chip(label: 'النقاط', value: '$score')),
          const SizedBox(width: 6),
          Expanded(child: _Chip(label: 'اليوم', value: '$day')),
          const SizedBox(width: 6),
          Expanded(child: _Chip(label: 'الأرواح', value: '$lives')),
          const SizedBox(width: 6),
          Expanded(child: _Chip(label: 'الجو', value: weather)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: (passed / target).clamp(0, 1).toDouble(), minHeight: 10, backgroundColor: Colors.white12, color: Colors.cyanAccent),
        ),
      ]),
    );
  }
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

class StartCard extends StatelessWidget {
  const StartCard({super.key, required this.title, required this.subtitle, required this.onTap, this.buttonText = 'ابدأ'});
  final String title, subtitle, buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(22),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.76),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.cyanAccent.withOpacity(.22)),
          boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(.12), blurRadius: 30)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          RetroButton(text: buttonText, icon: Icons.play_arrow, onTap: onTap),
        ]),
      );
}

class RoadPainter extends CustomPainter {
  RoadPainter({required this.playerLane, required this.cars, required this.weather, required this.tick});
  final int playerLane, tick;
  final List<RoadCar> cars;
  final String weather;

  double ease(double d) => math.pow(d.clamp(0, 1), 1.13).toDouble();
  double yOf(Size s, double d) => s.height * (.38 + .63 * ease(d));
  double roadW(Size s, double d) => s.width * (.13 + .92 * ease(d));
  double laneX(Size s, int lane, double d) {
    final rw = roadW(s, d);
    final left = s.width * .5 - rw / 2;
    return left + rw * ((lane + .5) / 5);
  }

  double vis(double d) {
    if (weather == 'نهار') return 1;
    if (weather == 'غروب') return (1 - d * .16).clamp(.70, 1).toDouble();
    if (weather == 'ليل') return (.12 + d * .88).clamp(.15, 1).toDouble();
    if (weather == 'ضباب') return (.06 + d * .94).clamp(.08, 1).toDouble();
    if (weather == 'مطر') return (.28 + d * .72).clamp(.28, 1).toDouble();
    if (weather == 'ثلج') return (.35 + d * .65).clamp(.35, 1).toDouble();
    return 1;
  }

  @override
  void paint(Canvas c, Size s) {
    drawSky(c, s);
    drawWorld(c, s);
    drawRoad(c, s);
    drawRoadDetails(c, s);
    final sorted = List<RoadCar>.from(cars)..sort((a, b) => a.depth.compareTo(b.depth));
    for (final car in sorted) drawOpponent(c, s, car);
    drawHeadlights(c, s);
    drawPlayer(c, s);
    drawWeather(c, s);
    drawPostFx(c, s);
  }

  void drawSky(Canvas c, Size s) {
    late final List<Color> colors;
    switch (weather) {
      case 'غروب': colors = const [Color(0xff22063f), Color(0xff9f1239), Color(0xfffb923c)]; break;
      case 'ليل': colors = const [Color(0xff01030d), Color(0xff081021), Color(0xff111827)]; break;
      case 'ضباب': colors = const [Color(0xff64748b), Color(0xff94a3b8), Color(0xffdbeafe)]; break;
      case 'ثلج': colors = const [Color(0xff93c5fd), Color(0xffdbeafe), Color(0xffffffff)]; break;
      case 'مطر': colors = const [Color(0xff030712), Color(0xff1f2937), Color(0xff475569)]; break;
      default: colors = const [Color(0xff0284c7), Color(0xff67e8f9), Color(0xff86efac)];
    }
    c.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(Offset.zero & s));
    if (weather == 'ليل') {
      c.drawCircle(Offset(s.width * .78, s.height * .13), 22, Paint()..color = Colors.white70);
      for (var i = 0; i < 26; i++) {
        c.drawCircle(Offset(((i * 57) % s.width).toDouble(), (18 + (i * 23) % (s.height * .25)).toDouble()), 1.2, Paint()..color = Colors.white54);
      }
    } else {
      c.drawCircle(Offset(s.width * .76, s.height * .17), 34, Paint()..color = const Color(0xfffff3b0));
      c.drawCircle(Offset(s.width * .76, s.height * .17), 58, Paint()..color = const Color(0xfffff3b0).withOpacity(.10));
    }
  }

  void drawWorld(Canvas c, Size s) {
    final mountain = Path()
      ..moveTo(0, s.height * .36)
      ..lineTo(s.width * .15, s.height * .23)
      ..lineTo(s.width * .34, s.height * .36)
      ..lineTo(s.width * .54, s.height * .22)
      ..lineTo(s.width * .76, s.height * .36)
      ..lineTo(s.width, s.height * .25)
      ..lineTo(s.width, s.height * .44)
      ..lineTo(0, s.height * .44)
      ..close();
    c.drawPath(mountain, Paint()..color = weather == 'ليل' ? const Color(0xff050816) : const Color(0xff1e3a8a).withOpacity(weather == 'ضباب' ? .08 : .22));
    final ground = weather == 'ثلج'
        ? const Color(0xffeef2ff)
        : weather == 'مطر'
            ? const Color(0xff0f3d23)
            : weather == 'ليل'
                ? const Color(0xff052e16)
                : const Color(0xff16a34a);
    c.drawRect(Rect.fromLTWH(0, s.height * .40, s.width, s.height * .60), Paint()..color = ground);
  }

  void drawRoad(Canvas c, Size s) {
    final top = s.height * .38;
    final road = Path()
      ..moveTo(s.width * .462, top)
      ..lineTo(s.width * .538, top)
      ..lineTo(s.width * 1.02, s.height)
      ..lineTo(-s.width * .02, s.height)
      ..close();
    final roadColors = weather == 'ثلج'
        ? const [Color(0xffa1a1aa), Color(0xff6b7280), Color(0xff374151)]
        : weather == 'مطر'
            ? const [Color(0xff1f2937), Color(0xff0f172a), Color(0xff020617)]
            : weather == 'ليل'
                ? const [Color(0xff111827), Color(0xff030712), Color(0xff000000)]
                : const [Color(0xff52525b), Color(0xff27272a), Color(0xff09090b)];
    c.drawPath(road, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: roadColors).createShader(Rect.fromLTWH(0, top, s.width, s.height - top)));
    c.drawPath(road, Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = Colors.white.withOpacity(weather == 'ليل' ? .18 : .40));
  }

  void drawRoadDetails(Canvas c, Size s) {
    for (var i = 0; i < 20; i++) {
      final d = (((i * 58 + tick * 7) % 820) / 820).clamp(.025, .99).toDouble();
      final y = yOf(s, d);
      final rw = roadW(s, d);
      final left = s.width * .5 - rw / 2;
      final right = s.width * .5 + rw / 2;
      final v = vis(d);
      final stripeColor = (i.isEven ? Colors.white : Colors.redAccent).withOpacity(v * (weather == 'ليل' ? .42 : .82));
      final stripe = Paint()..color = stripeColor;
      final size = 6 + d * 22;
      c.drawRect(Rect.fromCenter(center: Offset(left - 5 * d, y), width: size, height: 4 + d * 9), stripe);
      c.drawRect(Rect.fromCenter(center: Offset(right + 5 * d, y), width: size, height: 4 + d * 9), stripe);
      if (i % 2 == 0) {
        final lanePaint = Paint()..color = Colors.white.withOpacity(v * (weather == 'ليل' ? .36 : weather == 'ضباب' ? .28 : .70));
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * .5, y), width: 2 + d * 8, height: 12 + d * 48), const Radius.circular(4)), lanePaint);
      }
    }
  }

  void drawOpponent(Canvas c, Size s, RoadCar car) {
    final v = vis(car.depth);
    if (v < .12) return;
    final x = laneX(s, car.lane, car.depth);
    final y = yOf(s, car.depth);
    final scale = .32 + car.depth * 1.35;
    if (weather == 'ليل' && car.depth < .55) {
      final p = Paint()..color = const Color(0xfffff176).withOpacity(v);
      final r = s.width * .026 * scale;
      c.drawCircle(Offset(x - r * 2.1, y), r, p);
      c.drawCircle(Offset(x + r * 2.1, y), r, p);
      return;
    }
    drawSuperCar(c, Offset(x, y), s.width * .082 * scale, Color.lerp(const Color(0xff111827), car.color, v) ?? car.color, true, v);
  }

  void drawHeadlights(Canvas c, Size s) {
    if (weather != 'ليل' && weather != 'ضباب' && weather != 'مطر') return;
    final x = laneX(s, playerLane, .88);
    final y = s.height * .84;
    final op = weather == 'ليل' ? .24 : weather == 'ضباب' ? .17 : .12;
    final cone = Path()
      ..moveTo(x - 40, y - 12)
      ..lineTo(s.width * .31, s.height * .40)
      ..lineTo(s.width * .69, s.height * .40)
      ..lineTo(x + 40, y - 12)
      ..close();
    c.drawPath(cone, Paint()..color = const Color(0xfffff3b0).withOpacity(op));
  }

  void drawPlayer(Canvas c, Size s) {
    drawSuperCar(c, Offset(laneX(s, playerLane, .88), s.height * .84), s.width * .145, const Color(0xff38bdf8), false, 1);
  }

  void drawSuperCar(Canvas c, Offset o, double w, Color body, bool opponent, double opacity) {
    final h = w * .66;
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, h * .22), width: w * 1.22, height: h * .62), Radius.circular(w * .35)), Paint()..color = Colors.black.withOpacity(.36 * opacity));
    final glow = Paint()..color = body.withOpacity(.10 * opacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    c.drawOval(Rect.fromCenter(center: o, width: w * 1.22, height: h * .95), glow);
    final bodyPath = Path()
      ..moveTo(o.dx - w * .56, o.dy + h * .12)
      ..quadraticBezierTo(o.dx - w * .50, o.dy - h * .22, o.dx - w * .28, o.dy - h * .40)
      ..quadraticBezierTo(o.dx - w * .10, o.dy - h * .54, o.dx, o.dy - h * .55)
      ..quadraticBezierTo(o.dx + w * .10, o.dy - h * .54, o.dx + w * .28, o.dy - h * .40)
      ..quadraticBezierTo(o.dx + w * .50, o.dy - h * .22, o.dx + w * .56, o.dy + h * .12)
      ..lineTo(o.dx + w * .45, o.dy + h * .34)
      ..quadraticBezierTo(o.dx, o.dy + h * .50, o.dx - w * .45, o.dy + h * .34)
      ..close();
    c.drawPath(bodyPath, Paint()..color = body.withOpacity(opacity));
    c.drawPath(bodyPath, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(1.1, w * .038)..color = Colors.white.withOpacity(.50 * opacity));
    final hood = Path()
      ..moveTo(o.dx, o.dy - h * .49)
      ..lineTo(o.dx - w * .24, o.dy - h * .09)
      ..lineTo(o.dx + w * .24, o.dy - h * .09)
      ..close();
    c.drawPath(hood, Paint()..color = Colors.white.withOpacity(.17 * opacity));
    final cabin = RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, -h * .01), width: w * .34, height: h * .30), Radius.circular(w * .10));
    c.drawRRect(cabin, Paint()..color = const Color(0xffdbeafe).withOpacity(.92 * opacity));
    final wheel = Paint()..color = const Color(0xff020617).withOpacity(opacity);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w * .64, o.dy - h * .09, w * .18, h * .29), Radius.circular(w * .06)), wheel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx + w * .46, o.dy - h * .09, w * .18, h * .29), Radius.circular(w * .06)), wheel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w * .57, o.dy + h * .17, w * .19, h * .19), Radius.circular(w * .06)), wheel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx + w * .38, o.dy + h * .17, w * .19, h * .19), Radius.circular(w * .06)), wheel);
    final lamp = Paint()..color = (opponent ? const Color(0xfffff176) : const Color(0xffef4444)).withOpacity(opacity);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w * .39, o.dy + h * .26, w * .25, h * .08), const Radius.circular(2)), lamp);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx + w * .14, o.dy + h * .26, w * .25, h * .08), const Radius.circular(2)), lamp);
    if (!opponent) {
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, h * .44), width: w * .44, height: h * .055), Radius.circular(w * .03)), Paint()..color = const Color(0xff020617).withOpacity(.85));
    }
  }

  void drawWeather(Canvas c, Size s) {
    if (weather == 'ليل') c.drawRect(Offset.zero & s, Paint()..color = Colors.black.withOpacity(.30));
    if (weather == 'ضباب') {
      c.drawRect(Offset.zero & s, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xCCFFFFFF), Color(0x66FFFFFF), Color(0x18FFFFFF)]).createShader(Offset.zero & s));
    }
    if (weather == 'مطر') {
      c.drawRect(Offset.zero & s, Paint()..color = Colors.blueGrey.withOpacity(.13));
      for (var i = 0; i < 86; i++) {
        final x = ((i * 61 + tick * 2) % s.width).toDouble();
        final y = ((i * 47 + tick * 5) % s.height).toDouble();
        c.drawLine(Offset(x, y), Offset(x - 6, y + 18), Paint()..color = const Color(0xff93c5fd).withOpacity(.62)..strokeWidth = 1.4);
      }
    }
    if (weather == 'ثلج') {
      c.drawRect(Offset.zero & s, Paint()..color = Colors.white.withOpacity(.10));
      for (var i = 0; i < 74; i++) {
        final x = ((i * 67 + tick) % s.width).toDouble();
        final y = ((i * 41 + tick * 2) % s.height).toDouble();
        c.drawCircle(Offset(x, y), i.isEven ? 2.2 : 1.4, Paint()..color = Colors.white.withOpacity(.90));
      }
    }
    if (weather == 'غروب') c.drawRect(Offset.zero & s, Paint()..color = const Color(0xffff7a18).withOpacity(.08));
  }

  void drawPostFx(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..style = PaintingStyle.stroke..strokeWidth = 14..color = Colors.black.withOpacity(.20));
    final scan = Paint()..color = Colors.black.withOpacity(.040);
    for (double y = 0; y < s.height; y += 5) {
      c.drawRect(Rect.fromLTWH(0, y, s.width, 1), scan);
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) => true;
}
