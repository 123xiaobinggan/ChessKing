const tcb = require('@cloudbase/node-sdk')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})

exports.main = async (event, context) => {
    const db = app.database()
    const versionCollection = db.collection('Version')

    try {
        // 按 updateTime 字段降序排序，取第一条记录
        const res = await versionCollection
           .orderBy('updateTime', 'desc')
           .limit(1)
           .get()

        console.log('res',res.data[0])
        if (res.data.length > 0) {
            return {code:0, data:res.data[0]}
        } else {
            return { message: '未找到相关数据' }
        }
    } catch (error) {
        console.error('查询数据出错:', error)
        return { error: '查询数据时发生错误', details: error.message }
    }
}