import 'package:flutter/material.dart';

Widget chatPhraseChip(String text, VoidCallback onTap) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.brown[800], fontSize: 14),
      ),
    ),
  );
}
