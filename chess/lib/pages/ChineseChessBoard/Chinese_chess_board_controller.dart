import 'dart:math';
import 'package:flutter/material.dart';
import '/widgets/Chinese_chess_piece_painter.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '/global/global_data.dart';
import '/widgets/loading_dialog.dart';
import '/widgets/confirm_dialog.dart';
import '/widgets/show_message_dialog.dart';
import '/widgets/build_personal_info_card.dart';
import '../MyFriends/my_friends_controller.dart';

class ChineseChessBoardController extends GetxController {
  String type = 'ChineseChessMatch'; // 游戏类型
  String opponentAccountId = '空座';
  String aiLevel = "初级";
  RxBool showMenu = false.obs; // 菜单按钮
  RxBool showChat = false.obs; // 聊天按钮
  RxBool showMyMessage = false.obs; // 控制我方聊天显示
  RxString opponentChatMessage = ''.obs; // 聊天消息

  RxBool sendKingAlert = false.obs; // 是否送将
  Rx<ChineseChessPieceModel> selectedPiece = ChineseChessPieceModel(
    type: '',
    isRed: false,
    pos: Point(row: -1, col: -1),
  ).obs;
  Rx<ChineseChessPieceModel> placedPiece = ChineseChessPieceModel(
    type: '',
    isRed: false,
    pos: Point(row: -1, col: -1),
  ).obs;

  late List<List<dynamic>> chessBoard; // 记录棋盘棋子位置

  Rx<Point> sourcePoint = Point(row: -1, col: -1).obs; // 记录棋子移动前的位置

  RxList<Point> availableMove = <Point>[].obs; // 记录可移动点

  // 游戏信息
  RxMap<String, dynamic> playerInfo = {
    "me": {
      "accountId": GlobalData.userInfo['accountId'],
      'username': GlobalData.userInfo['username'],
      'avatar': GlobalData.userInfo['avatar'],
      'level': GlobalData.userInfo['ChineseChess']['level'],
      'timeLeft': 0.obs,
      'myTurn': false.obs,
      'showMessage': false.obs,
      'isRed': true.obs, // 红方
    },
    "opponent": {
      "accountId": '空座'.obs,
      'username': '空座'.obs,
      'avatar':
          'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png'
              .obs,
      'level': '1-1'.obs,
      'timeLeft': 0.obs,
      'showMessage': false.obs,
      'myTurn': false.obs,
      'isRed': false.obs, // 黑方
    },
  }.obs;

  // 棋子
  RxList<ChineseChessPieceModel> pieces = <ChineseChessPieceModel>[].obs;
  final chatInputController = TextEditingController();
  final RxInt currentLength = 0.obs; // 输入框长度
  final RxList<Map<String, dynamic>> chatHistory =
      <Map<String, dynamic>>[].obs; // 聊天记录

  var stage = GameStage.idle.obs; // 游戏阶段
  RxInt gameTime = 0.obs;
  RxInt stepTime = 0.obs;
  RxInt myStepTime = 0.obs;
  RxInt opponentStepTime = 0.obs;
  String result = '和';
  String roomId = '';
  final moves = [];
  int requestUndoCnt = 0;
  int requestDrawCnt = 0;
  ChineseChessPieceModel capturedPiece = ChineseChessPieceModel(
    type: '',
    isRed: false,
    pos: Point(row: -1, col: -1),
  );

  final isInCheckNotifier = ValueNotifier<bool>(false);
  final isInCheckMateNotifier = ValueNotifier<bool>(false);

  Timer? _gametimer;
  Timer? _moveRequestTimer;
  Timer? _matchTimer;

  final socketService = GlobalData.socketService;
  bool _moveListenerInitialized = false;
  StreamSubscription<dynamic>? _moveSubscription;
  StreamSubscription<dynamic>? _matchSubscription;
  StreamSubscription<dynamic>? _waitingSubscription;
  StreamSubscription<dynamic>? _disconnectSubscription;
  StreamSubscription<dynamic>? _opponentDisconnectSubscription;
  StreamSubscription<dynamic>? _reconnectSubscription;
  StreamSubscription<dynamic>? _opponentReconnectSubscription;
  StreamSubscription<dynamic>? _opponentDealInvitationSubscription;
  StreamSubscription<dynamic>? _opponentReadySubscription;
  StreamSubscription<dynamic>? _roomJoinedSubscription;
  StreamSubscription<dynamic>? _receiveMessagesSubscription;
  StreamSubscription<dynamic>? _receiveActionsSubscription;
  StreamSubscription<dynamic>? _opponentLeaveSubscription;

  @override
  void onInit() {
    super.onInit();
    print('onInit');

    socketService.initSocket(); // 初始化 SocketService

    playerInfo['me']['myTurn'].listen((value) {
      if (stage.value != GameStage.playing) {
        return;
      }
      if (value == true) {
        print('我方回合');
        myStepTime.value = min(
          stepTime.value,
          playerInfo['me']['timeLeft'].value,
        );
        startTimer(playerInfo['me']['timeLeft'], myStepTime, true);
      }
    });

    playerInfo['opponent']['myTurn'].listen((value) {
      if (value == true) {
        print('对方回合');
        requestUndoCnt = 0;
        requestDrawCnt = 0;
        opponentStepTime.value = min(
          stepTime.value,
          playerInfo['opponent']['timeLeft'].value,
        );
        startTimer(playerInfo['opponent']['timeLeft'], opponentStepTime, false);
        if (placedPiece.value.type != '') {
          print('发送我方落子');
          sendMyMove(
            placedPiece.value.type,
            sourcePoint.value,
            placedPiece.value.pos,
          );
        }
      }
    });

    // 我方断线
    _disconnectSubscription = socketService.onDisconnect.listen((data) {
      if (stage.value == GameStage.playing) {
        print('onDisconnect,断开连接,${data}');
        Get.dialog(
          ShowMessageDialog(content: '正在重新连接'),
          barrierDismissible: false,
          barrierColor: Colors.transparent,
        );
      }
    });

    // 重连获取棋盘数据
    _reconnectSubscription = socketService.onReconnect.listen((data) {
      Get.back();
      print('onReconnect重新连接,$data');
      if (data['status'] == "finished") {
        overGame(data['result']['winner'], data['result']['reason']);
        return;
      }
      if (data['moves'].length > moves.length) {
        print(
          'moves,${data['moves']},${moves.length},${data['moves'][moves.length]}',
        );
        getOpponentMove({'step': data['moves'][moves.length]});
      }
    });

    // 对方断线通知
    _opponentDisconnectSubscription = socketService.onOpponentDisconnect.listen(
      (data) {
        print('onOpponentDisconnect,断开连接,${data}');
        Get.dialog(
          ShowMessageDialog(content: '对方断线,等待重连'),
          barrierDismissible: false,
          barrierColor: Colors.transparent,
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.back();
        });
      },
    );

