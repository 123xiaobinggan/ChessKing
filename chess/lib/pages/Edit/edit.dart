import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'edit_controller.dart';
import '/widgets/avatar_image.dart'; // 导入头像组件
import '../AvatarPreview/avatar_preview.dart'; // 导入头像预览组件

class Edit extends StatelessWidget {
  Edit({super.key});

  final EditController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/MyInfo/BackGround.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            AppBar(
              title: Text(
                '编辑资料',
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0.5, 0.5),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Get.back();
                },
              ),
              actions: [
                IconButton(
                  icon: Image.asset(
                    'assets/MyInfo/Store.png',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    Get.toNamed('/Recharge');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 头像
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4), // 模拟边框宽度
                    child: GestureDetector(
                      onTap: () {
                        final imageProvider = resolveImageProvider(
                          controller.avatar['file'] ??
                              controller.avatar['path'],
                          controller.avatar['file'] == null,
                        );
                        Get.to(
                          () => ImagePreviewPage(imageProvider: imageProvider),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white, // 内层背景色
                        ),
                        child: Obx(
                          () => avatarImage(
                            controller.avatar['path'],
                            controller.avatar['file'] == null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 更换头像
                ElevatedButton(
                  onPressed: () => controller.changeAvatar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    fixedSize: const Size(500, 50),
                  ),
                  child: const Text(
                    '更换头像',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 30),

                // 用户名
                TextField(
                  controller: controller.usernameController,
                  focusNode: controller.usernameFocusNode,
                  decoration: InputDecoration(
                    labelText: '用户名',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 个性签名
                TextField(
                  controller: controller.descriptionController,
                  focusNode: controller.descriptionFocusNode,
                  // maxLines: 2,
                  decoration: InputDecoration(
                    labelText: '个性签名',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 原密码
                TextField(
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: '原密码',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 新密码
                TextField(
                  controller: controller.newPasswordController,
                  focusNode: controller.newPasswordFocusNode,
                  decoration: InputDecoration(
                    labelText: '新密码',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 确认密码
                TextField(
                  controller: controller.confirmPasswordController,
                  focusNode: controller.confirmPasswordFocusNode,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                // 保存按钮
                ElevatedButton(
                  onPressed: controller.saveUserInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fixedSize: const Size(400, 50),
                  ),
                  child: const Text(
                    '保存',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
