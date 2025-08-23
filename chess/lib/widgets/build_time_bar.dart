import 'package:flutter/material.dart';

Widget buildTimerBar({required int totalTime, required int stepTime}) {
  String formatTime(int seconds) {
    // print('$seconds');
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFF5DEB3), Colors.transparent],
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.hourglass_bottom, color: Colors.white, size: 20),
        const SizedBox(width: 4),
        Text(
          formatTime(totalTime),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 20, color: Colors.white30),
        const SizedBox(width: 8),
        Text(
          formatTime(stepTime),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    ),
  );
}
