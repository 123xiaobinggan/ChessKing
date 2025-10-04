
module.exports = (io, socket, userCollection, accountIdMap) => {
    socket.on('dealInvitation', async (data) => {
        console.log('dealInvitation', data);
        const inviterAccountId = data['inviterAccountId'];
        const inviteeAccountId = data['inviteeAccountId'];
        const socketRoomId = data['socketRoomId'];
        console.log('dealInvitation:socketRoomId', socketRoomId)
        if (data['deal'] == "accept") {
            const client = await io.in(socketRoomId).allSockets();
            console.log('client', client);
            if (client.size == 0) {
                socket.emit('roomNotExist');
                return;
            }
            socket.join(socketRoomId);
            socket.data.socketRoomId = socketRoomId;
            console.log('socket.data.socketRoomId', socketRoomId);

            const users = await userCollection.find(
                { accountId: { $in: [inviterAccountId, inviteeAccountId] } },
                { projection: { password: 0 } } // 直接排除 password 字段
            ).toArray();

            let player1 = users.find(u => u.accountId === inviterAccountId);
            let player2 = users.find(u => u.accountId === inviteeAccountId);

            player1 = {
                accountId: player1.accountId,
                username: player1.username,
                avatar: player1.avatar,
                level: player1[transform(data['type'])].level,
                timeLeft: data['gameTime']
            }

            player2 = {
                accountId: player2.accountId,
                username: player2.username,
                avatar: player2.avatar,
                level: player2[transform(data['type'])].level,
                timeLeft: data['gameTime']
            }

            io.to(socketRoomId).emit("room_joined", {
                socketRoomId,
                inviter: player1,
                invitee: player2,
                gameTime: data['gameTime']
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

