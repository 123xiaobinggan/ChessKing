import 'package:flutter/material.dart';
import 'login_controller.dart';
import 'package:get/get.dart';
import "dart:math";

// ignore: must_be_immutable
class Login extends StatelessWidget {
  Login({super.key});

  LoginController loginController = Get.put(LoginController());

  // 创建聚焦节点
  final FocusNode accountIdFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover,
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
                    LoginController.sayings[Random().nextInt(LoginController.sayings.length)],
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamilyFallback: [
                        LoginController.fontFamilies[LoginController.changeFont()],
                        "Roboto",
                      ],
                      foreground: Paint()
                        ..shader =
                            LinearGradient(
                              colors:
                                  LoginController.gradients[Random().nextInt(LoginController.gradients.length)],
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
                    controller: loginController.accountIdController,
                    focusNode: accountIdFocusNode,
                    decoration: InputDecoration(
                      hintText: '请输入账号',
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

                  // 密码输入框
                  TextField(
                    controller: loginController.passwordController,
                    focusNode: passwordFocusNode,
                    obscureText: true,
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

                  // 登录按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        int idLength =
                            loginController.accountIdController.text.length;
                        int psdLength =
                            loginController.passwordController.text.length;
                        if (idLength == 0 || psdLength == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('账号或密码不能为空')),
                          );
                          return;
                        }
                        if (idLength > 15) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('账号长度不能超过15位')),
                          );
                          return;
                        }
                        if (psdLength < 5) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('密码长度不能小于5位')),
                          );
                          return;
                        }
                        accountIdFocusNode.unfocus(); // 收起键盘
                        passwordFocusNode.unfocus(); // 收起键盘
                        loginController.login();
            
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFFFA500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('登录', style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 注册按钮
                  TextButton(
                    onPressed: () {
                      // 跳转注册页
                      Get.offNamed('/Register');
                      // Get.toNamed('/Register');
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          '没有账号？点击注册',
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
