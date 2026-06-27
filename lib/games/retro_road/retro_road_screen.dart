import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/storage/score_storage.dart';
import '../../core/widgets/retro_button.dart';
import 'retro_road_audio.dart';
import 'retro_road_config.dart';
import 'retro_road_engine.dart';
import 'retro_road_info.dart';
import 'retro_road_painter.dart';
import 'retro_road_weather.dart';

class RetroRoadScreen extends StatefulWidget {
  const RetroRoadScreen({super.key});

  @override
  State<RetroRoadScreen> createState() => _RetroRoadScreenState();
}

class _RetroRoadScreenState extends State<RetroRoadScreen> {
  final engine = RetroRoadEngine();
  final info = RetroRoadGameInfo();
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
      if (event == RoadEvent.passed) RetroRoadAudio.pass();
      if (event == RoadEvent.weatherChanged) RetroRoadAudio.weather();
      if (event == RoadEvent.dayClear) RetroRoadAudio.clear();
      if (event == RoadEvent.crash) {
        RetroRoadAudio.crash();
        await ScoreStorage.saveBestScore(info.bestScoreKey, engine.score);
        best = await ScoreStorage.getBestScore(info.bestScoreKey);
      }
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final progress = engine.passed / RetroRoadConfig.carsPerDay;
    return Scaffold(
      appBar: AppBar(title: const Text('طريق التحمل'), centerTitle: true),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Text('النقاط: ${engine.score}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('اليوم: ${engine.day}'),
                Text('الأفضل: $best'),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 12, backgroundColor: Colors.white12))),
                const SizedBox(width: 10),
                Text(engine.weather.label),
              ]),
            ]),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white10)),
              clipBehavior: Clip.antiAlias,
              child: Stack(children: [
                CustomPaint(painter: RetroRoadPainter(playerX: engine.playerX, cars: engine.cars, weather: engine.weather, day: engine.day, score: engine.score), child: const SizedBox.expand()),
                if (!engine.running)
                  Center(child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.black.withOpacity(0.62), borderRadius: BorderRadius.circular(22)), child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(engine.gameOver ? 'انتهى السباق' : 'جاهز للطريق؟', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(engine.gameOver ? 'نقاطك: ${engine.score}' : 'تجاوز السيارات قبل نهاية اليوم', style: const TextStyle(color: Colors.white70)),
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
              Expanded(child: RetroButton(text: 'يسار', onTap: () => setState(engine.moveLeft))),
            ]),
          ),
        ]),
      ),
    );
  }
}
