import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static AudioPlayer? audioPlayer;
  static String movePieceChineseChessSoundPath = 'Sound/movePiece.wav';
  static String gameOverChineseChessSoundPath = 'Sound/gameOver.wav';

  static Future<void> init() async {
    try {
      audioPlayer = AudioPlayer();
    } catch (e) {
      if (kDebugMode) {
        print('AudioPlayer initialization failed: $e');
      }
      audioPlayer = null;
    }
  }

  static Future<void> movePieceChineseChessPieceSound() async {
    if (audioPlayer == null) return;
    try {
      await audioPlayer!.play(AssetSource(movePieceChineseChessSoundPath));
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play move sound: $e');
      }
    }
  }

  static Future<void> gameOverChineseChessSound() async {
    if (audioPlayer == null) return;
    try {
      await audioPlayer!.play(AssetSource(gameOverChineseChessSoundPath));
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play game over sound: $e');
      }
    }
  }
}