const { ObjectId } = require('bson');

module.exports = (io, socket,roomCollection) => {
    socket.on('ping', async (data) => {
        console.log('data', data);
        socket.emit("pong");
        if(!data || !data['roomId']){
            return;
        }
        try {
            const room = await roomCollection.findOne({ _id: new ObjectId(data['roomId']) });
            if (!room) {
                return socket.emit("error", { msg: "房间不存在" });
            }
            let opponentSocketId = null;
            if (room.player1['accountId'] === move['step']['accountId']) {
                opponentSocketId = room.player2.id;   // 你在匹配时存的 socket.id
            } else if (room.player2['accountId'] === move['step']['accountId']) {
                opponentSocketId = room.player1.id;
            }

            console.log('opponentSocketId', opponentSocketId);
            if (opponentSocketId) {
                io.to(opponentSocketId).emit("opponentPong"); // 只发给对手
            }


        } catch (e) {
            console.log('e', e);
        }
    })

}