    //对方重连通知
    _opponentReconnectSubscription = socketService.onOpponentReconnect.listen((
      data,
    ) {
      print('onOpponentReconnect,对方重新连接,${data}');
      Get.dialog(
        ShowMessageDialog(content: '对方已重连'),
        barrierDismissible: false,
        barrierColor: Colors.transparent,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back();
      });
    });

    // 对方处理邀请
    _opponentDealInvitationSubscription = socketService.onOpponentDealInvitation
        .listen((data) {
          print('onOpponentDealInvitation,对方处理邀请,${data}');
          if (data['deal'] == 'reject') {
            Get.dialog(
              ShowMessageDialog(content: '对方拒绝了你的邀请'),
              barrierDismissible: false,
              barrierColor: Colors.transparent,
            );
          } else {
            Get.dialog(
              ShowMessageDialog(content: '对方在对局中'),
              barrierDismissible: false,
              barrierColor: Colors.transparent,
            );
          }
          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.back();
          });
        });

    // 对方准备
    _opponentReadySubscription = socketService.onOpponentReady.listen((
      accountId,
    ) {
      if (accountId != playerInfo['opponent']['accountId'].value) {
        return;
      }
      print('onOpponentReady,对方准备');
      Get.dialog(
        ShowMessageDialog(content: '对方已准备'),
        barrierDismissible: false,
        barrierColor: Colors.transparent,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back();
      });
    });

    // 对方离开房间
    _opponentLeaveSubscription = socketService.onOpponentLeave.listen((_) {
      print('onOpponentLeave,对方离开房间');
      playerInfo['opponent']['accountId'].value = '空座';
      playerInfo['opponent']['username'].value = '空座';
      playerInfo['opponent']['avatar'].value =
          'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png';
      playerInfo['opponent']['level'].value = '1-1';
    });

    // 房间建立
    _roomJoinedSubscription = socketService.onRoomJoined.listen((data) {
      print('onRoomJoined,房间建立,${data}');
      roomId = data['roomId'];
      if (playerInfo['me']['accountId'] == data['inviter']['accountId']) {
        playerInfo['opponent']['accountId'].value =
            data['invitee']['accountId'];
        playerInfo['opponent']['username'].value = data['invitee']['username'];
        playerInfo['opponent']['avatar'].value = data['invitee']['avatar'];
        playerInfo['opponent']['level'].value = data['invitee']['level'];
      } else {
        playerInfo['opponent']['accountId'].value =
            data['inviter']['accountId'];
        playerInfo['opponent']['username'].value = data['inviter']['username'];
        playerInfo['opponent']['avatar'].value = data['inviter']['avatar'];
        playerInfo['opponent']['level'].value = data['inviter']['level'];
      }
    });

    //收听消息
    _receiveMessagesSubscription = socketService.onReceiveMessages.listen((
      data,
    ) {
      print('onReceiveMessages,收到消息,${data}');
      receiveText(data);
    });

    //收听动作
    _receiveActionsSubscription = socketService.onReceiveActions.listen((data) {
      print('onReceiveActions,收到动作,${data}');
      receiveActions(data);
    });
  }

  @override
  void onClose() {
    print('onClose');
    stopTimer();
    socketService.overGame();
    GlobalData.isPlaying = false;
    socketService.cancelMatch();
    if (stage.value == GameStage.playing) {
      socketService.sendActions({
        'accountId': playerInfo['me']['accountId'],
        'type': "认输",
        'roomId': roomId,
      });
      overGame('败', 'surrender');
    } else {
      Get.back();
    }
    _waitingSubscription?.cancel();
    _waitingSubscription = null;
    _opponentDisconnectSubscription?.cancel();
    _opponentDisconnectSubscription = null;
    _opponentReconnectSubscription?.cancel();
    _opponentReconnectSubscription = null;
    _disconnectSubscription?.cancel();
    _disconnectSubscription = null;
    _reconnectSubscription?.cancel();
    _reconnectSubscription = null;
    _matchSubscription?.cancel();
    _matchSubscription = null;
    _opponentDealInvitationSubscription?.cancel();
    _opponentDealInvitationSubscription = null;
    _opponentReadySubscription?.cancel();
    _opponentReadySubscription = null;
    _opponentLeaveSubscription?.cancel();
    _opponentLeaveSubscription = null;
    _roomJoinedSubscription?.cancel();
    _roomJoinedSubscription = null;
    _receiveMessagesSubscription?.cancel();
    _receiveMessagesSubscription = null;
    _receiveActionsSubscription?.cancel();
    _receiveActionsSubscription = null;
    _moveSubscription?.cancel();
    _moveSubscription = null;
    _moveListenerInitialized = false;
    chatInputController.dispose();
    Get.delete<ChineseChessBoardController>();
    super.onClose();
  }

  // 初始化棋盘
  void initChessBoard() {
    initChessPiece();
    print('初始化棋盘');
    chessBoard = List.generate(10, (_) => List.filled(9, null));
    for (var piece in pieces) {
      chessBoard[piece.pos.row][piece.pos.col] = copyPiece(piece);
    }
    sourcePoint.value = Point(row: -1, col: -1);
  }

  // 初始化棋子
  void initChessPiece() {
    print(
      '初始化棋子,${playerInfo['me']['isRed'].value},${playerInfo['opponent']['isRed'].value}',
    );
    pieces.clear();
    pieces.addAll([
      // 上方
      ChineseChessPieceModel(
        type: '車',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 0, col: 0),
      ),
      ChineseChessPieceModel(
        type: '馬',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 0, col: 1),
      ),
      ChineseChessPieceModel(
        type: playerInfo['opponent']['isRed'].value ? '相' : '象',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 0, col: 2),
      ),
      ChineseChessPieceModel(
        type: '仕',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 0, col: 3),
      ),
      ChineseChessPieceModel(
        type: playerInfo['opponent']['isRed'].value ? '帥' : '將',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 0, col: 4),
      ),
      ChineseChessPieceModel(
        type: '仕',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 0, col: 5),
      ),
      ChineseChessPieceModel(
        type: playerInfo['opponent']['isRed'].value ? '相' : '象',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 0, col: 6),
      ),
      ChineseChessPieceModel(
        type: '馬',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 0, col: 7),
      ),
      ChineseChessPieceModel(
        type: '車',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 0, col: 8),
      ),
      ChineseChessPieceModel(
        type: '炮',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 2, col: 1),
      ),
      ChineseChessPieceModel(
        type: '炮',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 2, col: 7),
      ),
      ChineseChessPieceModel(
        type: playerInfo['opponent']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 3, col: 0),
      ),
      ChineseChessPieceModel(
        type: playerInfo['opponent']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 3, col: 2),
      ),
      ChineseChessPieceModel(
        type: playerInfo['opponent']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 3, col: 4),
      ),
      ChineseChessPieceModel(
        type: playerInfo['opponent']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 3, col: 6),
      ),
      ChineseChessPieceModel(
        type: playerInfo['opponent']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['opponent']['isRed'].value,
        pos: Point(row: 3, col: 8),
      ),

      // 下方
      ChineseChessPieceModel(
        type: '車',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 9, col: 0),
      ),
      ChineseChessPieceModel(
        type: '馬',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 9, col: 1),
      ),
      ChineseChessPieceModel(
        type: playerInfo['me']['isRed'].value ? '相' : '象',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 9, col: 2),
      ),
      ChineseChessPieceModel(
        type: '仕',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 9, col: 3),
      ),
      ChineseChessPieceModel(
        type: playerInfo['me']['isRed'].value ? '帥' : '將',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 9, col: 4),
      ),
      ChineseChessPieceModel(
        type: '仕',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 9, col: 5),
      ),
      ChineseChessPieceModel(
        type: playerInfo['me']['isRed'].value ? '相' : '象',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 9, col: 6),
      ),
      ChineseChessPieceModel(
        type: '馬',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 9, col: 7),
      ),
      ChineseChessPieceModel(
        type: '車',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 9, col: 8),
      ),
      ChineseChessPieceModel(
        type: '炮',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 7, col: 1),
      ),
      ChineseChessPieceModel(
        type: '炮',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 7, col: 7),
      ),
      ChineseChessPieceModel(
        type: playerInfo['me']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 6, col: 0),
      ),
      ChineseChessPieceModel(
        type: playerInfo['me']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 6, col: 2),
      ),
      ChineseChessPieceModel(
        type: playerInfo['me']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 6, col: 4),
      ),
      ChineseChessPieceModel(
        type: playerInfo['me']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 6, col: 6),
      ),
      ChineseChessPieceModel(
        type: playerInfo['me']['isRed'].value ? '兵' : '卒',
        isRed: playerInfo['me']['isRed'].value,
        pos: Point(row: 6, col: 8),
      ),
    ]);
  }

  // 初始化游戏信息
  void initplayerInfo() {
    if (!_moveListenerInitialized) {
      print("监听棋子移动事件");
      _moveSubscription = socketService.onMove.listen((moveData) {
        getOpponentMove(moveData);
      });
      _moveListenerInitialized = true; // 设置标志为 true，表示监听器已初始化
    }
    roomId = '';
    moves.clear();
    availableMove.clear();
    chatHistory.clear();
    myStepTime.value = stepTime.value;
    opponentStepTime.value = stepTime.value;
    playerInfo['me']['myTurn'].value = false;
    playerInfo['opponent']['myTurn'].value = false;
    playerInfo['me']['showMessage'].value = false;
    playerInfo['opponent']['showMessage'].value = false;
    playerInfo['me']['timeLeft'].value = gameTime.value;
    playerInfo['me']['timeLeft'].value = gameTime.value;
    playerInfo['opponent']['timeLeft'].value = gameTime.value;
    playerInfo['opponent']['accountId'].value = opponentAccountId;
    print('${playerInfo['opponent']['accountId'].value}');

    print(
      '${playerInfo['me']['timeLeft'].value},${playerInfo['opponent']['timeLeft'].value}',
    );
    print('${myStepTime.value},${opponentStepTime.value}');
  }

  // 菜单栏展开
  void toggleMenu() {
    showMenu.value = !showMenu.value;
    showChat.value = false;
  }

  // 聊天窗口展开
  void toggleChatDialog() {
    showChat.value = !showChat.value;
    showMenu.value = false;
  }

  // 展示个人信息
  void showPersonalInfo(String accountId) async {
    String avatar =
        'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/xiaobinggan.jpg';
    String username = '';
    String description = '';
    int activity = 0;
    int gold = 0;
    int coupon = 0;
    Dio dio = Dio();
    Map<String, dynamic> params = {'accountId': accountId};
    try {
      final res = await dio.post("${GlobalData.url}/GetUserInfo", data: params);
      if (res.data['code'] == 0) {
        print(res.data);
        avatar = res.data['avatar'];
        username = res.data['username'];
        description = res.data['description'];
        activity = res.data['activity'].toInt();
        gold = res.data['gold'].toInt();
        coupon = res.data['coupon'].toInt();
      } else {
        print(res.data['msg']);
      }
    } catch (e) {
      print(e);
      print('获取用户信息失败');
    }
    ;

    Get.dialog(
      BuildPersonalInfoCard(
        avatar: avatar,
        username: username,
        accountId: accountId,
        description: description,
        activity: activity,
        gold: gold,
        coupon: coupon,
        isFriend: true,
        onLevelTap: () => onLevelTap(accountId),
        onFriendTap: () => onFriendTap(accountId),
        onSendConversationMessage: () => onSendConversationMessage(accountId),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.001),
    );
  }

  // 点击等级信息
  void onLevelTap(String accountId) {
    Get.toNamed('/Level', parameters: {'accountId': accountId});
  }

  // 点击添加好友
  void onFriendTap(String accountId) {
    if (GlobalData.userInfo['friends'].contains(accountId)) {
      Get.dialog(
        ShowMessageDialog(content: '你们已经是好友了'),
        barrierDismissible: true,
        barrierColor: Colors.transparent,
      );
      Future.delayed(Duration(seconds: 1), () {
        Get.back();
      });
    } else {
      final MyFriendsController myFriendsController = Get.find();
      myFriendsController.request(accountId: accountId);
    }
  }

  // 发送私信
  void onSendConversationMessage(String accountId) async {
    Get.toNamed('/ChatWindow', parameters: {'accountId': accountId});
  }

  // 发送消息
  void sendMessages(String text) {
    chatInputController.text = text;
    showChat.value = false;
    showMyMessage.value = true;

    Future.delayed(Duration(seconds: 5), () {
      showMyMessage.value = false;
      chatInputController.clear();
    });

    socketService.sendMessages({
      'accountId': GlobalData.userInfo['accountId'],
      'text': text,
      'roomId': roomId,
    });
    chatHistory.add({'accountId': playerInfo['me']['accountId'], 'text': text});
  }

  // 选择棋子
  void selectPiece(ChineseChessPieceModel piece) async {
    if (!(playerInfo['me']['myTurn'].value == true &&
            piece.isRed == playerInfo['me']['isRed'].value ||
        playerInfo['opponent']['myTurn'].value == true &&
            piece.isRed == playerInfo['opponent']['isRed'].value)) {
      return;
    }
    if (piece.isRed != playerInfo['me']['isRed'].value) {
      return;
    }
    selectedPiece.value = piece;
    availableMove.value = canMovePoint(piece, chessBoard);
    print('选中棋子: ${piece.type}, 位置: ${piece.pos.row}, ${piece.pos.col}');
  }

  // 重置选择的棋子
  void resetSelectedPiece() {
    selectedPiece.value = ChineseChessPieceModel(
      type: '',
      isRed: false,
      pos: Point(row: -1, col: -1),
    );
  }

  // 清除可移动点的记录
  void clearAvailableMove() {
    availableMove.clear();
  }

  // 移动我方棋子到可移动点
  void moveSelectedPiece(int newRow, int newCol) {
    // 检查新位置是否合法
    bool isContain = false;
    for (var point in availableMove) {
      if (point.row == newRow && point.col == newCol) {
        isContain = true;
        break;
      }
    }
    if (!isContain) {
      return;
    }
    sendKingAlert.value = sendKing(
      selectedPiece.value,
      Point(row: newRow, col: newCol),
    );
    if (sendKingAlert.value) {
      print('送将');
      return;
    }
    // 吃掉对方棋子
    capturePiece(newRow, newCol);
    chessBoard[selectedPiece.value.pos.row][selectedPiece.value.pos.col] = null;
    // 移动棋子
    sourcePoint.value = Point(
      row: selectedPiece.value.pos.row,
      col: selectedPiece.value.pos.col,
    );
    selectedPiece.value.pos.row = newRow;
    selectedPiece.value.pos.col = newCol;
    chessBoard[newRow][newCol] = copyPiece(selectedPiece.value);
    placedPiece.value = selectedPiece.value;

    clearAvailableMove(); // 移动后清除可用移动点
    resetSelectedPiece(); // 移动后重置选中棋子
    turnTransition(); // 切换回合

    // 判断是否处于绝杀状态
    isInCheckMateNotifier.value = checkmate(playerInfo['opponent']);
    if (isInCheckMateNotifier.value == true) {
      Future.delayed(Duration(milliseconds: 3500), () {
        overGame('胜', 'checkmate');
      });
      return;
    }

    // 判断是否将军;
    isInCheckNotifier.value = isInCheckMateNotifier.value
        ? false
        : check(playerInfo['opponent'], pieces, chessBoard);

    print('是否我方绝杀: ${isInCheckMateNotifier.value}');
    print('是否我方将军: ${isInCheckNotifier.value}');
  }

  // 移动对方棋子
  void moveOpponentPiece(Point from, Point to) {
    print('moveOpponentPiece');
    if (to.row > 9 || to.row < 0 || to.col > 8 || to.col < 0) {
      return;
    }
    sourcePoint.value = Point(row: from.row, col: from.col);
    capturePiece(to.row, to.col);
    for (var piece in pieces) {
      if (piece.pos.row == from.row && piece.pos.col == from.col) {
        chessBoard[from.row][from.col] = null;
        piece.pos.row = to.row;
        piece.pos.col = to.col;
        placedPiece.value = piece;
        chessBoard[to.row][to.col] = copyPiece(piece);
        break;
      }
    }

    // 判断是否处于绝杀状态
    isInCheckMateNotifier.value = checkmate(playerInfo['me']);
    print('是否对方绝杀: ${isInCheckMateNotifier.value}');
    if (isInCheckMateNotifier.value == true) {
      Future.delayed(Duration(milliseconds: 3500), () {
        overGame('败', 'checkmate');
      });
      return;
    }

    // 判断是否将军;
    isInCheckNotifier.value = check(playerInfo['me'], pieces, chessBoard);
    print('是否对方将军: ${isInCheckNotifier.value}');
  }

  // 模拟移动棋子
  void emulatePieces(
    List<ChineseChessPieceModel> prePieces,
    List<List<dynamic>> preChessBoard,
    ChineseChessPieceModel piece,
    Point point,
  ) {
    // 1. 如果目标点有棋子（吃子），删除它
    prePieces.removeWhere(
      (p) => p.pos.row == point.row && p.pos.col == point.col,
    );

    // 2. 找到要移动的棋子，并更新它的位置
    ChineseChessPieceModel? movingPiece;
    for (var p in prePieces) {
      if (p.type == piece.type &&
          p.isRed == piece.isRed &&
          p.pos.row == piece.pos.row &&
          p.pos.col == piece.pos.col) {
        p.pos = Point(row: point.row, col: point.col); // 更新位置
        movingPiece = p;
        break;
      }
    }

    // 3. 更新棋盘
    preChessBoard[piece.pos.row][piece.pos.col] = null;
    if (movingPiece != null) {
      preChessBoard[point.row][point.col] = movingPiece;
    }
  }

  // 计算可移动点
  List<Point> canMovePoint(
    ChineseChessPieceModel piece,
    List<List<dynamic>> preChessBoard,
  ) {
    List<Point> canMove = [];

    switch (piece.type) {
      case '車':
        for (int i = piece.pos.col + 1; i < 9; i++) {
          if (preChessBoard[piece.pos.row][i] == null ||
              preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
            canMove.add(Point(row: piece.pos.row, col: i));
            if (preChessBoard[piece.pos.row][i] != null &&
                preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
              break;
            }
          } else {
            break;
          }
        }
        for (int i = piece.pos.col - 1; i >= 0; i--) {
          if (preChessBoard[piece.pos.row][i] == null ||
              preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
            canMove.add(Point(row: piece.pos.row, col: i));

            if (preChessBoard[piece.pos.row][i] != null &&
                preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
              break;
            }
          } else {
            break;
          }
        }
        for (int i = piece.pos.row + 1; i < 10; i++) {
          if (preChessBoard[i][piece.pos.col] == null ||
              preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
            canMove.add(Point(row: i, col: piece.pos.col));

            if (preChessBoard[i][piece.pos.col] != null &&
                preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
              break;
            }
          } else {
            break;
          }
        }
        for (int i = piece.pos.row - 1; i >= 0; i--) {
          if (preChessBoard[i][piece.pos.col] == null ||
              preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
            canMove.add(Point(row: i, col: piece.pos.col));

            if (preChessBoard[i][piece.pos.col] != null &&
                preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
              break;
            }
          } else {
            break;
          }
        }
        break;
      case '馬':
        List<int> drow = [-1, -2, -2, -1, 1, 2, 2, 1];
        List<int> dcol = [-2, -1, 1, 2, 2, 1, -1, -2];
        List<int> horse_feet_row = [0, -1, -1, 0, 0, 1, 1, 0];
        List<int> horse_feet_col = [-1, 0, 0, 1, 1, 0, 0, -1];
        for (int i = 0; i < 8; i++) {
          int row = piece.pos.row + drow[i];
          int col = piece.pos.col + dcol[i];
          int feet_row = piece.pos.row + horse_feet_row[i];
          int feet_col = piece.pos.col + horse_feet_col[i];
          if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
            if (preChessBoard[row][col] == null ||
                preChessBoard[row][col].isRed != piece.isRed) {
              if (preChessBoard[feet_row][feet_col] == null) {
                canMove.add(Point(row: row, col: col));
              }
            }
          }
        }
        break;
      case '相' || '象':
        List<int> drow = [-2, -2, 2, 2];
        List<int> dcol = [-2, 2, -2, 2];
        List<int> elephant_feet_row = [-1, -1, 1, 1];
        List<int> elephant_feet_col = [-1, 1, -1, 1];
        for (int i = 0; i < 4; i++) {
          int row = piece.pos.row + drow[i];
          int col = piece.pos.col + dcol[i];
          int feet_row = piece.pos.row + elephant_feet_row[i];
          int feet_col = piece.pos.col + elephant_feet_col[i];
          if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
            if (piece.pos.row < 5 && row < 5 ||
                piece.pos.row >= 5 && row >= 5) {
              if (preChessBoard[row][col] == null ||
                  preChessBoard[row][col].isRed != piece.isRed) {
                if (feet_row >= 0 &&
                    feet_row <= 9 &&
                    feet_col >= 0 &&
                    feet_col < 9 &&
                    preChessBoard[feet_row][feet_col] == null) {
                  canMove.add(Point(row: row, col: col));
                }
              }
            }
          }
        }
        break;
      case '仕':
        List<int> drow = [-1, -1, 1, 1];
        List<int> dcol = [-1, 1, 1, -1];
        for (int i = 0; i < 4; i++) {
          int row = drow[i] + piece.pos.row;
          int col = dcol[i] + piece.pos.col;
          if (row <= 9 && row >= 7 && col >= 3 && col <= 5 ||
              row >= 0 && row <= 2 && col >= 3 && col <= 5) {
            if (preChessBoard[row][col] == null ||
                preChessBoard[row][col].isRed != piece.isRed) {
              canMove.add(Point(row: row, col: col));
            }
          }
        }
        break;
      case '帥' || '將':
        List<int> drow = [-1, 0, 1, 0];
        List<int> dcol = [0, 1, 0, -1];
        for (int i = 0; i < 4; i++) {
          int row = drow[i] + piece.pos.row;
          int col = dcol[i] + piece.pos.col;
          if ((row >= 7 && row <= 9 || row >= 0 && row <= 2) &&
              col >= 3 &&
              col <= 5) {
            if (preChessBoard[row][col] == null ||
                preChessBoard[row][col].isRed != piece.isRed) {
              canMove.add(Point(row: row, col: col));
            }
          }
        }
        // 两方不能照将
        for (
          int i = piece.pos.row + (piece.pos.row <= 2 ? 1 : -1);
          piece.pos.row <= 2 ? i <= 9 : i >= 0;
          piece.pos.row <= 2 ? i++ : i--
        ) {
          if (preChessBoard[i][piece.pos.col] != null &&
              preChessBoard[i][piece.pos.col].type != '帥' &&
              preChessBoard[i][piece.pos.col].type != '將') {
            break;
          } else if (preChessBoard[i][piece.pos.col] != null &&
              (preChessBoard[i][piece.pos.col].type == '帥' ||
                  preChessBoard[i][piece.pos.col].type == '將')) {
            canMove.add(Point(row: i, col: piece.pos.col));
            break;
          }
        }
        break;
      case '炮':
        for (int i = piece.pos.col + 1, battery = 0; i < 9; i++) {
          if (preChessBoard[piece.pos.row][i] == null) {
            if (battery == 0) {
              canMove.add(Point(row: piece.pos.row, col: i));
            }
          } else if (battery == 0) {
            battery++;
          } else if (battery == 1) {
            if (preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
              canMove.add(Point(row: piece.pos.row, col: i));
            }
            break;
          }
        }
        for (int i = piece.pos.col - 1, battery = 0; i >= 0; i--) {
          if (preChessBoard[piece.pos.row][i] == null) {
            if (battery == 0) {
              canMove.add(Point(row: piece.pos.row, col: i));
            }
          } else if (battery == 0) {
            battery++;
          } else if (battery == 1) {
            if (preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
              canMove.add(Point(row: piece.pos.row, col: i));
            }
            break;
          }
        }
        for (int i = piece.pos.row + 1, battery = 0; i < 10; i++) {
          if (preChessBoard[i][piece.pos.col] == null) {
            if (battery == 0) {
              canMove.add(Point(row: i, col: piece.pos.col));
            }
          } else if (battery == 0) {
            battery++;
          } else if (battery == 1) {
            if (preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
              canMove.add(Point(row: i, col: piece.pos.col));
            }
            break;
          }
        }
        for (int i = piece.pos.row - 1, battery = 0; i >= 0; i--) {
          if (preChessBoard[i][piece.pos.col] == null) {
            if (battery == 0) {
              canMove.add(Point(row: i, col: piece.pos.col));
            }
          } else if (battery == 0) {
            battery++;
          } else if (battery == 1) {
            if (preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
              canMove.add(Point(row: i, col: piece.pos.col));
            }
            break;
          }
        }
        break;
      case '兵':
        if (playerInfo['me']['isRed'] == true) {
          List<int> drow = [-1, 0, 0];
          List<int> dcol = [0, 1, -1];
          for (int i = 0; i < 3; i++) {
            int row = drow[i] + piece.pos.row;
            int col = dcol[i] + piece.pos.col;
            if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
              if (row == piece.pos.row) {
                if (row <= 4) {
                  canMove.add(Point(row: row, col: col));
                }
              } else {
                canMove.add(Point(row: row, col: col));
              }
            }
          }
        } else {
          List<int> drow = [1, 0, 0];
          List<int> dcol = [0, 1, -1];
          for (int i = 0; i < 3; i++) {
            int row = drow[i] + piece.pos.row;
            int col = dcol[i] + piece.pos.col;
            if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
              if (row == piece.pos.row) {
                if (row >= 5) {
                  canMove.add(Point(row: row, col: col));
                }
              } else {
                canMove.add(Point(row: row, col: col));
              }
            }
          }
        }
        break;
      case '卒':
        if (playerInfo['me']['isRed'] == false) {
          List<int> drow = [-1, 0, 0];
          List<int> dcol = [0, 1, -1];
          for (int i = 0; i < 3; i++) {
            int row = drow[i] + piece.pos.row;
            int col = dcol[i] + piece.pos.col;
            if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
              if (row == piece.pos.row) {
                if (row <= 4) {
                  canMove.add(Point(row: row, col: col));
                }
              } else {
                canMove.add(Point(row: row, col: col));
              }
            }
          }
        } else {
          List<int> drow = [1, 0, 0];
          List<int> dcol = [0, 1, -1];
          for (int i = 0; i < 3; i++) {
            int row = drow[i] + piece.pos.row;
            int col = dcol[i] + piece.pos.col;
            if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
              if (row == piece.pos.row) {
                if (row >= 5) {
                  canMove.add(Point(row: row, col: col));
                }
              } else {
                canMove.add(Point(row: row, col: col));
              }
            }
          }
        }
        break;
    }
    return canMove;
  }

  // 吃掉棋子
  void capturePiece(int row, int col) {
    pieces.removeWhere((p) => p.pos.row == row && p.pos.col == col);
    if (chessBoard[row][col] != null) {
      capturedPiece = copyPiece(chessBoard[row][col]);
    } else {
      capturedPiece = ChineseChessPieceModel(
        type: '',
        isRed: false,
        pos: Point(row: -1, col: -1),
      );
    }
    chessBoard[row][col] = null;
  }

  // 复制棋子
  ChineseChessPieceModel copyPiece(ChineseChessPieceModel piece) {
    return ChineseChessPieceModel(
      type: piece.type,
      isRed: piece.isRed,
      pos: Point(row: piece.pos.row, col: piece.pos.col),
    );
  }

  //判断是否将军
  bool check(
    Map<String, dynamic> side,
    List<ChineseChessPieceModel> prePieces,
    List<List<dynamic>> preChessBoard,
  ) {
    Point kingPos = Point(row: 0, col: 0);
    print('side,${side['isRed'].value}');
    // 找到红方或黑方的帥或將
    for (var p in prePieces) {
      if (p.isRed == side['isRed'].value) {
        if (p.isRed == true) {
          if (p.type == '帥') {
            print('帥');
            kingPos = p.pos;
            break;
          }
        } else {
          if (p.type == '將') {
            print('將');
            kingPos = p.pos;
            break;
          }
        }
      }
    }

    // print('KingPos,${kingPos.row},${kingPos.col}');

    return prePieces.any((piece) {
      if (piece.isRed != side['isRed'].value) {
        return canMovePoint(piece, preChessBoard).any((p) {
          if (p.row == kingPos.row && p.col == kingPos.col) {
            print(
              'eatKing:${piece.type},${piece.isRed},${piece.pos.row},${piece.pos.col} to ${p.row},${p.col}',
            );
            print('KingPos,${kingPos.row},${kingPos.col}');
            return true;
          }
          return false;
        });
      } else {
        return false;
      }
    });
  }

  //判断是否送将
  bool sendKing(ChineseChessPieceModel piece, Point point) {
    // piece:棋子,point:目标位置
    List<ChineseChessPieceModel> prePieces = [];
    List<List<dynamic>> preChessBoard = List.generate(
      10,
      (i) => List.generate(9, (j) => null),
    );

    // 复制一份棋子和棋盘
    for (var p in pieces) {
      prePieces.add(copyPiece(p));
      preChessBoard[p.pos.row][p.pos.col] = copyPiece(p);
    }

    // 模拟将棋子移动到目标位置
    emulatePieces(prePieces, preChessBoard, piece, point);

    bool isInCheck = check(
      playerInfo['me']['myTurn'].value == true
          ? playerInfo['me']
          : playerInfo['opponent'],
      prePieces,
      preChessBoard,
    );
    // if (!isInCheck) {
    //   print(
    //     prePieces
    //         .map((p) => '${p.type},${p.isRed},${p.pos.row},${p.pos.col}')
    //         .join('\n'),
    //   );
    //   for (int i = 0; i < preChessBoard.length; i++) {
    //     String row = '';
    //     for (int j = 0; j < preChessBoard[i].length; j++) {
    //       final piece = preChessBoard[i][j];
    //       row += (piece != null ? '${piece.type} ' : '· ') + '  '; // 用·表示空位
    //     }
    //     print(row);
    //   }
    // }
    return isInCheck;
  }

  //判断side方是否被绝杀
  bool checkmate(Map<String, dynamic> side) {
    for (var p in pieces) {
      //查找同一方的棋子
      if (p.isRed == side['isRed'].value) {
        List<Point> avalibleMove = canMovePoint(p, chessBoard);
        for (var point in avalibleMove) {
          bool isSendKing = sendKing(p, point);
          print('sendKing:${isSendKing}');
          if (!isSendKing) {
            print(
              'save:${p.type},${p.isRed},${p.pos.row},${p.pos.col} => ${point.row},${point.col}',
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  // 开始匹配
  void startMatching() async {
    stage.value = GameStage.matching;
    initplayerInfo();

    // 等待一次匹配成功
    _matchSubscription?.cancel();
    _matchSubscription = socketService.onMatchSuccess.listen((data) {
      print('okok');
      // print("匹配成功 => $data");
      print('match end:');
      GlobalData.isPlaying = true;
      stage.value = GameStage.playing;
      matchSuccess(data);
      initChessBoard();
    });
    matching();
  }

  // 匹配请求
  void matching() async {
    print('开始匹配');
    if (opponentAccountId != '空座') {
      socketService.sendReady(opponentAccountId);
    }

    final Map<String, dynamic> params = {
      'player': {
        'accountId': playerInfo['me']['accountId'],
        'username': playerInfo['me']['username'],
        'avatar': playerInfo['me']['avatar'],
        'level': playerInfo['me']['level'],
        'isRed': false,
        'timeLeft': gameTime.value,
      },
      'type': '$type',
      'aiLevel': aiLevel,
      'inviter': '${opponentAccountId == '空座' ? '' : opponentAccountId}',
    };
    socketService.sendMatchRequest(params['type'], params);
  }

  // 匹配成功
  void matchSuccess(Map<String, dynamic> data) {
    print('myTurn:${playerInfo['me']['myTurn'].value}');
    Map<String, dynamic> player1 = data['player1'];
    Map<String, dynamic> player2 = data['player2'];
    roomId = data['roomId'];
    if (player1['accountId'] != GlobalData.userInfo['accountId']) {
      playerInfo['opponent']['accountId'].value = player1['accountId'];
      playerInfo['opponent']['username'].value = player1['username'];
      playerInfo['opponent']['avatar'].value = player1['avatar'];
      playerInfo['opponent']['level'].value = player1['level'];
      playerInfo['opponent']['isRed'].value = player1['isRed'];
      playerInfo['opponent']['myTurn'].value = player1['isRed'];
      playerInfo['me']['isRed'].value = player2['isRed'];
      playerInfo['me']['myTurn'].value = player2['isRed'];
    } else {
      playerInfo['opponent']['accountId'].value = player2['accountId'];
      playerInfo['opponent']['username'].value = player2['username'];
      playerInfo['opponent']['avatar'].value = player2['avatar'];
      playerInfo['opponent']['level'].value = player2['level'];
      playerInfo['opponent']['isRed'].value = player2['isRed'];
      playerInfo['opponent']['myTurn'].value = player2['isRed'];
      playerInfo['me']['isRed'].value = player1['isRed'];
      playerInfo['me']['myTurn'].value = player1['isRed'];
    }
    playerInfo['me']['myTurn'].refresh();
    playerInfo['opponent']['myTurn'].refresh();
    print(
      'myTurn:${playerInfo['me']['myTurn'].value},opponent:${playerInfo['opponent']['myTurn'].value}',
    );
  }

  // 发送我方落子信息
  void sendMyMove(String type, Point from, Point to) async {
    final Map<String, dynamic> params = {
      'roomId': roomId,
      'step': {
        'accountId': playerInfo['me']['accountId'],
        'type': type,
        'from': {'row': from.row, 'col': from.col},
        'to': {'row': to.row, 'col': to.col},
        'timeLeft': playerInfo['me']['timeLeft'].value,
      },
    };
    moves.add(params['step']);
    socketService.sendMove(params);
  }

  // 获取对方落子
  void getOpponentMove(Map<String, dynamic> moveData) async {
    if(stage.value != GameStage.playing){
      return;
    }
    print('moveData,$moveData');
    final data = moveData['step'];
    print('data,$data');
    // 如果不是对方的操作，则忽略
    if (data['accountId'] != playerInfo['opponent']['accountId'].value) {
      print(
        '${data['accountId']}不是${playerInfo['opponent']['accountId'].value}',
      );
      return;
    }
    playerInfo['opponent']['timeLeft'].value = (data['timeLeft'] != null)
        ? data['timeLeft'].round()
        : playerInfo['opponent']['timeLeft'].value;

    moves.add(data);
    print('moves:${moves.length}');

    num row = 9 - data['from']['row'].toInt();
    num col = 8 - data['from']['col'].toInt();
    Point from = Point(row: row.toInt(), col: col.toInt());
    moves[moves.length - 1]['from']['row'] = row.toInt();
    moves[moves.length - 1]['from']['col'] = col.toInt();
    row = 9 - data['to']['row'].toInt();
    col = 8 - data['to']['col'].toInt();
    Point to = Point(row: row.toInt(), col: col.toInt());
    moves[moves.length - 1]['to']['row'] = row.toInt();
    moves[moves.length - 1]['to']['col'] = col.toInt();
    print('movePiece,${moves[moves.length - 1]}');
    turnTransition(); // 切换回合
    moveOpponentPiece(from, to);
  }

  // 接受对方信息
  void receiveText(Map<String, dynamic> message) {
    if (message['accountId'] != playerInfo['opponent']['accountId'].value) {
      print(
        '${message['accountId']}不是${playerInfo['opponent']['accountId'].value}',
      );
      return;
    }
    chatHistory.add({
      'accountId': playerInfo['opponent']['accountId'],
      'text': message['text'],
    });
    if (message['text'] != '') {
      opponentChatMessage.value = message['text'];
      playerInfo['opponent']['showMessage'].value = true;
      Future.delayed(const Duration(milliseconds: 5000), () {
        playerInfo['opponent']['showMessage'].value = false;
      });
    }
  }

  //处理对方动作
  void receiveActions(Map<String, dynamic> action) {
    if (action['accountId'] != playerInfo['opponent']['accountId'].value) {
      print(
        '${action['accountId']}不是${playerInfo['opponent']['accountId'].value}',
      );
      return;
    }
    if (action['type'] == '请求悔棋') {
      dealOpponentUndo();
    } else if (action['type'] == '请求和棋') {
      dealOpponentDraw();
    } else if (action['type'] == '同意和棋') {
      Get.back();
      overGame('和', 'draw');
    } else if (action['type'] == '同意悔棋') {
      Get.back();
      undo();
    } else if (action['type'] == '拒绝悔棋' || action['type'] == '拒绝和棋') {
      Get.back();
      Get.dialog(
        ShowMessageDialog(content: '对方${action['type']}请求'),
        barrierColor: Colors.transparent,
        barrierDismissible: false,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back();
      });
    } else if (action['type'] == '认输') {
      dealOpponentSurrender();
    }
  }

  // 后端推送邀请通知给好友
  Future<void> sendInvitation(String accountId) async {
    final Map<String, dynamic> params = {
      'accountId': GlobalData.userInfo['accountId'],
      'invitation': {
        'accountId': accountId,
        'type': type,
        'gameTime': gameTime.value,
        'stepTime': stepTime.value,
      },
    };
    Dio dio = new Dio();
    try {
      final response = await dio.post(
        '${GlobalData.url}/SendInvitation',
        data: params,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.data['code'] == 0) {
        print('发送邀请成功');
        Get.dialog(
          ShowMessageDialog(content: '发送邀请成功'),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.back();
        });
      }
    } catch (e) {
      print('发送邀请失败:$e');
    }
  }

  // 悔棋操作
  void undo() {
    print('悔棋操作');
    for (var move in moves.reversed) {
      Point from = Point(row: move['to']['row'], col: move['to']['col']);
      Point to = Point(row: move['from']['row'], col: move['from']['col']);
      placedPiece.value.pos.row = to.row;
      placedPiece.value.pos.col = to.col;
      chessBoard[to.row][to.col] = copyPiece(placedPiece.value);
      if (capturedPiece.type != '') {
        pieces.add(copyPiece(capturedPiece));
        chessBoard[from.row][from.col] = copyPiece(capturedPiece);
      } else {
        chessBoard[from.row][from.col] = null;
      }
      selectedPiece.value = ChineseChessPieceModel(
        type: '',
        isRed: false,
        pos: Point(row: -1, col: -1),
      );
      placedPiece.value = ChineseChessPieceModel(
        type: '',
        isRed: false,
        pos: Point(row: -1, col: -1),
      );
      sourcePoint.value = Point(row: -1, col: -1);
      break;
    }
    turnTransition();
    moves.clear();
  }

  // 请求悔棋
  void requestUndo() async {
    if (stage.value != GameStage.playing) {
      return;
    }
    if (playerInfo['opponent']['myTurn'].value == true) {
      bool hasUndo = false;
      for (var move in moves) {
        if (move['accountId'] == playerInfo['me']['accountId'] &&
            move['from']['row'] != -1 &&
            move['from']['col'] != -1) {
          hasUndo = true;
          break;
        }
      }
      if (!hasUndo) {
        return;
      }
      if (requestUndoCnt == 0) {
        Get.dialog(
          LoadingDialog(content: '请求对方悔棋中'),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );
        requestUndoCnt++;
        socketService.sendActions({
          'type': '请求悔棋',
          'accountId': GlobalData.userInfo['accountId'],
          'roomId': roomId,
        });
      } else {
        Get.dialog(
          ShowMessageDialog(content: '每个回合只能请求一次'),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.back();
          print('Get.back()');
        });
      }
    } else {
      Get.dialog(
        ShowMessageDialog(content: '我方回合不可悔棋'),
        barrierColor: Colors.transparent,
        barrierDismissible: false,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back();
        print('Get.back()');
      });
    }
  }

  // 请求和棋
  void requestDraw() async {
    if (stage.value != GameStage.playing) {
      return;
    }
    if (requestDrawCnt == 0) {
      if (type.contains('Ai')) {
        overGame('和', 'draw');
      } else {
        Get.dialog(
          LoadingDialog(content: '请求对方和棋中'),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );
        requestDrawCnt++;
        socketService.sendActions({
          'type': '请求和棋',
          'accountId': GlobalData.userInfo['accountId'],
        });
      }
    } else {
      Get.dialog(
        ShowMessageDialog(content: '每个回合只能请求一次'),
        barrierColor: Colors.transparent,
        barrierDismissible: false,
      );
      Future.delayed(Duration(milliseconds: 1500), () {
        Get.back();
        print('Get.back()');
      });
    }
  }

  // 认输
  void surrender() {
    if (stage.value != GameStage.playing) {
      return;
    }
    Get.dialog(
      ConfirmDialog(
        content: '确定认输吗',
        confirmText: '确定',
        cancelText: '取消',
        onConfirm: () {
          Get.back();
          print('Get.back()');
          socketService.sendActions({
            'type': '认输',
            'accountId': GlobalData.userInfo['accountId'],
            'roomId': roomId,
          });
          overGame('败', 'surrender');
        },
        onCancel: () {
          Get.back();
          print('Get.back()');
        },
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );
  }

  // 处理对方悔棋请求
  void dealOpponentUndo() {
    print('对方请求悔棋');
    Get.dialog(
      ConfirmDialog(
        content: '对方请求悔棋',
        confirmText: '同意',
        cancelText: '拒绝',
        onConfirm: () {
          Get.back();
          print('Get.back()');
          acceptOpponentUndo();
        },
        onCancel: () {
          Get.back();
          print('Get.back()');
          rejectOpponentUndo();
        },
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );
  }

  // 接受对方悔棋
  void acceptOpponentUndo() async {
    socketService.sendActions({
      'accountId': playerInfo['me']['accountId'],
      'type': '同意悔棋',
      'roomId': roomId,
    });
    undo();
  }

  // 拒绝对方悔棋
  void rejectOpponentUndo() {
    socketService.sendActions({
      'accountId': playerInfo['me']['accountId'],
      'type': '拒绝悔棋',
      'roomId': roomId,
    });
  }

  // 处理对方和棋请求
  void dealOpponentDraw() {
    print("对方请求和棋");
    Get.dialog(
      ConfirmDialog(
        content: '对方请求和棋',
        confirmText: '同意',
        cancelText: '拒绝',
        onConfirm: () {
          Get.back();
          acceptOpponentDraw();
        },
        onCancel: () {
          Get.back();
          print('Get.back()');
          rejectOpponentDraw();
        },
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );
  }

  // 接受对方和棋请求
  void acceptOpponentDraw() async {
    socketService.sendActions({
      'accountId': playerInfo['me']['accountId'],
      'type': '同意和棋',
      'roomId': roomId,
    });
    overGame('和', 'draw');
  }

  // 拒绝对方和棋请求
  void rejectOpponentDraw() {
    socketService.sendActions({
      'accountId': playerInfo['me']['accountId'],
      'type': '拒绝和棋',
      'roomId': roomId,
    });
  }

  // 处理对方认输
  void dealOpponentSurrender() {
    Get.dialog(
      ShowMessageDialog(content: '对方认输'),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );
    Future.delayed(const Duration(milliseconds: 1000), () {
      Get.back();
      print('Get.back()');
      overGame('胜', 'surrender');
    });
  }

  // 游戏结束
  void overGame(String res, String reason) async {
    print('res,$res,reason,$reason');
    GlobalData.isPlaying = false;
    Dio dio = Dio();
    final Map<String, dynamic> params = {
      'roomId': roomId,
      'type': type,
      'result': {
        'winner': res == '胜'
            ? playerInfo['me']['accountId']
            : res == '败'
            ? playerInfo['opponent']['accountId'].value
            : '和',
        'reason': reason,
      },
    };
    try {
      final response = await dio.post(
        '${GlobalData.url}/WritingResult',
        data: params,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print(response.data['msg']);
    } catch (e) {
      print('写入结果出错: $e');
    }
    GlobalData.userInfo['activity'] += 10;
    GlobalData.userInfo['ChineseChess']['levelBar'] += res == '胜'
        ? 10
        : res == '败'
        ? -10
        : 0;
    if (GlobalData.userInfo['ChineseChess']['levelBar'] > 100) {
      GlobalData.userInfo['ChineseChess']['levelBar'] %= 100;
      final level = GlobalData.userInfo['ChineseChess']['level'].split('-');
      int level1 = int.parse(level[1]);
      int level0 = int.parse(level[0]);
      level1 += 1;
      if (level1 > 3) {
        level1 = 1;
        level0 += 1;
      }
      GlobalData.userInfo['ChineseChess']['level'] = '$level0-$level1';
    }

    // 取消监听
    _moveSubscription?.cancel();
    _moveSubscription = null;
    _moveListenerInitialized = false;

    stage.value = GameStage.over;
    result = res;
    selectedPiece.value = ChineseChessPieceModel(
      type: '',
      isRed: false,
      pos: Point(row: -1, col: -1),
    );
    placedPiece.value = copyPiece(selectedPiece.value);
    stopTimer();
    print('res,$res');
  }

  // 回合转换
  void turnTransition() {
    stopTimer();
    playerInfo['me']['myTurn'].value = !playerInfo['me']['myTurn'].value;
    playerInfo['opponent']['myTurn'].value =
        !playerInfo['opponent']['myTurn'].value;

    myStepTime.value = stepTime.value;
    opponentStepTime.value = stepTime.value;
  }

  // 开始计局时和步时
  void startTimer(RxInt time, RxInt stepTime, bool myTurn) async {
    stopTimer();
    if (_gametimer != null) {
      print('_gametimer!= null');
    }
    _gametimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time.value > 0 && stepTime.value > 0) {
        // print('${time.value},${stepTime.value}');
        time.value--;
        stepTime.value--;
      } else {
        stopTimer();
        if (myTurn == true) {
          Get.dialog(
            ShowMessageDialog(content: '我方超时'),
            barrierColor: Colors.transparent,
            barrierDismissible: false,
          );
          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.back();
            print('Get.back()');
            overGame('败', 'timeOut');
          });
        } else {
          Get.dialog(
            ShowMessageDialog(content: '对方超时'),
            barrierColor: Colors.transparent,
            barrierDismissible: false,
          );
          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.back();
            overGame('胜', 'timeOut');
          });
        }
        print('时间耗尽，游戏结束');
      }
    });
  }

  // 停止所有计数器
  void stopTimer() {
    print('stopTimer');
    _gametimer?.cancel();
    _gametimer = null;
    _moveRequestTimer?.cancel();
    _moveRequestTimer = null;
    _matchTimer?.cancel();
    _matchTimer = null;
  }
}

enum GameStage { idle, matching, playing, over }
