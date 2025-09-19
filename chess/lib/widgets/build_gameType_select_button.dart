import 'package:flutter/material.dart';

class GameTypeSelectButton extends StatelessWidget {
  final String gameType;
  final Function() onPressed;

  const GameTypeSelectButton({
    super.key,
    required this.gameType,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          onPressed();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF8E1), // 浅米黄色
                Color(0xFFFFE57F), // 稍深米黄色
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                offset: Offset(-3, -3),
                blurRadius: 6,
              ),
              BoxShadow(
                color: Colors.brown.withOpacity(0.15),
                offset: Offset(3, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gameType,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown[800],
                  decoration: TextDecoration.none,
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
