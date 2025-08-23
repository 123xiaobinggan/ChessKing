const tcb = require('@cloudbase/node-sdk')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})

exports.main = async (event, context) => {
    const db = app.database()
    const { roomId, type, result } = JSON.parse(event.body)

    try {
        const roomCollection = db.collection('Room')

        // 1. 先检查房间是否存在且未结束
        const roomRes = await roomCollection.doc(roomId).get()
        if (!roomRes.data.length) {
            return { code: 1, msg: '房间不存在' }
        }
        if (roomRes.data[0].status === 'finished') {
            return { code: 1, msg: '房间已结束' }
        }

        const player1 = roomRes.data[0].player1
        const player2 = roomRes.data[0].player2

        if (type.includes('Match')) {
            tt = type.replace('Macth','');
            await app.callFunction({
                name: 'UpdateLevel',
                data: { accountId: player1.accountId, tt, win: result.winner == player1.accountId ? 1 : result.winner == player2.accountId ? -1 : 0 }
            })

            await app.callFunction({
                name: 'UpdateLevel',
                data: { accountId: player2.accountId, tt, win: result.winner == player2.accountId ? 1 : result.winner == player1.accountId ? -1 : 0 }
            })
        }

        // 2. 更新房间状态与结果
        await roomCollection.doc(roomId).update({
            status: 'finished',
            result: result,  // { winner_id, loser_id, reason }
            finished_at: new Date()
        })

        return { code: 0, msg: '更新房间状态成功', data: { roomId } }
    } catch (err) {
        console.error(err)
        return { code: 1, msg: '更新房间状态失败', error: err }
    }
}
