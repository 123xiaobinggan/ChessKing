import 'package:get/get.dart';
import '../../pages/Tabbar/tabbar.dart';
import '../../pages/Index/index.dart';
import '/pages/MyInfo/my_info.dart';
import '../bindings/tabbar.dart';
import '../bindings/index.dart';
import '../bindings/my_info.dart';
import '../bindings/login.dart';
import '../bindings/register.dart';
import '../bindings/my_friends.dart';
import '../bindings/edit.dart';
import '../bindings/version.dart';
import '../bindings/level.dart';
import '../bindings/Chinese_chess.dart';
import '../bindings/Chinese_chess_match.dart';
import '../bindings/Chinese_chess_rank.dart';
import '../bindings/Chinese_chess_challenge.dart';
import '../bindings/Chinese_chess_board.dart';
import '../bindings/recharge.dart';
import '../bindings/game_record.dart';
import '../bindings/game_replay.dart';
import '../bindings/messages.dart';
import '../bindings/chat_window.dart';
import '../bindings/conversation.dart';

import '../../pages/Version/version.dart';
import '../../pages/Enter/Login/login.dart';
import '../../pages/Enter/Register/register.dart';
import '../../pages/MyFriends/my_friends.dart';
import '../../pages/Edit/edit.dart';
import '../../pages/Level/level.dart';
import '../../pages/ChineseChess/Chinese_chess.dart';
import '../../pages/ChineseChessMatch/Chinese_chess_match.dart';
import '../../pages/ChineseChessRank/Chinese_chess_rank.dart';
import '../../pages/ChineseChessChallenge/Chinese_chess_challenge.dart';
import '../../pages/ChineseChessBoard/chinese_chess_board.dart';
import '../../pages/Recharge/recharge.dart';
import '../../pages/GameRecord/game_record.dart';
import '../../pages/GameReplay/game_replay.dart';
import '../../pages/Conversation/conversation.dart';
import '../../pages/ChatWindow/chat_window.dart';

class AppRoutes {
  static final Login = "/";
  static final Register = "/Register";
  static final Tabbar = "/Tabbar";
  static final Index = "/Index";
  static final MyInfo = "/MyInfo";
  static final MyFriends = "/MyFriends";
  static final Edit = "/Edit";
  static final Version = "/Version";
  static final Level = "/Level";
  static final ChineseChess = "/ChineseChess";
  static final ChineseChessMatch = "/ChineseChessMatch";
  static final ChineseChessRank = "/ChineseChessRank";
  static final ChineseChessChallenge = "/ChineseChessChallenge";
  static final ChineseChessBoard = "/ChineseChessBoard";
  static final Recharge = "/Recharge";
  static final GameRecord = "/GameRecord";
  static final GameReplay = "/GameReplay";
  static final Messages = "/Messages";
  static final ChatWindow = "/ChatWindow";
  static final Conversations = "/Conversations";
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.Login,
      page: () => Login(),
      binding: LoginBindings(),
    ),
    GetPage(
      name: AppRoutes.Register,
      page: () => Register(),
      binding: RegisterBindings(),
    ),
    GetPage(
      name: AppRoutes.Tabbar,
      page: () => Tabbar(),
      binding: TabbarBindings(),
    ),
    GetPage(
      name: AppRoutes.Index,
      page: () => Index(),
      binding: IndexBindings(),
    ),
    GetPage(
      name: AppRoutes.MyInfo,
      page: () => MyInfo(),
      binding: MyInfoBindings(),
    ),
    GetPage(
      name: AppRoutes.MyFriends,
      page: () => MyFriends(),
      binding: MyFriendsBindings(),
    ),
    GetPage(name: AppRoutes.Edit, page: () => Edit(), binding: EditBindings()),
    GetPage(
      name: AppRoutes.Version,
      page: () => Version(),
      binding: VersionBindings(),
    ),
    GetPage(
      name: AppRoutes.Level,
      page: () => Level(),
      binding: LevelBindings(),
    ),
    GetPage(
      name: AppRoutes.ChineseChess,
      page: () => ChineseChess(),
      binding: ChineseChessBindings(),
    ),
    GetPage(
      name: AppRoutes.ChineseChessMatch,
      page: () => ChineseChessMatch(),
      binding: ChineseChessMatchBindings(),
    ),
    GetPage(
      name: AppRoutes.ChineseChessRank,
      page: () => ChineseChessRank(),
      binding: ChineseChessRankBindings(),
    ),
    GetPage(
      name: AppRoutes.ChineseChessChallenge,
      page: () => ChineseChessChallenge(),
      binding: ChineseChessChallengeBindings(),
    ),
    GetPage(
      name: AppRoutes.ChineseChessBoard,
      page: () => ChineseChessBoard(),
      binding: ChineseChessBoardBindings(tag: Get.parameters['tag'] ?? ''),
    ),
    GetPage(
      name: AppRoutes.Recharge,
      page: () => Recharge(),
      binding: RechargeBindings(),
    ),
    GetPage(
      name: AppRoutes.GameRecord,
      page: () => GameRecord(),
      binding: GameRecordBindings(),
    ),
    GetPage(
      name: AppRoutes.GameReplay,
      page: () => GameReplay(),
      binding: GameReplayBindings(),
    ),
    GetPage(
      name: AppRoutes.Messages,
      page: () => Conversations(),
      binding: ConversationsBindings(),
    ),
    GetPage(
      name: AppRoutes.ChatWindow,
      page: () => ChatWindow(),
      binding: ChatWindowBindings(),
    ),
    GetPage(
      name: AppRoutes.Conversations,
      page: () => Conversations(),
      binding: ConversationsBindings(),
    )
  ];
}
