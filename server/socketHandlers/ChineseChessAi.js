const { ObjectId } = require('bson');
const { pikafish, boardToFEN, uciToMove } = require('../pikafish.js')
const pieces = ['車', '馬', '相', '象', '仕', '將', '帥', '炮', '兵', '卒'];

module.exports = (io, socket, roomCollection) => {
  socket.on("ChineseChessAi", async (params) => {
    console.log('ChineseChessAi收到消息:', params);
    try {
      const player = { id: socket.id, ...params["player"] };
      const aiLevel = params["aiLevel"];

      console.log("请求 AI 对战", player["accountId"], "AI 等级:", aiLevel);

      // 随机决定谁是红方
      const isRed = Math.random() > 0.5;
      player.isRed = isRed;

      // 构造一个 AI 虚拟玩家
      const aiPlayer = {
        accountId: "AI_" + aiLevel,
        username: "AI Lv." + aiLevel,
        avatar: "https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/ai.png",
        isRed: !player.isRed,
        timeMode: player['timeLeft'],
        level: aiLevel
      };

      // 创建房间文档
      const newRoom = {
        player1: player,
        player2: aiPlayer,
        type: "ChineseChessAi",
        timeMode: player['timeLeft'],
        status: "playing",
        moves: [],
        result: { winner: null, reason: null },
        createdAt: Date.now(),
        board: initialBoard()
      };

      const res = await roomCollection.insertOne(newRoom);
      const roomId = res.insertedId.toString();
      const socketRoomId = roomId;

      // 玩家加入房间
      socket.join(socketRoomId);
      socket.data.accountId = params['player']['accountId'];
      socket.data.socketRoomId = socketRoomId;

      // 通知客户端匹配成功
      socket.emit("match_success", {
        roomId,
        player1: player,
        player2: aiPlayer,
        socketRoomId
      });

      //调用ai模型下第一步
      if (aiPlayer.isRed) {
        const fen = boardToFEN(newRoom.board, newRoom.player2.isRed);
        console.log('fen', fen);
        const aiMove = uciToMove(await pikafish(fen, newRoom.player2.level == '初级' ? 3 : (newRoom.player2.level == "中等" ? 8 : 12)), newRoom.board);
        console.log('aiMove', typeof aiMove, aiMove)
        aiMove['step'].accountId = newRoom.player2.accountId
        update(newRoom, aiMove);
        await roomCollection.updateOne(
          { _id: new ObjectId(roomId) },
          {
            $push: { moves: aiMove['step'] },
            $set: { board: newRoom.board }
          },
        );
        console.log('aiMove', aiMove);
        socket.emit("move", aiMove);
      }

      console.log("AI 对战房间创建成功:", roomId);
    } catch (err) {
      console.error("AI 对战匹配失败:", err);
      socket.emit("match_error", { msg: "AI 对战创建失败" });
    }
  });

};


function initialBoard() {
  return [
    {
      type: '車',
      isRed: false,
      pos: { row: 0, col: 0 },
    },
    {
      type: '馬',
      isRed: false,
      pos: { row: 0, col: 1 },
    },
    {
      type: '象',
      isRed: false,
      pos: { row: 0, col: 2 },
    },
    {
      type: '仕',
      isRed: false,
      pos: { row: 0, col: 3 },
    },
    {
      type: '將',
      isRed: false,
      pos: { row: 0, col: 4 },
    },
    {
      type: '仕',
      isRed: false,
      pos: { row: 0, col: 5 },
    },
    {
      type: '象',
      isRed: false,
      pos: { row: 0, col: 6 },
    },
    {
      type: '馬',
      isRed: false,
      pos: { row: 0, col: 7 },
    },
    {
      type: '車',
      isRed: false,
      pos: { row: 0, col: 8 },
    },
    {
      type: '炮',
      isRed: false,
      pos: { row: 2, col: 1 },
    },
    {
      type: '炮',
      isRed: false,
      pos: { row: 2, col: 7 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 0 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 2 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 4 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 6 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 8 },
    },

    // 下方
    {
      type: '車',
      isRed: true,
      pos: { row: 9, col: 0 },
    },
    {
      type: '馬',
      isRed: true,
      pos: { row: 9, col: 1 },
    },
    {
      type: '相',
      isRed: true,
      pos: { row: 9, col: 2 },
    },
    {
      type: '仕',
      isRed: true,
      pos: { row: 9, col: 3 },
    },
    {
      type: '帥',
      isRed: true,
      pos: { row: 9, col: 4 },
    },
    {
      type: '仕',
      isRed: true,
      pos: { row: 9, col: 5 },
    },
    {
      type: '相',
      isRed: true,
      pos: { row: 9, col: 6 },
    },
    {
      type: '馬',
      isRed: true,
      pos: { row: 9, col: 7 },
    },
    {
      type: '車',
      isRed: true,
      pos: { row: 9, col: 8 },
    },
    {
      type: '炮',
      isRed: true,
      pos: { row: 7, col: 1 },
    },
    {
      type: '炮',
      isRed: true,
      pos: { row: 7, col: 7 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 0 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 2 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 4 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 6 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 8 },
    },

  ];
}

function update(room, move) {
  const copyMove = JSON.parse(JSON.stringify(move));

  if (!pieces.includes(move['step']['type'])) {
    return;
  }
  // 坐标修正（如果玩家执黑，需要翻转棋盘）
  const needFlip =
    (room.player1.accountId === copyMove.step.accountId && room.player1.isRed === false) ||
    (room.player2.accountId === copyMove.step.accountId && room.player2.isRed === false);

  if (needFlip) {
    copyMove.step.from.row = 9 - copyMove.step.from.row;
    copyMove.step.from.col = 8 - copyMove.step.from.col;
    copyMove.step.to.row = 9 - copyMove.step.to.row;
    copyMove.step.to.col = 8 - copyMove.step.to.col;
  }

  // 判断是否有吃子
  const targetPiece = room.board.find(
    p => p.pos.row === copyMove.step.to.row && p.pos.col === copyMove.step.to.col
  );
  if (targetPiece) {
    move.step.capture = { ...targetPiece };
    // 移除被吃掉的棋子
    room.board = room.board.filter(p => !(p.id === targetPiece.id));
  }

  // 移动棋子
  const movingPiece = room.board.find(
    p => p.pos.row === copyMove.step.from.row && p.pos.col === copyMove.step.from.col
  );
  if (movingPiece) {
    movingPiece.pos.row = copyMove.step.to.row;
    movingPiece.pos.col = copyMove.step.to.col;
  }
}