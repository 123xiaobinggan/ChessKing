import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'register_controller.dart';
import 'dart:math';

class Register extends StatelessWidget {
  Register({super.key});

  static const List<String> sayings = [
    "落子无悔大丈夫",
    "棋路漫漫 有你相伴",
    "棋场即战场",
    "宁失一子 不失一先",
    "乾坤未定 你我皆是黑马",
    "一着不慎 满盘皆输",
    "以棋会友",
    "到乡翻似烂柯人",
    "相见恨晚 旗鼓相当",
    "一鼓作气 先发制人",
    "君子一言 快马一鞭",
    "兵者 诡道也",
    "罗袜生尘 凌波微步",
    "月之皎兮 佼人僚兮",
    "闲敲棋子落灯花",
    "日日思君不见君",
    "白露横江 水光接天",
    "雪压围棋石 风吹饮酒楼",
    "玉作弹棋局 中心亦不平",
    "恃强斯有失 守分固无侵",
    "人间与世远 鸟语知境静",
    "十分潋滟君休赤",
    "易醉扶头酒 难逢敌手棋",
    "诗酒琴棋客 风花雪月天",
    "高田如楼梯,平田如棋局",
    "一局残棋见六朝",
    "雪拥蓝关马不前",
    "将军置酒饮归客",
    "男儿何不带吴钩",
    "谈笑间 樯橹灰飞烟灭",
    "实者虚之 虚者实之",
  ];

  static final List<List<Color>> gradients = [
    [Color(0xFFFFD700), Color(0xFFFF8C00)],
    [Color(0xFFFFDDE1), Color(0xFFFEC8D8)],
    [Color(0xFFFF758C), Color(0xFFFF7EB3)],
    [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
    [Color(0xFFB2F7EF), Color(0xFF82EEDD)],
    [Color(0xFFC3AED6), Color(0xFF736CED)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF9966FF), Color(0xFF99CCFF)],
    [Color(0xFF3399FF), Color(0xFF99CCFF)],
    [Color(0xFF66CCFF), Color(0xFF99CCFF)],
    [Color(0xFF6699FF), Color(0xFF99CCFF)],
  ];

  static final List<String> fontFamilies = [
    "ZhiMangXing-Regular",
    "MaShanZheng-Regular",
    "YunFengJingLong",
    "XiaoJiaoWenXun",
    "XiaWuZhenKai",
    "SanJi",
    "QianDu",
  ];

  final RegisterController registerController = Get.put(RegisterController());
  // 创建 FocusNode
  final accountIdFocusNode = FocusNode();
  final userNameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover, // 图片填充方式
            ),
          ),
          // 内容区域
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    decoration: BoxDecoration(
                      // color: Colors.white.withValues(alpha: 0.9 * 255), // 背景色
                      borderRadius: BorderRadius.circular(12), // 圆角
                    ),
                    child: Image.asset(
                      'assets/Login/Logo.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  // Text
                  Text(
                    sayings[Random().nextInt(sayings.length)],
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamilyFallback: [
                        fontFamilies[Random().nextInt(fontFamilies.length)],
                        "Roboto",
                      ],
                      foreground: Paint()
                        ..shader =
                            LinearGradient(
                              colors:
                                  gradients[Random().nextInt(gradients.length)],
                            ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                      shadows: const [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // 账号输入框
                  TextField(
                    controller: registerController.accountIdController,
                    focusNode: accountIdFocusNode, // 关联 FocusNode
                    decoration: InputDecoration(
                      hintText: '请输入账号(字母+数字)',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.9 * 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: registerController.userNameController,
                    focusNode: userNameFocusNode, // 关联 FocusNode
                    decoration: InputDecoration(
                      hintText: '请输入用户名',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.9 * 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 密码输入框
                  TextField(
                    controller: registerController.passwordController,
                    obscureText: true,
                    focusNode: passwordFocusNode, // 关联 FocusNode
                    decoration: InputDecoration(
                      hintText: '请输入密码',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.9 * 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 注册按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 让输入框失焦
                        accountIdFocusNode.unfocus();
                        userNameFocusNode.unfocus();
                        passwordFocusNode.unfocus();

                        int idLength =
                            registerController.accountIdController.text.length;
                        int userNameLength =
                            registerController.userNameController.text.length;
                        int psdLength =
                            registerController.passwordController.text.length;
                        if (idLength == 0 ||
                            psdLength == 0 ||
                            userNameLength == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('账号、用户名或密码不能为空')),
                          );
                          return;
                        }
                        if (idLength > 15) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('账号长度不能超过15位')),
                          );
                          return;
                        }
                        if (userNameLength > 15) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('用户名长度不能超过15位')),
                          );
                          return;
                        }
                        if (psdLength < 5) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('密码长度不能小于5位')),
                          );
                          return;
                        }
                        
                        registerController.register();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFFFA500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('注册', style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 登录按钮
                  TextButton(
                    onPressed: () {
                      // 跳转注册页
                      Get.offNamed('/Login');
                      // Get.toNamed('/Login');
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          '已有账号？点击登录',
                          style: TextStyle(color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 150, // 下划线宽度
                            height: 2, // 下划线高度
                            color: Colors.white, // 下划线颜色
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}