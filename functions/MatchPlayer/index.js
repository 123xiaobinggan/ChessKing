const tcb = require('@cloudbase/node-sdk');

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
});

exports.main = async (event, context) => {
    const db = app.database();
    const _ = db.command;
    const { player, type, roomId } = JSON.parse(event.body);
    const roomCollection = db.collection('Room');

    // 状态码定义
    const CODES = {
        JOIN_SUCCESS: 0,
        CREATE_SUCCESS: 1,
        WAITING: 2,
        NO_ROOM: 3,
        FAIL: 4
    };

    try {
        // 如果是新匹配
        if (roomId == '') {
            // 先找一个别人的等待房间
            const waitingRooms = await roomCollection
                .where({
                    status: 'waiting',
                    type,
                    timeMode: player['timeLeft'],
                    'player1.accountId': _.neq(player.accountId) // 排除自己
                })
                .limit(1)
                .get();

            if (waitingRooms.data.length > 0) {
                const roomDoc = waitingRooms.data[0];

                // 分配红黑方
                const player1 = roomDoc.player1;
                const player2 = player;
                player1.isRed = Math.random() > 0.5;
                player2.isRed = !player1.isRed;

                // 条件更新，防止并发
                const updateRes = await roomCollection.doc(roomDoc._id).update({
                    player1,
                    player2,
                    status: 'playing',
                    updatedAt: Date.now()
                });

                if (updateRes.updated === 1) {
                    return {
                        code: CODES.JOIN_SUCCESS,
                        msg: '加入房间成功',
                        data: { roomId: roomDoc._id, player1, player2 }
                    };
                } else {
                    return { code: CODES.FAIL, msg: '房间已被其他人加入' };
                }
            }

            // 如果没有找到别人房间，先查自己是否有等待房
            const myWaitingRooms = await roomCollection
                .where({
                    status: 'waiting',
                    type,
                    timeMode: player.timeLeft,
                    'player1.accountId': player.accountId
                })
                .limit(1)
                .get();

            if (myWaitingRooms.data.length > 0) {
                return {
                    code: CODES.WAITING,
                    msg: '已有等待中的房间',
                    data: { roomId: myWaitingRooms.data[0]._id }
                };
            }

            // 创建新房间
            const newRoom = {
                player1: player,
                player2: {
                    accountId: '',
                    username: '',
                    avatar: '',
                    level: '',
                    isRed: false,
                    timeLeft: 0
                },
                type,
                timeMode: player.timeLeft,
                status: 'waiting',
                moves: [],
                result: { winner: null, reason: null },
                createdAt: Date.now(),
                updatedAt: Date.now()
            };

            const res = await roomCollection.add(newRoom);
            return {
                code: CODES.CREATE_SUCCESS,
                msg: '创建房间成功',
                data: { roomId: res.id }
            };
        }

        // 如果是已有房间，检查是否有人加入
        else {
            const myRooms = await roomCollection
                .where({
                    _id: roomId
                })
                .limit(1)
                .get();

            if (myRooms.data.length > 0) {
                const player1 = myRooms.data[0].player1;
                const player2 = myRooms.data[0].player2;
                if ((player1.accountId == player.accountId && player2.accountId) || (player2.accountId == player.accountId && player1.accountId)) {
                    return {
                        code: CODES.JOIN_SUCCESS,
                        msg: '房间有人加入',
                        data: { roomId: myRooms.data[0]._id, player1, player2 }
                    };
                } else {
                    return { code: CODES.WAITING, msg: '暂无他人加入房间' };
                }
            }

            return { code: CODES.NO_ROOM, msg: '房间不存在' };
        }
    } catch (err) {
        console.error(err);
        return { code: CODES.FAIL, msg: '匹配失败', error: err };
    }
};
