

module.exports = (io, socket, userCollection, roomCollection, accountIdMap) => {
    socket.on('sendInvitation', async (data) => {

        const inviteeAccountId = data['inviteeAccountId'];
        const inviterAccountId = data['inviterAccountId'];
        const inviterSocket = accountIdMap[inviterAccountId]
        const inviterUser = await userCollection.findOne({
            accountId: inviterAccountId
        });
        const player1 = {
            id: inviterSocket.id,
            accountId: inviterAccountId,
            username: inviterUser.username,
            avatar: inviterUser.avatar,
            level: inviterUser[transform(data['type'])]['level'],
            isRed: false,
            timeLeft: data['timeMode']
        }
        const newRoom = {
            player1,
            type: data['type'],
            timeMode: data['gameTime'],
            status: 'ready',
            moves: [],
            messages: [],
            actions: [],
            result: {
                winner: null,
                result: null
            },
            createdAt: new Date(),
            board: initialBoard()
        };
        const res = await roomCollection.insertOne(newRoom);
        const roomId = res.insertedId.toString();
        inviterSocket.join(roomId);
        inviterSocket.roomId = roomId;
        inviterSocket.accountId = inviterAccountId;
        data.roomId = roomId;
        console.log('sendInvitation', data)
        if (accountIdMap[inviteeAccountId]) {
            data['avatar'] = inviterUser.avatar;
            data['username'] = inviterUser.username;
            console.log('data', data);
            io.to(accountIdMap[inviteeAccountId].id).emit('receiveInvitation', data);
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