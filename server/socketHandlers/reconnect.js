const { ObjectId } = require('bson');
module.exports = (io, socket, db,roomCollection) => {
  //断线重连
  socket.on('reconnectRoom', async ({ roomId, accountId }) => {
    console.log(`玩家 ${accountId} 尝试重连房间 ${roomId}`);
    
    try {
      const room = await roomCollection.findOne({ _id: new ObjectId(roomId) });
      if (!room) {
        socket.emit("reconnect_failed", { msg: "房间不存在" });
        return;
      }

      // 检查玩家是否在这个房间
      const isPlayerInRoom =
        room.player1.accountId === accountId ||
        room.player2.accountId === accountId;

      if (!isPlayerInRoom) {
        socket.emit("reconnect_failed", { msg: "你不是该房间的玩家" });
        return;
      }

      // 加入 socket.io 房间
      socket.join(roomId);

      // 更新玩家 socketId(方便继续通信)
      if (room.player1.accountId === accountId) {
        room.player1.id = socket.id;
      } else {
        room.player2.id = socket.id;
      }
      await roomCollection.updateOne(
        { _id: new ObjectId(roomId) },
        { $set: { player1: room.player1, player2: room.player2 } }
      );

      // 把当前棋局状态发给玩家(moves、当前轮到谁等)
      socket.emit("reconnect_success", {
        roomId,
        player1: room.player1,
        player2: room.player2,
        moves: room.moves,
        status: room.status,
        result: room.result,
      });

      console.log(`玩家 ${accountId} 重连成功，进入房间 ${roomId}`);

    } catch (err) {
      console.error("重连错误:", err);
      socket.emit("reconnect_failed", { msg: "服务器错误" });
    }
  });
}