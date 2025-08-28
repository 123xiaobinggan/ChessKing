const tcb = require('@cloudbase/node-sdk');

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
});

exports.main = async (event, context) => {
    const db = app.database();
    const _ = db.command;
    const { myAccountId, opponentAccountId } = JSON.parse(event.body);

    const transaction = await db.startTransaction();

    try {
        const myUserDoc = await transaction.collection('UserInfo').where({ accountId: myAccountId }).get();
        const opponentUserDoc = await transaction.collection('UserInfo').where({ accountId: opponentAccountId }).get();

        if (myUserDoc.data.length === 0 || opponentUserDoc.data.length === 0) {
            await transaction.rollback();
            return { code: 1, msg: '用户不存在' };
        }

        const myUser = myUserDoc.data[0];
        const opponentUser = opponentUserDoc.data[0];

        // 检查是否已经是好友
        if (myUser.friends.includes(opponentAccountId) || opponentUser.friends.includes(myAccountId)) {
            await transaction.rollback();
            return { code: 1, msg: '已经是好友' };
        }

        // 从请求列表中移除
        await transaction.collection('UserInfo').doc(myUser._id).update({
            requestFriends: _.pull(opponentAccountId)
        });
        await transaction.collection('UserInfo').doc(opponentUser._id).update({
            requestFriends: _.pull(myAccountId)
        });

        // 添加到好友列表
        await transaction.collection('UserInfo').doc(myUser._id).update({
            friends: _.push(opponentAccountId)
        });
        await transaction.collection('UserInfo').doc(opponentUser._id).update({
            friends: _.push(myAccountId)
        });

        // 提交事务
        await transaction.commit();
        return { code: 0, msg: '成功添加好友' };

    } catch (error) {
        console.error(error);
        await transaction.rollback();
        return { code: 1, msg: '添加好友失败' };
    }
};
