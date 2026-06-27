import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/storage/score_storage.dart';
import '../../core/widgets/retro_button.dart';
import 'fuel_plane_audio.dart';
import 'fuel_plane_engine.dart';
import 'fuel_plane_info.dart';
import 'fuel_plane_painter.dart';

class FuelPlaneScreen extends StatefulWidget {
  const FuelPlaneScreen({super.key});

  @override
  State<FuelPlaneScreen> createState() => _FuelPlaneScreenState();
}

class _FuelPlaneScreenState extends State<FuelPlaneScreen> {
  final engine = FuelPlaneEngine();
  final info = FuelPlaneGameInfo();
  Timer? timer;
  int best = 0;

  @override
  void initState() {
    super.initState();
    ScoreStorage.getBestScore(info.bestScoreKey).then((v) => mounted ? setState(() => best = v) : null);
  }

  void start() {
    engine.reset();
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 30), (_) async {
      final event = engine.tick();
      if (event == PlaneEvent.shoot && engine.score % 3 == 0) FuelPlaneAudio.shoot();
      if (event == PlaneEvent.fuel) FuelPlaneAudio.fuel();
      if (event == PlaneEvent.hit) FuelPlaneAudio.explosion();
      if (event == PlaneEvent.dead) {
        FuelPlaneAudio.gameOver();
        await ScoreStorage.saveBestScore(info.bestScoreKey, engine.score);
        best = await ScoreStorage.getBestScore(info.bestScoreKey);
      }
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  void _dragPlane(DragUpdateDetails details, double width) {
    engine.dragTo(details.localPosition.dx, width);
    setState(() {});
  }

  void _touchPlane(DragDownDetails details, double width) {
    engine.dragTo(details.localPosition.dx, width);
    setState(() {});
  }

  void _setSlider(double value) {
    if (!engine.running) return;
    engine.planeX = value.clamp(0.08, 0.92).toDouble();
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fuelColor = engine.fuel > 50 ? Colors.greenAccent : engine.fuel > 25 ? Colors.orangeAccent : Colors.redAccent;
    return Scaffold(
      appBar: AppBar(title: const Text('طائرة الوقود'), centerTitle: true),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Text('النقاط: ${engine.score}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('المرحلة: ${engine.level}'),
                Text('الأفضل: $best'),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (engine.fuel.clamp(0, 100)) / 100, minHeight: 12, valueColor: AlwaysStoppedAnimation(fuelColor), backgroundColor: Colors.white12)),
            ]),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white10)),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (d) => _touchPlane(d, constraints.maxWidth),
                  onPanUpdate: (d) => _dragPlane(d, constraints.maxWidth),
                  child: Stack(children: [
                    CustomPaint(painter: FuelPlanePainter(planeX: engine.planeX, objects: engine.objects, bullets: engine.bullets, level: engine.level), child: const SizedBox.expand()),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: engine.running ? 0.55 : 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.34), borderRadius: BorderRadius.circular(16)),
                            child: const Text('اسحب الطائرة أو استخدم شريط التحكم بالأسفل — الإطلاق تلقائي', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    if (!engine.running)
                      Center(child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.black.withOpacity(0.62), borderRadius: BorderRadius.circular(22)), child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(engine.gameOver ? 'انتهت الجولة' : 'جاهز للطيران؟', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text(engine.gameOver ? 'نقاطك: ${engine.score}' : 'حرّك الشريط بالأسفل، والنار تعمل تلقائيًا', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        RetroButton(text: engine.gameOver ? 'إعادة اللعب' : 'ابدأ', icon: Icons.play_arrow, onTap: start),
                      ]))),
                  ]),
                );
              }),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.24),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.mouse, size: 20, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    engine.running ? 'حرّك المقبض مثل الماوس' : 'اضغط ابدأ ثم استخدم شريط التحكم',
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 12,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 18),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 26),
                  activeTrackColor: Colors.lightBlueAccent,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  overlayColor: Colors.lightBlueAccent.withOpacity(0.18),
                ),
                child: Slider(
                  value: engine.planeX.clamp(0.08, 0.92),
                  min: 0.08,
                  max: 0.92,
                  onChanged: engine.running ? _setSlider : null,
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
