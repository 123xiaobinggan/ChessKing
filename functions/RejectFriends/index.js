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
        const myUserDoc = await userCollection.where({ accountId: myAccountId }).get();
        if (myUserDoc.data.length > 0) {
            const myUser = myUserDoc.data[0];
            if (myUser['requestFriends'].includes(opponentAccountId)) {
                await userCollection.doc(myUser._id).update({
                    requestFriends: _.pull({ accountId: opponentAccountId })
                })
                return { code: 0, msg: '已拒绝' };
            }
        }
    }
    catch (error) {
        console.log(error);
        return { code: 1, msg: '拒绝失败' };
    }
}