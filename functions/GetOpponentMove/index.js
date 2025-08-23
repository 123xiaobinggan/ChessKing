const tcb = require('@cloudbase/node-sdk')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})

exports.main = async (event, context) => {
    const { roomId, moves_length } = JSON.parse(event.body)
    const db = app.database()
    const RoomCollection = db.collection('Room')
    console.log('roomId:', roomId)

    try {
        // 正确获取文档
        const res = await RoomCollection.doc(roomId).get({
            fields: ['moves']
        })

        // 判断房间是否存在
        if (res.data.length === 0) {
            return { code: 1, msg: '房间不存在' }
        }

        const roomData = res.data[0]
        const moves = roomData.moves || []

        // 判断是否有新的落子
        if (moves.length === moves_length) {
            return { code: 2, msg: '对方未动' }  // 建议用不同的 code
        }

        // 返回最后一步落子
        return { code: 0, msg: '获取动作成功', data: moves[moves.length - 1] }

    } catch (err) {
        console.error(err)
        return { code: 1, msg: '获取动作失败' }
    }
}
