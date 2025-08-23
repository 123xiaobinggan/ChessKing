const tcb = require('@cloudbase/node-sdk')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})


exports.main = async (event, context) => {
    const {roomId} = JSON.parse(event.body)
    const db = app.database()
    const _ = db.command

    const roomCollection = db.collection('Room')
    console.log('roomId',roomId);
    try {
        // 找一个等待中的房间
        const res = await roomCollection.doc(roomId).remove()
        console.log('res',res.data.length);
        return {
            code: 0,
            msg: '房间销毁成功'
        }
    }catch(err){
        return {
            code: 1,
            msg: '房间销毁失败'
        }
    }

}