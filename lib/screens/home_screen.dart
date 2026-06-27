import 'package:flutter/material.dart';
import '../core/audio/audio_manager.dart';
import '../core/game_registry.dart';
import '../core/widgets/game_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool soundOn = AudioManager.instance.enabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ألعاب زمان', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('طائرة وسيارات بروح أتاري قديمة — كود مقسّم وقابل للإضافة', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      setState(() {
                        AudioManager.instance.toggle();
                        soundOn = AudioManager.instance.enabled;
                      });
                    },
                    icon: Icon(soundOn ? Icons.volume_up : Icons.volume_off),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (final game in retroGames) GameCard(game: game),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(18)),
                      child: const Text(
                        'ملاحظة: هذه ألعاب أصلية مستوحاة من روح الألعاب القديمة وليست نسخًا حرفية من ألعاب محمية. يمكن إضافة ألعاب جديدة لاحقًا من خلال game_registry فقط.',
                        style: TextStyle(color: Colors.white60, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
