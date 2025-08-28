import 'package:flutter/material.dart';


Widget buildGameButton(
  String title,
  String imagePath,
  void Function()? onTap,
  {  
  int edge = 32,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF5DEB3), Color(0xFFDEB887)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.6), // 高光
            offset: const Offset(-3, -3),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.brown.shade600, // 阴影
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
        ],
        border: Border.all(color: Colors.brown.shade400, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.brown.shade200.withOpacity(0.3),
          highlightColor: Colors.brown.shade100.withOpacity(0.3),
          onTap: () {
            if (onTap != null) {
              onTap();
            }
          },
          child: SizedBox(
            height: 80,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // 保证垂直居中
                children: [
                  // SizedBox(width: 105),
                  imagePath != ''
                      ? Image.asset(
                          imagePath,
                          height: edge.toDouble(), // 调整图像大小,
                          fit: BoxFit.contain, // 保证图像不超出
                          alignment: Alignment.center, // 强制图像自身居中
                        )
                      : SizedBox(),
                  const SizedBox(width: 20),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[900],
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
