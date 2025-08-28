const tcb = require('@cloudbase/node-sdk')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})

exports.main = async (event, context) => {
    console.log('event',JSON.parse(event.body));
    const { friends , requestFriends } = JSON.parse(event.body);
    console.log('参数值',friends,requestFriends);
    const db = app.database()
    const _ = db.command

    const userCollection = db.collection('UserInfo');

    var friendsList = [];

    try {
        const friend = await userCollection.where(
            _.or([
                { accountId: _.in(friends) },
                { accountId: _.in(requestFriends) }
            ])
        ).get();

        console.log(friend.data)

        friend.data.forEach((item) => {
            delete item.password;
            friendsList.push({
                ...item,
            })
        })


        return { code: 0, msg: '获取成功', data: friendsList }
    } catch (err) {
        console.log(err)
        return { code: 1, msg: '获取失败' }
    }
}