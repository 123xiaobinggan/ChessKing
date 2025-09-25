import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final bool isMyself;

  const SpeechBubble({super.key, required this.text, required this.isMyself});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(isMyself: isMyself),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(minWidth: 50, maxWidth: 250),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final bool isMyself;

  BubblePainter({required this.isMyself});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF5DEB3), Color(0xFFEED7A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    const radius = 15.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);

    if (!isMyself) {
      // 左边小三角
      path.moveTo(10, 10);
      path.lineTo(10, -10);
      path.lineTo(30, 10);
    } else {
      // 右边小三角
      path.moveTo(size.width - 10, 40);
      path.lineTo(size.width - 8, 50);
      path.lineTo(size.width - 30, 40);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
