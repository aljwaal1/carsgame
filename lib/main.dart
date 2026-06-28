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
      title: 'ألعاب زمان V4.4',
      theme: ThemeData.dark(useMaterial3: true).copyWith(scaffoldBackgroundColor: const Color(0xff07111f)),
      home: const Directionality(textDirection: TextDirection.rtl, child: Home()),
    );
  }
}

class Sfx {
  static final AudioPlayer p = AudioPlayer();
  static Future<void> play(String path, double volume) async {
    try {
      await p.stop();
      await p.play(AssetSource(path), volume: volume);
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
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff020617), Color(0xff082f49)])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 14),
              const Text('ألعاب زمان V4.4', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('سيارة رياضية عريضة ورؤية تتغير حسب النهار والليل والضباب والمطر', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 28),
              _Tile(title: 'طريق التحمل', icon: '🏎️', text: 'ثلاث أرواح، أزرار صحيحة، رؤية حقيقية حسب الطقس.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: RoadGame())))),
              const SizedBox(height: 16),
              _Tile(title: 'طائرة الوقود', icon: '✈️', text: 'ستُحسّن لاحقًا بعد تثبيت لعبة السيارات.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: PlaneMini())))),
              const Spacer(),
              const Text('نسخة أصلية مستوحاة من ألعاب التحمل القديمة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.icon, required this.text, required this.onTap});
  final String title, icon, text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(26), border: Border.all(color: Colors.white12)),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 42)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(text, style: const TextStyle(color: Colors.white70))])),
            const Icon(Icons.play_circle_fill, color: Colors.lightBlueAccent, size: 34),
          ]),
        ),
      );
}

class PlaneMini extends StatelessWidget {
  const PlaneMini({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('طائرة الوقود')), body: const Center(child: Text('التركيز الآن على تحسين لعبة السيارات.')));
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
  int lane = 2, score = 0, passed = 0, target = 40, day = 1, tick = 0, lives = 3, distance = 0;
  bool running = false, stopped = false, gameOver = false;
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
    final speed = math.min(.0135, .0048 + day * .00055 + distance / 260000).toDouble();
    final spawn = (.010 + day * .0012).clamp(.010, .024).toDouble();
    if (rnd.nextDouble() < spawn && cars.length < 5) {
      final l = rnd.nextInt(5);
      if (!cars.any((c) => c.lane == l && c.depth < .24)) {
        cars.add(RoadCar(lane: l, depth: .045, color: colors[rnd.nextInt(colors.length)], speed: .82 + rnd.nextDouble() * .28));
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
    final title = gameOver ? 'انتهت اللعبة' : stopped ? 'توقف!' : 'طريق التحمل';
    final sub = gameOver ? 'النقاط: $score' : stopped ? 'تبقى لديك $lives أرواح — تابع من نفس الجولة' : 'الرؤية تختلف حسب الجو. الهدف: $target سيارة';
    return Scaffold(
      appBar: AppBar(title: const Text('طريق التحمل V4.4')),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text('النقاط: $score', style: const TextStyle(fontWeight: FontWeight.w900)), Text('اليوم: $day'), Text('الأرواح: $lives'), Text('تجاوز: $passed / $target')]),
          const SizedBox(height: 7),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (passed / target).clamp(0, 1).toDouble(), minHeight: 10, backgroundColor: Colors.white12)),
        ])),
        Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 12), clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)), child: Stack(children: [
          CustomPaint(painter: RoadPainter(playerLane: lane, cars: cars, weather: weather, tick: tick), child: const SizedBox.expand()),
          Positioned(top: 10, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(.35), borderRadius: BorderRadius.circular(14)), child: Text(weather, style: const TextStyle(fontWeight: FontWeight.bold)))),
          if (overlay) Center(child: StartCard(title: title, subtitle: sub, buttonText: stopped ? 'تابع' : 'ابدأ', onTap: stopped ? resume : start)),
        ]))),
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 12), child: Row(textDirection: TextDirection.ltr, children: [Expanded(child: RetroButton(text: 'يسار', icon: Icons.arrow_back, onTap: left)), const SizedBox(width: 12), Expanded(child: RetroButton(text: 'يمين', icon: Icons.arrow_forward, onTap: right))])),
      ])),
    );
  }
}

class RetroButton extends StatelessWidget {
  const RetroButton({super.key, required this.text, required this.icon, required this.onTap});
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(onPressed: onTap, icon: Icon(icon), label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))));
}

class StartCard extends StatelessWidget {
  const StartCard({super.key, required this.title, required this.subtitle, required this.onTap, this.buttonText = 'ابدأ'});
  final String title, subtitle, buttonText;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.all(22), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.black.withOpacity(.72), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white24)), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 18), RetroButton(text: buttonText, icon: Icons.play_arrow, onTap: onTap)]));
}

