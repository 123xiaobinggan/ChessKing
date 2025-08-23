import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedAvatar extends StatefulWidget {
  final String imagePath;
  final RxBool isMyTurn;
  final bool isRed;

  const AnimatedAvatar({
    super.key,
    required this.imagePath,
    required this.isMyTurn,
    required this.isRed,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // 初始状态
    if (widget.isMyTurn.value) {
      _controller.repeat();
    }

    // 监听 RxBool
    widget.isMyTurn.listen((value) {
      if (value) {
        _controller.repeat();
        print('动画开始');
      } else {
        _controller.stop();
        print('动画停止');
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 状态变化时控制动画开关
    if (widget.isMyTurn.value && !_controller.isAnimating) {
      _controller.repeat();
      print('动画开始');
    } else if (!widget.isMyTurn.value && _controller.isAnimating) {
      _controller.stop();
      print('动画停止');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 30;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * 3.1415926;

        return Container(
          width: radius * 2 + 6,
          height: radius * 2 + 6,
          alignment: Alignment.center,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return SweepGradient(
                startAngle: 0,
                endAngle: 2 * 3.1415926,
                colors: [
                  widget.isMyTurn.value
                      ? Colors.greenAccent
                      : Colors.transparent,
                  Colors.transparent,
                ],
                stops: [0.0, 1.0],
                transform: GradientRotation(angle),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isRed ? Colors.redAccent : Colors.blueAccent,
                  width: 3,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                radius: radius,
                backgroundImage: Image.network(widget.imagePath).image,
              ),
            ),
          ),
        );
      },
    );
  }
}
