const tcb = require('@cloudbase/node-sdk');

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
});

exports.main = async (event, context) => {
    const {friends} = JSON.parse(event.body);
    const db = app.database();
    const _ = db.command;
    const userCollection = db.collection('UserInfo');
    const userDoc = await userCollection.where({ accountId: _.nin(friends) }).limit(10).get();
    if (userDoc.data.length === 0) {
        return { code: 1, msg: '已加载所有用户' };
    }
    else{
        userDoc.data.forEach((item) => {
            delete item.password;
        })
        console.log('userDoc.data',userDoc.data)
        return { code: 0, msg: '获取成功', data: userDoc.data }
    }
}