const { ObjectId } = require('bson');

module.exports = (io, socket, db, waitingPlayers, roomCollection) => {
  socket.on('ChineseChessWithFriends', async (params) => {
    const roomId = socket.roomId;
    const room = await roomCollection.findOne({ _id: new ObjectId(roomId) });

    if (!room) {
      io.to(roomId).emit('roomNotExist');
      return;
    }

    let player1 = room.player1;
    let player2 = room.player2;

    if (room.status === 'playing') {
      // 已经开局了，直接通知客户端
      io.to(roomId).emit('match_success', {
        roomId,
        player1,
        player2
      });
    } else {
      // 分配红黑方
      player1.isRed = Math.random() > 0.5;
      player2.isRed = !player1.isRed;

      // 更新数据库
      await roomCollection.updateOne(
        { _id: new ObjectId(roomId) },
        { $set: { status: 'playing', player1, player2 } }
      );
      io.to(roomId).emit('opponentReady', socket.accountId);
    }
  });
};
