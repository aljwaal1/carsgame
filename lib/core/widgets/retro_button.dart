import 'package:flutter/material.dart';

class RetroButton extends StatelessWidget {
  const RetroButton({super.key, required this.text, required this.onTap, this.icon});
  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
