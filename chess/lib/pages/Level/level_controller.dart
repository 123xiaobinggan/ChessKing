import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../global/global_data.dart';

class LevelController extends GetxController {
  late String accountId;
  Map<String, dynamic>? ChineseChess;
  Map<String, dynamic>? Go;
  Map<String, dynamic>? Military;
  Map<String, dynamic>? Fir;
  RxBool isLoading = true.obs;

  @override
  void onInit() async {
    super.onInit();
    print('init');
    accountId = Get.parameters['accountId'] ?? GlobalData.userInfo['accountId'];
    print('accountId:$accountId');
    await getStats();
    isLoading.value = false;
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose');
  }

  Future<void> getStats() async {
    Dio dio = Dio();
    String url = GlobalData.url;
    Map<String, dynamic> params = {'accountId': accountId};
    try {
      final res = await dio.post('$url/GameStats', data: params);
      print('获取成功,${res.data['data']}');
      if (res.data['code'] == 0) {
        ChineseChess = res.data['data']['ChineseChess'];
        Go = res.data['data']['Go'];
        Military = res.data['data']['Military'];
        Fir = res.data['data']['Fir'];
        print('成功:$ChineseChess,$Go,$Military,$Fir');
        if (accountId == GlobalData.userInfo['accountId']) {
          GlobalData.userInfo['ChineseChess'] = ChineseChess;
          GlobalData.userInfo['Go'] = Go;
          GlobalData.userInfo['Military'] = Military;
          GlobalData.userInfo['Fir'] = Fir;
        }
      } else {
        print('获取失败');
        ChineseChess = GlobalData.userInfo['ChineseChess'];
        Go = GlobalData.userInfo['Go'];
        Military = GlobalData.userInfo['Military'];
        Fir = GlobalData.userInfo['Fir'];
      }
    } catch (e) {
      print('获取失败,$e');
      ChineseChess = GlobalData.userInfo['ChineseChess'];
      Go = GlobalData.userInfo['Go'];
      Military = GlobalData.userInfo['Military'];
      Fir = GlobalData.userInfo['Fir'];
    }
  }
}
