const { ObjectId } = require('bson');

module.exports = (io, socket, waitingPlayers) => {
    socket.on('cancelMatch', async () => {
        console.log('cancelMatch', socket.data.accountId, socket.data.socketRoomId);
        // 移除排队
        for (var i = 0; i < waitingPlayers.length; i++) {
            var player = waitingPlayers[i]
            if (player.id == socket.id) {
                waitingPlayers.splice(i, 1);
                break;
            }
        }

        const socketRoomId = socket.data.socketRoomId
        const client = await io.in(socketRoomId).allSockets();
        console.log('client',client.size,socketRoomId);
        //房间里有两个人才通知对方已离开
        if (client.size > 1) {
            io.to(socket.data.socketRoomId).emit('opponentLeave', {
                accountId: socket.data.accountId
            });
        }

        // 离开房间
        if (socketRoomId) {
            socket.leave(socketRoomId);
            socket.data.socketRoomId = ''
            console.log(socket.data.accountId, 'leaveRoom', await io.in(socketRoomId).allSockets())
        }

    })
}