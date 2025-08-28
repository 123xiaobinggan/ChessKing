const tcb = require('@cloudbase/node-sdk');

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
});

exports.main = async (event, context) => {
    const db = app.database();
    const _ = db.command;
    const { myAccountId, opponentAccountId } = JSON.parse(event.body);

    const userCollection = db.collection('UserInfo');

    try {
        // 查询双方用户
        const [myUserDoc, opponentUserDoc] = await Promise.all([
            userCollection.where({ accountId: myAccountId }).get(),
            userCollection.where({ accountId: opponentAccountId }).get()
        ]);

        if (myUserDoc.data.length === 0 || opponentUserDoc.data.length === 0) {
            return { code: 1, msg: '用户不存在' };
        }

        const myUser = myUserDoc.data[0];
        const opponentUser = opponentUserDoc.data[0];

        // 并行删除两边好友关系
        const [myRes, opponentRes] = await Promise.all([
            userCollection.doc(myUser._id).update({
                friends: _.pull(opponentAccountId),
                requestFriends: _.pull({ accountId: opponentAccountId })
            }),
            userCollection.doc(opponentUser._id).update({
                friends: _.pull(myAccountId),
                requestFriends: _.pull({ accountId: myAccountId })
            })
        ]);

        if (myRes.updated === 1 || opponentRes.updated === 1) {
            return { code: 0, msg: '好友关系已删除' };
        } else {
            return { code: 1, msg: '未找到好友关系' };
        }

    } catch (error) {
        console.error('删除好友出错:', error);
        return { code: 1, msg: '删除失败', error: error.toString() };
    }
};
