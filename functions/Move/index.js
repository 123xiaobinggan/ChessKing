const tcb = require('@cloudbase/node-sdk')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})

exports.main = async (event, context) => {
    const { roomId, step } = JSON.parse(event.body)
    const db = app.database()
    const _ = db.command
    const RoomCollection = db.collection('Room')
    console.log('roomId', roomId)

    try {
        const res = await RoomCollection.doc(roomId).get({
            fields: ['moves']
        })

        if (!res.data || res.data.length === 0) {
            return { code: 1, msg: '房间不存在' }
        }

        const roomData = res.data[0]
        const moves = roomData.moves || []

        // 如果不是第一步，则检查回合
        if (moves.length > 0) {
            const last_step = moves[moves.length - 1]
            if (last_step.accountId === step.accountId) {
                const types = ["車", "馬", "相", "象", "仕", "帥", "將", "兵", "卒", "炮"];
                if (types.includes(step.type)) {
                    console.log('type,last_step.type', step.type, last_step.type)
                    return { code: 1, msg: '不是你的回合' }
                }
            }
        }

        await RoomCollection.doc(roomId).update({
            moves: _.push(step)
        })

        return { code: 0, msg: '移动成功' }

    } catch (err) {
        console.error(err)
        return { code: 1, msg: '移动失败' }
    }
}
