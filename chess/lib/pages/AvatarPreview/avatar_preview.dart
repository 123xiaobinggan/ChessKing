import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewPage extends StatelessWidget {
  final ImageProvider imageProvider;

  const ImagePreviewPage({super.key, required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Get.back(), // 单击返回
        child: Center(
          child: PhotoView(
            imageProvider: imageProvider,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
          ),
        ),
      ),
    );
  }
}

ImageProvider resolveImageProvider(dynamic src, bool isNetwork) {
  if (!isNetwork) {
    return FileImage(src);
  } else if (src is String && src.startsWith('http')) {
    return NetworkImage(src);
  } else {
    return const AssetImage('assets/MyInfo/NotLogin.png');
  }
}
