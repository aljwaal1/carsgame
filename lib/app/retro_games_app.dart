import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import 'app_theme.dart';

class RetroGamesApp extends StatelessWidget {
  const RetroGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألعاب زمان',
      theme: AppTheme.dark(),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}
