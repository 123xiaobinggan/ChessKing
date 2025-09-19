import 'package:flutter/material.dart';
import 'build_player_avatar.dart';
import 'package:get/get.dart';
import '/global/global_data.dart';

class GameResultOverlay extends StatelessWidget {
  final String result; // "胜利" / "失败" / "和棋"
  final Map<String, dynamic> me;
  final Map<String, dynamic> opponent;
  final VoidCallback onRestart;
  final String type;

  const GameResultOverlay({
    Key? key,
    required this.result,
    required this.me,
    required this.opponent,
    required this.type,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('type:$type');
    final woodBackground = BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color.fromARGB(255, 238, 184, 36),
          Colors.amber.shade100,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.brown.shade900.withOpacity(0.7),
          offset: Offset(0, 4),
          blurRadius: 6,
        ),
      ],
    );

    Widget buildResultText() {
      switch (result) {
        case '胜':
          return Stack(
            children: [
              // 金色描边文字
              Text(
                '胜',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'kaiti',
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3
                    ..color = Colors.amber.shade700, // 金色描边
                  shadows: [
                    Shadow(
                      color: Colors.amber.shade400,
                      blurRadius: 4,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              // 内部红蓝渐变填充文字
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.red, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  '胜',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'kaiti',
                    color: Colors.white, // 填充必须是白色，才会被 ShaderMask 处理
                  ),
                ),
              ),
            ],
          );

        case '败':
          // 简单模仿撕裂感：用渐变+斜切的文字阴影模拟
          return Stack(
            children: [
              Text(
                '败',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'kaiti',
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade300,
                        Colors.grey.shade100,
                      ],
                      stops: [0.0, 0.5, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, 100, 40)),
                ),
              ),

              Positioned(
                left: 2,
                top: 2,
                child: ClipPath(
                  clipper: TearClipper(),
                  child: Text(
                    '败',
                    style: TextStyle(
                      fontSize: 42,
                      fontFamily: 'kaiti',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          );
        case '和':
        default:
          return Stack(
            alignment: Alignment.center,
            children: [
              // 金色描边文字
              Text(
                '和',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1
                    ..color = Colors.green.shade400, // 金色
                ),
              ),
              // 渐变填充文字
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.green.shade200,
                    Colors.green.shade400,
                    Colors.yellow.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  '和',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // 必须是白色才会显示渐变
                  ),
                ),
              ),
            ],
          );
      }
    }

    Widget buildVsText() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // V
          Text(
            'V',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: (me['isRed'] is RxBool ? me['isRed'].value : me['isRed'])
                  ? Colors.red
                  : Colors.blue,
              shadows: [
                Shadow(
                  color: Colors.orangeAccent.withOpacity(0.6),
                  offset: Offset(0, 0),
                  blurRadius: 8,
                ),
              ],
              letterSpacing: 2,
            ),
          ),
          // S
          Text(
            'S',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color:
                  (opponent['isRed'] is RxBool
                      ? opponent['isRed'].value
                      : opponent['isRed'])
                  ? Colors.red
                  : Colors.blue,
              shadows: [
                Shadow(
                  color: Colors.orangeAccent.withOpacity(0.6),
                  offset: Offset(0, 0),
                  blurRadius: 8,
                ),
              ],
              letterSpacing: 2,
            ),
          ),
        ],
      );
    }

    Widget buildProgressBar() {
      return Container(
        child: Column(
          children: [
            Text(
              result == '胜'
                  ? '+10'
                  : result == '败'
                  ? '-10'
                  : '0',

              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            LinearProgressIndicator(
              value:
                  (GlobalData.userInfo[type]['levelBar'] % 100) / 100, // 模拟加载进度
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
              minHeight: 8,
            ),
            Text(
              '等级值：${(GlobalData.userInfo[type]['levelBar'] + 20) % 100} / 100',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    Widget buildRestartButton() {
      return SizedBox(
        width: 300,
        height: 50,
        child: ElevatedButton(
          onPressed: onRestart,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              return Colors.transparent; // 用渐变代替纯色
            }),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            elevation: WidgetStateProperty.all(0),
            shadowColor: WidgetStateProperty.all(Colors.orange.shade200),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.yellow.shade200, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade100.withOpacity(0.6),
                  offset: Offset(-2, -2),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: Colors.orange.shade900.withOpacity(0.5),
                  offset: Offset(2, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '再来一局',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 91, 58, 52),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: woodBackground,
            margin: EdgeInsets.symmetric(horizontal: 50),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 我的头像
                    Column(
                      children: [
                        // 第一个AnimatedAvatar组件
                        AnimatedAvatar(
                          imagePath: me['avatar'],
                          isMyTurn: RxBool(false),
                          isRed: me['isRed'] is RxBool
                              ? me['isRed'].value
                              : me['isRed'],
                        ),

                        Text(
                          me['username'] ?? '用户名',
                          style: TextStyle(
                            color: Color.fromARGB(255, 91, 58, 52),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '等级：${me['level']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color.fromARGB(255, 91, 58, 52),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    // 中间竖排的文字
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildResultText(),
                        SizedBox(height: 8),
                        buildVsText(),
                      ],
                    ),
                    SizedBox(width: 20),

                    // 对方头像
                    Column(
                      children: [
                        AnimatedAvatar(
                          imagePath: opponent['avatar'].value,
                          isMyTurn: RxBool(false),
                          isRed: opponent['isRed'].value,
                        ),
                        Text(
                          opponent['username'].value ?? '用户名',
                          style: TextStyle(
                            color: Color.fromARGB(255, 91, 58, 52),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '等级：${opponent['level'].value}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color.fromARGB(255, 91, 58, 52),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 进度条
                buildProgressBar(),
              ],
            ),
          ),
          SizedBox(height: 24),
          buildRestartButton(),
        ],
      ),
    );
  }
}

// 简单撕裂感裁剪器
class TearClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double step = size.height / 6;
    path.moveTo(0, 0);
    for (int i = 0; i < 6; i++) {
      double y = i * step;
      path.lineTo(size.width * (i % 2 == 0 ? 0.8 : 1.0), y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TearClipper oldClipper) => false;
}
