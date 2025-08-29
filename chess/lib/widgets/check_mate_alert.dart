import 'package:flutter/material.dart';
import 'dart:math';

class CheckmateAlert extends StatefulWidget {
  final ValueNotifier<bool> isInCheckMateNotifier;
  final void Function() onClose;
  const CheckmateAlert({super.key, required this.isInCheckMateNotifier, required this. onClose});

  @override
  State<CheckmateAlert> createState() => _CheckmateAlertState();
}

class _CheckmateAlertState extends State<CheckmateAlert>
    with TickerProviderStateMixin {
  late AnimationController _juController;
  late AnimationController _shaController;
  late AnimationController _swordController;
  late AnimationController _fadeOutController;
  late AnimationController _circleController;

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400), // 圆圈绘制时间
    );

    _juController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _shaController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _swordController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _fadeOutController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    widget.isInCheckMateNotifier.addListener(() {
      if (widget.isInCheckMateNotifier.value) {
        _startAnimation();
      }
    });
  }

  void _startAnimation() async {
    _fadeOutController.value = 0;
    _juController.forward();
    _circleController.forward();
    await Future.delayed(Duration(milliseconds: 500));
    _shaController.forward();
    await Future.delayed(Duration(milliseconds: 500));
    _swordController.forward();

    await Future.delayed(Duration(milliseconds: 1000));
    _fadeOutController.forward();
    await Future.delayed(Duration(milliseconds: 300));
    widget.isInCheckMateNotifier.value = false;
    _reset();
    widget.onClose();
  }

  void _reset() {
    _circleController.reset();
    _juController.reset();
    _shaController.reset();
    _swordController.reset();
    _fadeOutController.reset();
  }

  @override
  void dispose() {
    _juController.dispose();
    _shaController.dispose();
    _swordController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isInCheckMateNotifier,
      builder: (context, show, _) {
        if (!show) return SizedBox.shrink();

        return FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.0).animate(_fadeOutController),
          child: Stack(
            children: [
              Center(
                child:
                    // 背景毛笔圈
                    AnimatedBuilder(
                      animation: _circleController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(160, 160),
                          painter: AnimatedRedCirclePainter(
                            _circleController.value,
                          ),
                        );
                      },
                    ),
              ),

              // 剑动画
              Align(
                alignment: Alignment(0, -1.8), // 0 水平居中，-1.5 上方偏移
                child: AnimatedBuilder(
                  animation: _swordController,
                  builder: (context, _) {
                    
                    final curvedAnim = CurvedAnimation(
                      parent: _swordController,
                      curve: Curves.easeInBack,
                    );

                    // 计算偏移量，t 从 0 ~ 1，插入方向竖直向下（y 轴正方向）
                    double t = curvedAnim.value;
                    double offsetY = 110 * t; // 从0到120向下
                    return Transform.translate(
                      offset: Offset(0, offsetY),
                      child: Image.asset(
                        'assets/Check_mate/sword.png',
                        width: 250,
                        // height: 200
                      ),
                    );
                  },
                ),
              ),

              // 绝杀文字动画
              Positioned(
                left: 105,
                top: 105,
                child: FadeTransition(
                  opacity: _juController,
                  child: GradientText(
                    '绝',
                    gradient: LinearGradient(
                      colors: [Color(0xFFF5E6B3), Colors.white],
                    ),
                    style: TextStyle(
                      fontSize: 90,
                      fontFamily: 'KaiTi',
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(3, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 杀字
              Positioned(
                right: 100,
                bottom: 100,
                child: FadeTransition(
                  opacity: _shaController,
                  child: GradientText(
                    '杀',
                    gradient: LinearGradient(
                      colors: [Color(0xFFF5E6B3), Colors.white],
                    ),
                    style: TextStyle(
                      fontSize: 90,
                      fontFamily: 'KaiTi',
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(3, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 毛笔风格红圈
class AnimatedRedCirclePainter extends CustomPainter {
  final double progress; // 0.0 ~ 1.0

  AnimatedRedCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 24.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // 圆圈渐变笔刷
    final gradient = SweepGradient(
      startAngle: -pi / 4, // 从左上角 45° 开始
      endAngle: -pi / 4 + 2 * pi,
      colors: [Colors.red.shade900, Colors.red, Colors.red.shade700],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // 圆滑的线帽

    // 从 -45°（左上角）开始画 progress * 360°
    double startAngle = -pi / 4;
    double sweepAngle = 2 * pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedRedCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 渐变文字
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    required this.gradient,
    required this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          gradient.createShader(Offset.zero & bounds.size),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}
