const { ObjectId } = require('bson');
const { pikafish, cancelAI, boardToFEN, uciToMove } = require('../pikafish.js')
const pieces = ['車', '馬', '相', '象', '仕', '將', '帥', '炮', '兵', '卒'];

module.exports = (io, socket, db, roomCollection) => {
  socket.on('move', async (move) => {
    console.log('move', move);
    try {
      var startTime = Date.now();
      // 找到房间信息
      const room = await roomCollection.findOne({ _id: new ObjectId(move['roomId']) });
      if (!room) {
        return socket.emit("error", { msg: "房间不存在" });
      }

      update(room, move);

      // 更新数据库棋谱
      await roomCollection.updateOne(
        { _id: new ObjectId(move['roomId']) },
        {
          $push: { moves: move['step'] },
          $set: { board: room.board }
        },
      );

      // 确定对手是谁
      let opponentSocketId = null;
      if (room.player1['accountId'] === move['step']['accountId']) {
        opponentSocketId = room.player2.id;   // 你在匹配时存的 socket.id
      } else if (room.player2['accountId'] === move['step']['accountId']) {
        opponentSocketId = room.player1.id;
      }

      if (room.type.includes("Ai")) {
        if (room.type == "ChineseChessAi") {
          const fen = boardToFEN(room.board, room.player2.isRed);
          console.log('fen', fen);
          const aiMove = uciToMove(await pikafish(fen, room.player2.level == '初级' ? 3 : (room.player2.level == "中等" ? 8 : 12)), room.board);
          console.log('aiMove', typeof aiMove, aiMove)
          aiMove['step'].accountId = room.player2.accountId
          // 如果ai执黑,则需要翻转棋盘
          if (!room.player2.isRed) {
            aiMove['step']['from']['row'] = 9 - aiMove['step']['from']['row'];
            aiMove['step']['from']['col'] = 8 - aiMove['step']['from']['col'];
            aiMove['step']['to']['row'] = 9 - aiMove['step']['to']['row'];
            aiMove['step']['to']['col'] = 8 - aiMove['step']['to']['col']
          }
          update(room, aiMove);
          await roomCollection.updateOne(
            { _id: new ObjectId(move['roomId']) },
            {
              $push: { moves: aiMove['step'] },
              $set: { board: room.board }
            },
          );
          console.log('aiMove', aiMove);

          io.to(room.player1.id).emit("move", aiMove);

        }
      }
      console.log('opponentSocketId',opponentSocketId);
      const endTime = Date.now();
      const processingTime = Math.floor((endTime-startTime) / 1000);
      move['step']['timeLeft'] = (move['step']['timeLeft'] || 0) + processingTime;

      if (opponentSocketId) {
        io.to(opponentSocketId).emit("move", move); // 只发给对手
      }

    } catch (e) {
      console.log('更新落子失败', e)
      socket.emit('error', { msg: '落子失败' });
    }
  });
};

function update(room, move) {
  const copyMove = JSON.parse(JSON.stringify(move));

  if (!pieces.includes(move['step']['type'])) {
    return;
  }
  // console.log('copyMove',copyMove);
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
    console.log('capture', targetPiece);
    move.step.capture = { ...targetPiece };
    // 移除被吃掉的棋子
    room.board = room.board.filter(p => !(p.pos.row === copyMove.step.to.row && p.pos.col === copyMove.step.to.col));
  }

  // 移动棋子
  const movingPiece = room.board.find(
    p => p.type === copyMove.step.type && p.pos.row === copyMove.step.from.row && p.pos.col === copyMove.step.from.col
  );
  console.log('movingPiece', movingPiece)
  if (movingPiece) {
    movingPiece.pos.row = copyMove.step.to.row;
    movingPiece.pos.col = copyMove.step.to.col;
  }
}