class RoadPainter extends CustomPainter {
  RoadPainter({required this.playerLane, required this.cars, required this.weather, required this.tick});
  final int playerLane, tick;
  final List<RoadCar> cars;
  final String weather;

  double ease(double d) => math.pow(d.clamp(0, 1), 1.12).toDouble();
  double yOf(Size s, double d) => s.height * (.40 + .61 * ease(d));
  double roadW(Size s, double d) => s.width * (.16 + .84 * ease(d));
  double laneX(Size s, int lane, double d) {
    final rw = roadW(s, d);
    final left = s.width * .5 - rw / 2;
    return left + rw * ((lane + .5) / 5);
  }

  double vis(double d) {
    if (weather == 'نهار') return 1;
    if (weather == 'غروب') return (1 - d * .20).clamp(.65, 1).toDouble();
    if (weather == 'ليل') return (.18 + d * .82).clamp(.20, 1).toDouble();
    if (weather == 'ضباب') return (.08 + d * .92).clamp(.10, 1).toDouble();
    if (weather == 'مطر') return (.32 + d * .68).clamp(.32, 1).toDouble();
    if (weather == 'ثلج') return (.38 + d * .62).clamp(.38, 1).toDouble();
    return 1;
  }

  @override
  void paint(Canvas c, Size s) {
    sky(c, s);
    horizon(c, s);
    road(c, s);
    shoulders(c, s);
    lines(c, s);
    posts(c, s);
    final sorted = List<RoadCar>.from(cars)..sort((a, b) => a.depth.compareTo(b.depth));
    for (final car in sorted) {
      drawOpponent(c, s, car);
    }
    headlights(c, s);
    drawPlayer(c, s);
    weatherMask(c, s);
    scan(c, s);
  }

