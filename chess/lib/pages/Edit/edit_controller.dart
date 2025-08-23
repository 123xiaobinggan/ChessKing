import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '/global/global_data.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class EditController extends GetxController {
  late TextEditingController usernameController = TextEditingController(
    text: GlobalData.userInfo['username'],
  );
  late TextEditingController descriptionController = TextEditingController(
    text: GlobalData.userInfo['description'],
  );
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController newPasswordController = TextEditingController();
  late TextEditingController confirmPasswordController =
      TextEditingController();

  var avatar = RxMap<String, dynamic>({
    'path': GlobalData.userInfo['avatar'] ?? '',
    'file': null,
    'time': DateTime.now().millisecondsSinceEpoch, // 时间戳，用于更新头像,
  });

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode newPasswordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  @override
  void onClose() {
    usernameController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> changeAvatar(BuildContext context) async {
    final List<AssetEntity>? image = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1, // 最多选择一张图片
        requestType: RequestType.image, // 只选择图片
        specialItemPosition: SpecialItemPosition.prepend,
        specialItemBuilder:
            (
              BuildContext context,
              AssetPathEntity? entity, // 添加这个参数
              int index,
            ) {
              return const Center(
                child: Icon(Icons.camera_alt, size: 42, color: Colors.grey),
              );
            },
      ),
    );
    if (image != null) {
      final file = await image[0].file;
      avatar['path'] = file?.path ?? ''; // 保存图片路径
      avatar['file'] = file; // 保存图片文件
      print('avatar, ${avatar}');
    }
  }

  void saveUserInfo() async {
    late final username, description, password, newPassword, confirmPassword;
    passwordController.text = passwordController.text.trim();
    newPasswordController.text = newPasswordController.text.trim();
    confirmPasswordController.text = confirmPasswordController.text.trim();

    if (usernameController.text != GlobalData.userInfo['username']) {
      username = usernameController.text.trim();
    } else {
      username = '';
    }
    if (descriptionController.text != GlobalData.userInfo['description']) {
      description = descriptionController.text.trim();
    } else {
      description = '';
    }
    if (passwordController.text != '' ||
        newPasswordController.text != '' ||
        confirmPasswordController.text != '') {
      if (passwordController.text == '' ||
          newPasswordController.text == '' ||
          confirmPasswordController.text == '') {
        showDialog('请填写完整的密码信息');
        return;
      }
      if (newPasswordController.text != confirmPasswordController.text) {
        showDialog('新密码不一致');
        return;
      }
      password = passwordController.text;
      newPassword = newPasswordController.text;
      confirmPassword = confirmPasswordController.text;
    } else {
      password = '';
      newPassword = '';
      confirmPassword = '';
    }

    if (username != '' ||
        description != '' ||
        avatar['file'] != null ||
        password != '' ||
        newPassword != '' ||
        confirmPassword != '') {
      showLoading();
      var dio = Dio();
      if (avatar['file'] != null) {
        String uploadedUrl = await uploadAvatar(File(avatar['path']));
        if (uploadedUrl == '') {
          print('上传失败');
          Get.back();
          showDialog('头像上传失败');
          return;
        }
        avatar['time']=DateTime.now().millisecondsSinceEpoch;
        GlobalData.userInfo['avatar'] = '$uploadedUrl?v=${avatar['time']}';
        avatar['path'] = GlobalData.userInfo['avatar'];
        print('GlobalData.userInfo,${GlobalData.userInfo['avatar']}');
      }
      var params = {
        'accountId': GlobalData.userInfo['accountId'], // 账号ID
        'username': username,
        'avatar': GlobalData.userInfo['avatar'],
        'description': description,
        'password': password,
        'newPassword': newPassword,
      };
      try {
        final res = await dio.post(
          '${GlobalData.url}/Edit',
          data: params, // 发送请求参数
        );
        Get.back(); // 关闭加载对话框
        print('res.data, ${res.data}');
        if (res.data['code'] == 0) {
          if (username != '') {
            GlobalData.userInfo['username'] = username;
          }
          if (description != '') {
            GlobalData.userInfo['description'] = description;
          }
          if (avatar['file'] != null) {
            GlobalData.userInfo['avatar'] = avatar['path'];
          }
          showDialog('更新成功'); // 显示成功提示
        } else {
          showDialog('更新失败'); // 显示错误提示
        }
      } catch (e) {
        print(e); // 打印错误信息
        showDialog('更新失败'); // 显示错误提示
      } finally {
        avatar['file'] = null; // 清空文件
      }
    }
  }

  Future<String> uploadAvatar(File avatarFile) async {
    String filePath = 'User/${GlobalData.userInfo['accountId']}.jpg'; // 上传路径
    String signedUrl = await getSignature(filePath); // 获取签名
    print('signedUrl, ${signedUrl}');
    var dio = Dio();
    try {
      final imageBytes = await avatarFile.readAsBytes();
      final response = await dio.put(
        signedUrl,
        data: imageBytes,
        options: Options(
          headers: {
            'Content-Type': 'image/jpeg', // 根据图片类型调整
          },
        ),
      );
      if (response.statusCode == 200) {
        return 'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/${GlobalData.userInfo['accountId']}.jpg'; // 返回图片URL;
      } else {
        showDialog('上传失败'); // 显示错误提示
        return '';
      }
    } catch (e) {
      print(e); // 打印错误信息
      showDialog('上传失败'); // 显示错误提示
      return '';
    }
  }

  Future<String> getSignature(String filePath) async {
    var dio = Dio();
    final res = await dio.post(
      '${GlobalData.url}/GetSignature',
      data: {
        'accountId': GlobalData.userInfo['accountId'], // 账号ID
        'filePath': filePath, // 上传路径
      },
    );
    print('res.data, ${res.data}');
    return res.data['url'];
  }

  void showDialog(String text) {
    Get.snackbar(
      '提示', // 标题
      text, // 内容
      snackPosition: SnackPosition.TOP, // 显示在底部
    );
  }

  void showLoading() {
    Get.dialog(
      Center(
        child: CircularProgressIndicator(), // 显示加载指示器
      ),
      barrierDismissible: true, // 禁止用户点击背景关闭对话框
    );
  }
}
