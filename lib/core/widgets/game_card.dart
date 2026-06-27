import 'package:flutter/material.dart';
import '../models/retro_game_info.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game});
  final RetroGameInfo game;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Directionality(textDirection: TextDirection.rtl, child: game.buildScreen()))),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [Color(0xff17213a), Color(0xff10243a)]),
          border: Border.all(color: Colors.white10),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: const Color(0xff0b1220), borderRadius: BorderRadius.circular(20)),
              child: Center(child: Text(game.icon, style: const TextStyle(fontSize: 34))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(game.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(game.description, style: const TextStyle(color: Colors.white70, height: 1.4)),
              ]),
            ),
            const Icon(Icons.chevron_left, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
