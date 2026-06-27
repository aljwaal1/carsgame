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
              child: Stack(children: [
                CustomPaint(painter: FuelPlanePainter(planeX: engine.planeX, objects: engine.objects, bullets: engine.bullets, level: engine.level), child: const SizedBox.expand()),
                if (!engine.running)
                  Center(child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.black.withOpacity(0.62), borderRadius: BorderRadius.circular(22)), child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(engine.gameOver ? 'انتهت الجولة' : 'جاهز للطيران؟', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(engine.gameOver ? 'نقاطك: ${engine.score}' : 'اجمع الوقود وتجنب العوائق', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    RetroButton(text: engine.gameOver ? 'إعادة اللعب' : 'ابدأ', icon: Icons.play_arrow, onTap: start),
                  ]))),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: RetroButton(text: 'يمين', onTap: () => setState(engine.moveRight))),
              const SizedBox(width: 8),
              Expanded(child: RetroButton(text: 'إطلاق', icon: Icons.bolt, onTap: () { engine.fire(); FuelPlaneAudio.shoot(); setState(() {}); })),
              const SizedBox(width: 8),
              Expanded(child: RetroButton(text: 'يسار', onTap: () => setState(engine.moveLeft))),
            ]),
          ),
        ]),
      ),
    );
  }
}
