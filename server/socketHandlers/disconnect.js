const { ObjectId } = require('bson');
module.exports = (io, socket, waitingPlayers, userCollection, accountIdMap) => {
  socket.on('disconnect', async () => {
    console.log('断开连接', socket.id, socket.data.accountId, socket.data.roomId);

    for (var i = 0; i < waitingPlayers.length; i++) {
      var player = waitingPlayers[i]
      if (player.id == socket.id) {
        waitingPlayers.splice(i, 1);
        break;
      }
    }

    if (socket.data.roomId) {
      const socketRoomId = socket.data.socketRoomId;
      console.log('socketRoomId', socketRoomId)
      if (socketRoomId) {
        io.to(socketRoomId).emit('opponentDisconnect', { accountId: socket.data.accountId })
      } else {
        console.log('socketRoomId为空', socketRoomId)
      }
    } else {
      console.log('socket.data.roomId为空')
    }
    delete accountIdMap[socket.data.accountId];
    if (socket.data.accountId) {
      const user = await userCollection.findOne({
        accountId: socket.data.accountId
      });
      if (user) {
        const friends = user.friends;
        socketFriends = [];
        for (var friendAccountId of friends) {
          if (accountIdMap[friendAccountId]) {
            socketFriends.push(accountIdMap[friendAccountId]);
          }
        }
        for (var soc of socketFriends) {
          soc.emit('receiveFriendsOffline', { accountId: socket.data.accountId })
        }
      }
    }
  });
}