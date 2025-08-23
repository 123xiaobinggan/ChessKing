import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Version extends StatelessWidget {
  Version({super.key});

  final String version = "1.0.1";
  final List<String> changelog = [
    "✨ 新增用户信息编辑功能",
    "🐞 修复部分图片上传失败问题",
    "🚀 优化启动速度",
    "🛠️ 小幅调整界面样式",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 区域
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            AppBar(
              title: Text(
                '版本发行',
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
            ),
          ],
        ),
      ),

      // Body 区域
      body: Stack(
        children: [
          Image.asset(
            'assets/MyInfo/BackGround.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8DC), // 米黄色背景
              borderRadius: BorderRadius.circular(16), // 圆角
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "当前版本：v$version",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "更新内容：",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 10),
                ...changelog.map(
                  (log) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        Expanded(
                          child: Text(
                            log,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
