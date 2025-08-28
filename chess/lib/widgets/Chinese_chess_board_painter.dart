import 'package:flutter/material.dart';


class ChineseChessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double backgroundHeight = size.height * 1.0;
    final double boardWidth = size.width * 0.88; // 90% 居中
    final double boardHeight = size.height * 0.889;
    final double offsetX = (size.width - boardWidth) / 2;
    final double offsetY = (backgroundHeight - boardHeight) / 2;
    final double cellWidth = boardWidth / 8;
    final double cellHeight = boardHeight / 9;

    // 木纹背景

    final Rect rect = Rect.fromLTWH(0, 0, size.width, backgroundHeight);
    final Paint backgroundPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0), // 中心在画布中心
        radius: 0.65,
        colors: [
          const Color(0xFFF5DEB3), // 中心较亮
          const Color(0xFFD2B48C), // 四周稍暗
        ],
        stops: const [0.5, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // 棋盘边框
    final Paint borderPaint = Paint()
      ..color =
          const Color(0xFF8B4513) // 深木色
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(
      Rect.fromLTWH(offsetX, offsetY, boardWidth, boardHeight),
      borderPaint,
    );

    // 棋盘线条
    final Paint linePaint = Paint()
      ..color =
          const Color(0xFF8B4513) // 与边框一致
      ..strokeWidth = 1.5;

    // 横线
    for (int i = 0; i < 10; i++) {
      final y = offsetY + i * cellHeight;
      canvas.drawLine(
        Offset(offsetX, y),
        Offset(offsetX + boardWidth, y),
        linePaint,
      );
    }

    // 纵线
    for (int i = 0; i < 9; i++) {
      final x = offsetX + i * cellWidth;
      if (i == 0 || i == 8) {
        canvas.drawLine(
          Offset(x, offsetY),
          Offset(x, offsetY + boardHeight),
          linePaint,
        );
      } else {
        canvas.drawLine(
          Offset(x, offsetY),
          Offset(x, offsetY + 4 * cellHeight),
          linePaint,
        );
        canvas.drawLine(
          Offset(x, offsetY + 5 * cellHeight),
          Offset(x, offsetY + boardHeight),
          linePaint,
        );
      }
    }

    // 楚河汉界
    final style = TextStyle(
      color: Colors.grey[600],
      fontSize: cellHeight * 0.45,
      fontWeight: FontWeight.bold,
    );

    final chuhe = TextPainter(
      text: TextSpan(text: '楚河', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    chuhe.paint(
      canvas,
      Offset(
        cellWidth * 2.5 - chuhe.width / 2,
        5.00 * cellHeight - chuhe.height / 2,
      ),
    );

    final hanjie = TextPainter(
      text: TextSpan(text: '汉界', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    hanjie.paint(
      canvas,
      Offset(
        cellWidth * 6.5 - hanjie.width / 2,
        5.00 * cellHeight - hanjie.height / 2,
      ),
    );

    // 画米字、炮位、小十字等都要加上 offsetX 和 offsetY 来适配新坐标
    void drawPalace(double leftX, double topY) {
      final rightX = leftX + 2 * cellWidth;
      final bottomY = topY + 2 * cellHeight;
      canvas.drawLine(Offset(leftX, topY), Offset(rightX, bottomY), linePaint);
      canvas.drawLine(Offset(leftX, bottomY), Offset(rightX, topY), linePaint);
    }

    drawPalace(offsetX + 3 * cellWidth, offsetY);
    drawPalace(offsetX + 3 * cellWidth, offsetY + 7 * cellHeight);

    void drawCornerCross(double cx, double cy) {
      const double len = 5;
      final Paint dotPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(cx - len, cy - len),
        Offset(cx - len, cy - len / 2),
        dotPaint,
      );
      canvas.drawLine(
        Offset(cx - len, cy - len),
        Offset(cx - len / 2, cy - len),
        dotPaint,
      );
      canvas.drawLine(
        Offset(cx + len, cy - len),
        Offset(cx + len, cy - len / 2),
        dotPaint,
      );
      canvas.drawLine(
        Offset(cx + len, cy - len),
        Offset(cx + len / 2, cy - len),
        dotPaint,
      );
      canvas.drawLine(
        Offset(cx - len, cy + len),
        Offset(cx - len, cy + len / 2),
        dotPaint,
      );
      canvas.drawLine(
        Offset(cx - len, cy + len),
        Offset(cx - len / 2, cy + len),
        dotPaint,
      );
      canvas.drawLine(
        Offset(cx + len, cy + len),
        Offset(cx + len, cy + len / 2),
        dotPaint,
      );
      canvas.drawLine(
        Offset(cx + len, cy + len),
        Offset(cx + len / 2, cy + len),
        dotPaint,
      );
    }

    for (var col in [1, 7]) {
      for (var row in [2, 7]) {
        drawCornerCross(offsetX + col * cellWidth, offsetY + row * cellHeight);
      }
    }

    for (var col in [0, 2, 4, 6, 8]) {
      drawCornerCross(offsetX + col * cellWidth, offsetY + 3 * cellHeight);
      drawCornerCross(offsetX + col * cellWidth, offsetY + 6 * cellHeight);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
