import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final bool isMyself;

  const SpeechBubble({super.key, required this.text, required this.isMyself});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(isMyself: isMyself),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: IntrinsicWidth(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
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

    final path = Path();

    const radius = 15.0;
    final rectHeight = size.height - 10;

    // 画圆角矩形主体
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, (size.height-rectHeight)/2, size.width, rectHeight),
        const Radius.circular(radius),
      ),
    );

    // 添加尖角路径
    if (!isMyself) {
      // 左上角尖角
      path.moveTo(10, 10);
      path.lineTo(10, -5); // 尖角顶点
      path.lineTo(30, 10);
    } else {
      // 右下角尖角
      path.moveTo(size.width - 10, rectHeight);
      path.lineTo(size.width - 10, size.height+5); // 尖角顶点
      path.lineTo(size.width - 30, rectHeight);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
