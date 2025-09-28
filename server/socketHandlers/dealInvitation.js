const { ObjectId } = require('bson');
module.exports = (io, socket, userCollection, roomCollection, accountIdMap) => {
    socket.on('dealInvitation', async (data) => {
        console.log('dealInvitation', data);
        const inviterAccountId = data['inviterAccountId'];
        const inviteeAccountId = data['inviteeAccountId'];
        if (data['deal'] == "accept") {
            const inviteeSocket = accountIdMap[inviteeAccountId];
            const inviteeUser = await userCollection.findOne({
                accountId: inviteeAccountId
            });
            const room = await roomCollection.findOne({
                _id: new ObjectId(data['roomId'])
            });
            if (!room) {
                socket.emit('roomNotExist');
                return;
            }
            const player2 = {
                id: inviteeSocket.id,
                accountId: inviteeAccountId,
                username: inviteeUser.username,
                avatar: inviteeUser.avatar,
                level: inviteeUser[transform(data['type'])]['level'],
                isRed: false,
                timeLeft: data['timeMode']
            };
            room.player2 = player2;
            const res = await roomCollection.updateOne(
                { _id: new ObjectId(data['roomId']) },
                { $set: {player2} }
            );
            inviteeSocket.join(data['roomId']);
            inviteeSocket.roomId = data['roomId'];
            inviteeSocket.accountId = inviteeAccountId;
            io.to(data['roomId']).emit("room_joined", {
                roomId:data['roomId'],
                inviter: room.player1,
                invitee: player2,
                gameTime: room.timeMode
            });
        } else {
            if (accountIdMap[inviterAccountId]) {
                console.log('data', data);
                io.to(accountIdMap[inviterAccountId].id).emit('opponentDealInvitation', data);
            }
        }
    })
}

function transform(type) {
    if (type.includes('ChineseChess')) {
        return 'ChineseChess';
    } else if (type.includes('Go')) {
        return 'Go'
    } else if (type.includes('Military')) {
        return 'Military'
    } else {
        return 'Fir'
    }
}
