import 'package:flutter/material.dart';



/// 在棋盘中间弹出“将军”提示的组件
class CheckAlertOverlay extends StatefulWidget {
  /// 当 isInCheckNotifier 从 false -> true 时会自动触发一次动画
  final ValueNotifier<bool>? isInCheckNotifier;

  /// 动画持续总时长（默认 1.5s）
  final Duration duration;

  /// 文本内容，默认 "将军"
  final String text;

  const CheckAlertOverlay({
    Key? key,
    this.isInCheckNotifier,
    this.duration = const Duration(milliseconds: 1500),
    this.text = '将军',
  }) : super(key: key);

  @override
  State<CheckAlertOverlay> createState() => _CheckAlertOverlayState();
}

class _CheckAlertOverlayState extends State<CheckAlertOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  ValueNotifier<bool>? _notifier;

  @override
  void initState() {
    super.initState();

    // 总时长：我们把动画分成出现(0~0.25)、停留(0.25~0.75)、消失(0.75~1.0)
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85).chain(CurveTween(curve: Curves.easeIn)), weight: 25),
    ]).animate(_ctrl);

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 25),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 25),
    ]).animate(_ctrl);

    // 如果传了 notifier，就监听它
    _notifier = widget.isInCheckNotifier;
    _notifier?.addListener(_onNotifierChange);

  }

  void _onNotifierChange() {
    if (_notifier == null) return;
    // 仅在从 false -> true 时触发一次动画
    if (_notifier!.value == true) {
      _play();
    }
  }

  void _play() {
    // restart animation
    _ctrl.stop();
    _ctrl.reset();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onNotifierChange);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 完全占满父视图并居中显示（通常把它放在棋盘的 Stack 里）
    return IgnorePointer(
      ignoring: true, // 覆盖层不阻断触摸
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          // 当接近 0 且未播放时，完全透明且不绘制（可优化性能）
          if (_ctrl.status == AnimationStatus.dismissed && _ctrl.value == 0) {
            return const SizedBox.shrink();
          }
          return Opacity(
            opacity: _opacityAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          );
        },
        child: _ArtfulText(
          text: widget.text,
        ),
      ),
    );
  }

}

/// 真正绘制“将军”富装饰文字的 Widget（描边 + 渐变 + 投影 + 模糊边缘）
class _ArtfulText extends StatelessWidget {
  final String text;
  const _ArtfulText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用 CustomPaint + TextPainter 绘制：先描边再填充（填充使用线性渐变的 shader）
    return Center(
      child: CustomPaint(
        painter: _ArtTextPainter(text),
        // 给个足够大的区域，保证在各种棋盘大小下不被裁剪
        size: Size(200, 120),
      ),
    );
  }
}

class _ArtTextPainter extends CustomPainter {
  final String text;
  _ArtTextPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    // 文本样式参数（可按需微调）
    final fontSize = size.height * 0.6; // 调整 "将军" 大小
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        // 填充在后面用 shader 实现，所以这里给白色占位（不会被直接绘制）
        color: Colors.white,
      ),
    );

    // 用 TextPainter 测量并定位到中心
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final Offset center = Offset(size.width / 2, size.height / 2);
    final Offset textTopLeft = center - Offset(tp.width / 2, tp.height / 2);

    // 1) 先绘制模糊阴影（更有杀气的外发光 / 烟雾效果）
    final shadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = Colors.deepOrange.withOpacity(0.25);
    // 用 drawParagraph 做阴影：将文本绘制到一个 Picture，然后以偏移绘制 —— 更简单的方法是直接用 TextPainter.paint 多次偏移来模拟阴影
    tp.paint(canvas, textTopLeft.translate(0, 6)); // 偏下的暗影
    // 叠加一个模糊的橙色光晕
    canvas.saveLayer(Offset.zero & size, Paint());
    tp.paint(canvas, textTopLeft.translate(0, 3));
    canvas.drawRect(Offset.zero & size, shadowPaint);
    canvas.restore();

    // 2) 描边（stroke）
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = fontSize * 0.14 // 描边粗细随字体大小缩放
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black.withOpacity(0.95);

    // 使用 TextPainter 先生成用于 stroked text 的 paragraph
    // Flutter 的 TextPainter 无法直接设置 stroke paint；但可以通过 TextStyle.foreground 来绘制一次 stroke，再绘制 fill
    final strokeText = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        foreground: strokePaint,
        letterSpacing: 2,
      ),
    );
    final tpStroke = TextPainter(
      text: strokeText,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    final strokeTopLeft = center - Offset(tpStroke.width / 2, tpStroke.height / 2);
    tpStroke.paint(canvas, strokeTopLeft);

    // 3) 填充（带渐变）
    // 创建线性渐变 shader（从上到下：亮到暗），你也可以用 RadialGradient
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.yellow.shade300,
        Colors.orange.shade800,
        Colors.deepOrange.shade900,
      ],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromLTWH(strokeTopLeft.dx, strokeTopLeft.dy, tpStroke.width, tpStroke.height));

    final fillPaint = Paint()..shader = shader;

    final fillText = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        foreground: fillPaint,
        letterSpacing: 2,
        shadows: [
          // 额外高光（让文字上端更亮）
          Shadow(
            offset: const Offset(0, -2),
            blurRadius: 6,
            color: Colors.white.withOpacity(0.6),
          ),
          // 微弱的内光提升质感
          Shadow(
            offset: const Offset(0, 1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.25),
          ),
        ],
      ),
    );

    final tpFill = TextPainter(
      text: fillText,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    final fillTopLeft = center - Offset(tpFill.width / 2, tpFill.height / 2);

    tpFill.paint(canvas, fillTopLeft);

    // 4) 额外：在文字周围绘制一圈淡红色的外光，增加“杀气”
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = Colors.redAccent.withOpacity(0.12);
    canvas.drawCircle(center, tpFill.width * 0.8, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