  void sky(Canvas c, Size s) {
    late final List<Color> colors;
    switch (weather) {
      case 'غروب':
        colors = const [Color(0xff35104f), Color(0xffe11d48), Color(0xfff59e0b)];
        break;
      case 'ليل':
        colors = const [Color(0xff020617), Color(0xff0f172a), Color(0xff1e293b)];
        break;
      case 'ضباب':
        colors = const [Color(0xff64748b), Color(0xffa8b3c4), Color(0xffdbe2eb)];
        break;
      case 'ثلج':
        colors = const [Color(0xff93c5fd), Color(0xffdbeafe), Color(0xffffffff)];
        break;
      case 'مطر':
        colors = const [Color(0xff0f172a), Color(0xff334155), Color(0xff475569)];
        break;
      default:
        colors = const [Color(0xff0ea5e9), Color(0xff67e8f9), Color(0xff86efac)];
    }
    c.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(Offset.zero & s));
    if (weather == 'ليل') {
      c.drawCircle(Offset(s.width * .78, s.height * .13), 22, Paint()..color = Colors.white70);
    } else {
      c.drawCircle(Offset(s.width * .76, s.height * .17), 30, Paint()..color = const Color(0xfffff3b0));
    }
  }

  void horizon(Canvas c, Size s) {
    final p = Path()
      ..moveTo(0, s.height * .36)
      ..lineTo(s.width * .18, s.height * .25)
      ..lineTo(s.width * .35, s.height * .36)
      ..lineTo(s.width * .55, s.height * .23)
      ..lineTo(s.width * .78, s.height * .36)
      ..lineTo(s.width, s.height * .27)
      ..lineTo(s.width, s.height * .44)
      ..lineTo(0, s.height * .44)
      ..close();
    c.drawPath(p, Paint()..color = weather == 'ليل' ? const Color(0xff0b1220) : const Color(0xff2563eb).withOpacity(weather == 'ضباب' ? .10 : .22));
    final g = weather == 'ثلج' ? const Color(0xffeef2ff) : weather == 'مطر' ? const Color(0xff14532d) : weather == 'ليل' ? const Color(0xff052e16) : const Color(0xff16a34a);
    c.drawRect(Rect.fromLTWH(0, s.height * .40, s.width, s.height * .60), Paint()..color = g);
  }

  void road(Canvas c, Size s) {
    final top = s.height * .40;
    final path = Path()
      ..moveTo(s.width * .455, top)
      ..lineTo(s.width * .545, top)
      ..lineTo(s.width * .985, s.height)
      ..lineTo(s.width * .015, s.height)
      ..close();
    final colors = weather == 'ثلج'
        ? const [Color(0xff9ca3af), Color(0xff6b7280), Color(0xff374151)]
        : weather == 'مطر'
            ? const [Color(0xff1f2937), Color(0xff111827), Color(0xff020617)]
            : weather == 'ليل'
                ? const [Color(0xff111827), Color(0xff030712), Color(0xff000000)]
                : const [Color(0xff4b5563), Color(0xff1f2937), Color(0xff020617)];
    c.drawPath(path, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(Rect.fromLTWH(0, top, s.width, s.height - top)));
    c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = Colors.white.withOpacity(weather == 'ليل' ? .20 : .42));
  }

  void shoulders(Canvas c, Size s) {
    for (var i = 0; i < 16; i++) {
      final d = (((i * 64 + tick * 5) % 760) / 760).clamp(.03, .98).toDouble();
      final op = vis(d) * (weather == 'ليل' ? .55 : .85);
      final yy = yOf(s, d);
      final rw = roadW(s, d);
      final left = s.width * .5 - rw / 2;
      final right = s.width * .5 + rw / 2;
      final size = 6 + d * 18;
      final paint = Paint()..color = (i.isEven ? Colors.white : Colors.redAccent).withOpacity(op);
      c.drawRect(Rect.fromCenter(center: Offset(left - 4 * d, yy), width: size, height: 4 + d * 8), paint);
      c.drawRect(Rect.fromCenter(center: Offset(right + 4 * d, yy), width: size, height: 4 + d * 8), paint);
    }
  }

  void lines(Canvas c, Size s) {
    for (var i = 0; i < 17; i++) {
      final d = (((i * 60 + tick * 6) % 780) / 780).clamp(.025, .98).toDouble();
      final op = vis(d) * (weather == 'ليل' ? .45 : weather == 'ضباب' ? .35 : .72);
      final yy = yOf(s, d);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * .5, yy), width: 2 + d * 7, height: 12 + d * 46), const Radius.circular(4)), Paint()..color = Colors.white.withOpacity(op));
    }
  }

  void posts(Canvas c, Size s) {
    for (var i = 0; i < 10; i++) {
      final d = (((i * 83 + tick * 4) % 820) / 820).clamp(.06, .99).toDouble();
      final op = vis(d) * (weather == 'ليل' ? .48 : .82);
      final yy = yOf(s, d);
      final rw = roadW(s, d);
      final left = s.width * .5 - rw / 2 - 14 * d;
      final right = s.width * .5 + rw / 2 + 14 * d;
      final size = 3 + d * 8;
      c.drawRect(Rect.fromCenter(center: Offset(left, yy), width: size, height: size * 3.2), Paint()..color = Colors.white.withOpacity(op));
      c.drawRect(Rect.fromCenter(center: Offset(right, yy + 20 * d), width: size, height: size * 3.2), Paint()..color = Colors.white.withOpacity(op));
    }
  }

  void drawOpponent(Canvas c, Size s, RoadCar car) {
    final v = vis(car.depth);
    if (v < .13) return;
    final x = laneX(s, car.lane, car.depth);
    final yy = yOf(s, car.depth);
    final scale = .32 + car.depth * 1.32;
    if (weather == 'ليل' && car.depth < .55) {
      final p = Paint()..color = const Color(0xfffff176).withOpacity(v);
      final r = s.width * .030 * scale;
      c.drawCircle(Offset(x - r * 1.8, yy), r, p);
      c.drawCircle(Offset(x + r * 1.8, yy), r, p);
    } else {
      drawSuperCar(c, Offset(x, yy), s.width * .080 * scale, Color.lerp(const Color(0xff111827), car.color, v) ?? car.color, true, v);
    }
  }

  void headlights(Canvas c, Size s) {
    if (weather != 'ليل' && weather != 'ضباب' && weather != 'مطر') return;
    final x = laneX(s, playerLane, .88);
    final y = s.height * .84;
    final op = weather == 'ليل' ? .22 : weather == 'ضباب' ? .16 : .12;
    final p = Path()
      ..moveTo(x - 34, y - 12)
      ..lineTo(s.width * .34, s.height * .42)
      ..lineTo(s.width * .66, s.height * .42)
      ..lineTo(x + 34, y - 12)
      ..close();
    c.drawPath(p, Paint()..color = const Color(0xfffff3b0).withOpacity(op));
  }

  void drawPlayer(Canvas c, Size s) {
    drawSuperCar(c, Offset(laneX(s, playerLane, .88), s.height * .84), s.width * .140, const Color(0xff38bdf8), false, 1);
  }

  void drawSuperCar(Canvas c, Offset o, double w, Color body, bool opponent, double opacity) {
    final h = w * .72;
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, h * .20), width: w * 1.20, height: h * .70), Radius.circular(w * .30)), Paint()..color = Colors.black.withOpacity(.34 * opacity));
    final path = Path()
      ..moveTo(o.dx - w * .52, o.dy + h * .16)
      ..quadraticBezierTo(o.dx - w * .50, o.dy - h * .20, o.dx - w * .30, o.dy - h * .36)
      ..quadraticBezierTo(o.dx - w * .12, o.dy - h * .52, o.dx, o.dy - h * .54)
      ..quadraticBezierTo(o.dx + w * .12, o.dy - h * .52, o.dx + w * .30, o.dy - h * .36)
      ..quadraticBezierTo(o.dx + w * .50, o.dy - h * .20, o.dx + w * .52, o.dy + h * .16)
      ..lineTo(o.dx + w * .42, o.dy + h * .36)
      ..quadraticBezierTo(o.dx, o.dy + h * .50, o.dx - w * .42, o.dy + h * .36)
      ..close();
    c.drawPath(path, Paint()..color = body.withOpacity(opacity));
    c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(1.1, w * .040)..color = Colors.white.withOpacity(.48 * opacity));
    final hood = Path()
      ..moveTo(o.dx, o.dy - h * .48)
      ..lineTo(o.dx - w * .22, o.dy - h * .10)
      ..lineTo(o.dx + w * .22, o.dy - h * .10)
      ..close();
    c.drawPath(hood, Paint()..color = Colors.white.withOpacity(.16 * opacity));
    final cabin = RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, -h * .02), width: w * .36, height: h * .32), Radius.circular(w * .10));
    c.drawRRect(cabin, Paint()..color = const Color(0xffdbeafe).withOpacity(opacity));
    final wheel = Paint()..color = const Color(0xff020617).withOpacity(opacity);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w * .62, o.dy - h * .10, w * .17, h * .30), Radius.circular(w * .06)), wheel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx + w * .45, o.dy - h * .10, w * .17, h * .30), Radius.circular(w * .06)), wheel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w * .56, o.dy + h * .18, w * .18, h * .20), Radius.circular(w * .06)), wheel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx + w * .38, o.dy + h * .18, w * .18, h * .20), Radius.circular(w * .06)), wheel);
    final lamp = Paint()..color = (opponent ? const Color(0xfffff176) : const Color(0xffef4444)).withOpacity(opacity);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w * .37, o.dy + h * .27, w * .23, h * .075), const Radius.circular(2)), lamp);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx + w * .14, o.dy + h * .27, w * .23, h * .075), const Radius.circular(2)), lamp);
    if (!opponent) c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o.translate(0, h * .44), width: w * .42, height: h * .05), Radius.circular(w * .03)), Paint()..color = const Color(0xff0f172a).withOpacity(.80));
  }

  void weatherMask(Canvas c, Size s) {
    if (weather == 'ليل') c.drawRect(Offset.zero & s, Paint()..color = Colors.black.withOpacity(.30));
    if (weather == 'ضباب') c.drawRect(Offset.zero & s, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xB8FFFFFF), Color(0x66FFFFFF), Color(0x18FFFFFF)]).createShader(Offset.zero & s));
    if (weather == 'مطر') {
      c.drawRect(Offset.zero & s, Paint()..color = Colors.blueGrey.withOpacity(.12));
      for (var i = 0; i < 80; i++) {
        final x = ((i * 61 + tick * 2) % s.width).toDouble();
        final y = ((i * 47 + tick * 5) % s.height).toDouble();
        c.drawLine(Offset(x, y), Offset(x - 6, y + 18), Paint()..color = const Color(0xff93c5fd).withOpacity(.62)..strokeWidth = 1.4);
      }
    }
    if (weather == 'ثلج') {
      c.drawRect(Offset.zero & s, Paint()..color = Colors.white.withOpacity(.10));
      for (var i = 0; i < 70; i++) {
        final x = ((i * 67 + tick) % s.width).toDouble();
        final y = ((i * 41 + tick * 2) % s.height).toDouble();
        c.drawCircle(Offset(x, y), i.isEven ? 2.2 : 1.4, Paint()..color = Colors.white.withOpacity(.90));
      }
    }
    if (weather == 'غروب') c.drawRect(Offset.zero & s, Paint()..color = const Color(0xffff7a18).withOpacity(.08));
  }

  void scan(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..style = PaintingStyle.stroke..strokeWidth = 12..color = Colors.black.withOpacity(.20));
    final p = Paint()..color = Colors.black.withOpacity(.045);
    for (double y = 0; y < s.height; y += 5) {
      c.drawRect(Rect.fromLTWH(0, y, s.width, 1), p);
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) => true;
}
