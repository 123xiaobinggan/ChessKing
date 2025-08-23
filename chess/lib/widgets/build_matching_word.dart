import 'package:flutter/material.dart';

class MatchingText extends StatefulWidget {
  const MatchingText({Key? key}) : super(key: key);

  @override
  State<MatchingText> createState() => _MatchingTextState();
}

class _MatchingTextState extends State<MatchingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 匹配中文字 + 渐变
        const SizedBox(width: 25),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.orange.shade400, Colors.red.shade600],
          ).createShader(bounds),
          child: const Text(
            "匹配中",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black38,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),

        // 固定宽度的点动画
        SizedBox(
          width: 30, // 能容纳三个点的宽度
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              int dotCount = ((_controller.value * 3)).floor() + 1;
              String dots = '.' * dotCount;
              return ShaderMask(
                // 定义渐变着色器
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.orange.shade400, Colors.red.shade600],
                ).createShader(bounds),
                // 确保文本颜色为白色，这样渐变效果才能正常显示
                child: Text(
                  dots,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
