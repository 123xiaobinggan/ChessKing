const tcb = require('@cloudbase/node-sdk')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})

exports.main = async (event, context) => {
    const db = app.database()
    const _ = db.command
    // win 1 胜利 -1 失败 0 平局
    const { accountId, Type, win } = event;

    const userCollection = db.collection('UserInfo');
    try {
        const user = await userCollection.where({ accountId: accountId }).get()

        if (user.data.length > 0) {
            const userData = user.data[0];
            const gameData = userData[Type];

            gameData['activity'] = gameData['activity'] + 10;
            gameData['levelBar'] += win == 1 ? 10 : win == -1 ? -10 : 0;
            if (gameData['levelBar'] < 0) {
                gameData['levelBar'] = 0;
            }
            if (gameData['levelBar'] > 100) {
                gameData['levelBar'] %= 100;
                const level = gameData['level'].split('-');
                level[1] = parseInt(level[1]) + 1;
                if (parseInt(level[1]) > 3) {
                    level[1] = 1;
                    level[0] = parseInt(level[0]) + 1;
                }
                gameData['level'] = level.join('-');
            }
            
            gameData['win'] += win == 1 ? 1 : 0;
            gameData['lose'] += win == -1 ? 1 : 0;
            gameData['total'] += 1;
            await userCollection.doc(userData._id).update({
                data: {
                    [Type]: gameData,
                }
            })
            return { code: 0, msg: '更新成功', data: gameData }
        }
        else {
            return { code: 1, msg: '用户不存在' }
        }
    } catch (err) {
        console.log(err)
        return { code: 1, msg: '更新失败' }
    }
}