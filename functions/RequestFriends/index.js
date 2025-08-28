const tcb = require('@cloudbase/node-sdk');

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
});

exports.main = async (event, context) => {
    try {
        const db = app.database();
        const _ = db.command;

        // 检查 event.body 是否存在且为有效的 JSON 字符串
        if (!event.body) {
            return { code: 1, msg: '请求体为空，无法解析' };
        }
        const { myAccountId, opponentAccountId } = JSON.parse(event.body);

        const userCollection = db.collection('UserInfo');
        const userDoc = await userCollection.where({ accountId: opponentAccountId }).get();

        // 检查查询结果是否为空
        if (userDoc.data.length === 0) {
            return { code: 1, msg: '未找到对应的用户信息' };
        }

        if (userDoc.data[0]['friends'].includes(myAccountId)) {
            return { code: 1, msg: '已经是好友' };
        }
        if (userDoc.data[0]['requestFriends'].includes(myAccountId)) {
            return { code: 1, msg: '已经发送过好友请求' };
        }
        const res = await userCollection.doc(userDoc.data[0]._id).update({
            requestFriends: _.push(myAccountId)
        });

        if (res.updated === 1) {
            return { code: 0, msg: '发送成功' };
        } else {
            return { code: 1, msg: '更新用户信息失败' };
        }
    } catch (error) {
        console.error('云函数执行出错:', error);
        return { code: 1, msg: '云函数执行出错', error: error.message };
    }
};