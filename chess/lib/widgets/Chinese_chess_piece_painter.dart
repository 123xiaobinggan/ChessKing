import 'package:flutter/material.dart';

// 棋子模型
class ChineseChessPieceModel {
  String type; // 如：'车'、'马'、'兵'、'帅'
  bool isRed; // 是否为红方
  Point pos;

  ChineseChessPieceModel({
    required this.type,
    required this.isRed,
    required this.pos,
  });
}

// 棋盘坐标
class Point {
  int row;
  int col;
  Point({required this.row, required this.col});
}

class Step {
  ChineseChessPieceModel piece;
  Point newPos;
  Step({required this.piece, required this.newPos});
}

// ignore: must_be_immutable
class ChineseChessPiece extends StatefulWidget {
  final String type; // 如：'车'、'马'、'兵'、'帅'
  final bool isRed; // 是否为红方
  int row; // 行（0~9）
  int col; // 列（0~8）
  bool isSelected; // 是否选中
  bool isPlaced; // 是否结束放置
  double size; // 棋子大小
  VoidCallback? onTap; // 点击事件

  ChineseChessPiece({
    super.key,
    required this.type,
    required this.isRed,
    required this.row,
    required this.col,
    this.isSelected = false,
    this.isPlaced = false,
    this.size = 40,
    this.onTap,
  });

  @override
  State<ChineseChessPiece> createState() => _ChineseChessPieceState();
}

class _ChineseChessPieceState extends State<ChineseChessPiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _liftAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 8.0, // 浮起最大高度
    );

    _liftAnimation = _controller.drive(Tween(begin: 0.0, end: 0.02));

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ChineseChessPiece oldWidget) {
    super.didUpdateWidget(oldWidget);
    // print('didUpdateWidget');
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _liftAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + _liftAnimation.value, // scale 为 1 ~ 1.05
            child: child,
          );
        },
        child: Container(
          decoration: widget.isPlaced || widget.isSelected
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                )
              : null,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: ChineseChessPiecePainter(widget.type, widget.isRed),
          ),
        ),
      ),
    );
  }
}

class ChineseChessPiecePainter extends CustomPainter {
  final String type; // 棋子文字
  final bool isRed; // 是否为红方

  ChineseChessPiecePainter(this.type, this.isRed);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2); // 棋子中心
    final double radius = size.width*0.95 / 2; // 棋子半径
    // 阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center.translate(4, 4), radius, shadowPaint); // 右下角阴影

    // 棋子背景（木质渐变）
    final woodPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3), // 偏左上光源
        radius: 0.9,
        colors: [
          const Color(0xFFF5DEB3), // 浅木色
          const Color(0xFFD2B48C), // 深木色
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, woodPaint);

    // 雕刻外圈
    final ringPaint = Paint()
      ..color = isRed ? Colors.red.shade800 : Colors.green.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 3, ringPaint);

    // 雕刻字（正楷 + 内阴影模拟）
    final textStyle = TextStyle(
      fontFamilyFallback: ['KaiTi', 'STKaiti', 'serif'],
      fontSize: radius * 1.2,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      shadows: const [
        Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26),
        Shadow(offset: Offset(-1, -1), blurRadius: 2, color: Colors.white70),
      ],
    );

    final tp = TextPainter(
      text: TextSpan(text: type, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 每次重绘
  }
}
