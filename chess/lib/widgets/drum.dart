import 'package:flutter/material.dart';
import 'dart:math' as math;

class DrumAnimation extends StatefulWidget {
  const DrumAnimation({Key? key}) : super(key: key);

  @override
  State<DrumAnimation> createState() => _DrumAnimationState();
}

class _DrumAnimationState extends State<DrumAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: DrumPainter(animationValue: _controller.value),
        );
      },
    );
  }
}

class DrumPainter extends CustomPainter {
  final double animationValue;
  DrumPainter({required this.animationValue});

  @override
    @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final drumRadius = size.width / 2.5;

    // ===== 鼓身渐变 =====
    final drumBodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.red.shade900, Colors.red.shade600],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: drumRadius + 10));
    canvas.drawCircle(center, drumRadius + 10, drumBodyPaint);

    // ===== 鼓皮渐变 =====
    final drumSkinPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color.fromARGB(255, 242, 241, 209), const Color(0xFFFFF8E1)],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: drumRadius));
    canvas.drawCircle(center, drumRadius, drumSkinPaint);

    // ===== 鼓皮高光 =====
    // final highlightPaint = Paint()
    //   ..shader = RadialGradient(
    //     colors: [Colors.white.withOpacity(0.6), Colors.transparent],
    //     stops: const [0.0, 1.0],
    //   ).createShader(Rect.fromCircle(
    //     center: center.translate(-drumRadius * 0.3, -drumRadius * 0.3),
    //     radius: drumRadius * 1.0,
    //   ));
    // canvas.drawCircle(
    //     center.translate(-drumRadius * 0.3, -drumRadius * 0.3), drumRadius * 0.6, highlightPaint);

    // ===== 鼓边描边 =====
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.brown[800]!;
    canvas.drawCircle(center, drumRadius, edgePaint);

    // ===== 水波纹效果 =====
    // _drawRipples(canvas, center, drumRadius);

    // ===== 棒槌 =====
    _drawStick(canvas, center, drumRadius, _getAngle(animationValue, true), true);
    _drawStick(canvas, center, drumRadius, _getAngle(animationValue, false), false);
  }

  void _drawRipples(Canvas canvas, Offset center, double drumRadius) {
    // 这里的 progress 会让波纹循环
    double progress = (animationValue * 2) % 1.0;

    for (int i = 0; i < 3; i++) {
      double rippleProgress = (progress - i * 0.25);
      if (rippleProgress < 0) continue;

      double radius = drumRadius * rippleProgress;
      double opacity = (1 - rippleProgress).clamp(0.0, 1.0);

      final ripplePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color.fromARGB(255, 218, 215, 215).withOpacity(opacity * 0.4);

      canvas.drawCircle(center, radius, ripplePaint);
    }
  }

  double _getAngle(double progress, bool isLeft) {
    // 每根棒槌相差半周期
    double offset = isLeft ? 0.0 : 0.5;
    double t = (progress + offset) % 1.0;

    // 更自然的敲击感：落下快，抬起慢
    double eased = t < 0.5
        ? math.pow(t * 2, 1.5).toDouble()
        : 1 - math.pow((t - 0.5) * 2, 1.5).toDouble();
    return eased;
  }

  void _drawStick(
    Canvas canvas,
    Offset center,
    double drumRadius,
    double t,
    bool isLeft,
  ) {
    final stickLengthUp = drumRadius * 0.8;
    final stickLengthDown = drumRadius * 0.4;
    final stickPaint = Paint()
      ..color = Colors.brown[400]!
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    double angleUp = isLeft ? math.pi / 3.5 : -math.pi / 3.5;
    double angleDown = isLeft ? math.pi / 2.1 : -math.pi / 2.1;
    double angle = lerpDouble(angleUp, angleDown, t)!;

    // 支点稍微往下
    double pivotX = center.dx + (isLeft ? -drumRadius + 15 : drumRadius - 15);
    double pivotY = center.dy + drumRadius / 5;

    canvas.save();
    canvas.translate(pivotX, pivotY);
    canvas.rotate(angle);

    // 棒身
    canvas.drawLine(Offset(0, 0), Offset(0, stickLengthUp), stickPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, -stickLengthDown), stickPaint);

    // 槌头（带高光）
    final headPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.red.shade300, Colors.red.shade800],
          ).createShader(
            Rect.fromCircle(center: Offset(0, -stickLengthDown), radius: 12),
          );
    canvas.drawCircle(Offset(0, -stickLengthDown), 12, headPaint);

    canvas.restore();
  }

  
  double? lerpDouble(num a, num b, double t) => a * (1.0 - t) + b * t;

  @override
  bool shouldRepaint(covariant DrumPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
