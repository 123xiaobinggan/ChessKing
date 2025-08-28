const tcb = require('@cloudbase/node-sdk')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})

exports.main = async (event, context) => {
    const ip = event.headers['x-real-ip'] || event.headers['x-forwarded-for'];
    const { accountId, username, password, login, rid } = JSON.parse(event.body);
    console.log('参数值',accountId, username, password, login);
    console.log('event',typeof event.body)
    const db = app.database()
    const userCollection = db.collection('UserInfo');
    const user = await userCollection.where({ accountId }).get()
    if (user.data.length > 0) {
        if (login) {
            if (user.data[0].password !== password) {
                return { code: 1, msg: '账号或密码错误' }
            }
            await userCollection.doc(user.data[0]._id).update({
                rid: rid
            })
            user.data[0]['ip'] = ip;
            delete user.data[0].password;
            return { code: 0, msg: '登录成功', data: user.data[0] }
        }
        else {
            return { code: 1, msg: '账号已存在' }
        }
    }
    else {
        if (login) {
            return { code: 1, msg: '账号或密码错误' }
        }
        else {
            const data = {
                accountId: accountId,
                username: username,
                avatar: 'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png',
                password: password,
                description: "这个人很懒，什么都没有留下",
                phone: '',
                gold: 0,
                activity: 0,
                coupon: 0,
                friend: [],
                requestFriends: [],
                rid: rid,
                ChineseChess: {
                    level: '1-1',
                    total: 0,
                    win: 0,
                    lose: 0,
                    levelBar: 0
                },
                Go: {
                    level: '1-1',
                    total: 0,
                    win: 0,
                    lose: 0,
                    levelBar: 0
                },
                military: {
                    level: '1-1',
                    total: 0,
                    win: 0,
                    lose: 0,
                    levelBar: 0
                },
                Fir: {
                    level: '1-1',
                    total: 0,
                    win: 0,
                    lose: 0,
                    levelBar: 0
                }
            }
            await userCollection.add({
                ...data
            })
            data['ip'] = ip;
            delete data.password;
            return { code: 0, msg: '注册成功', data: data }
        }
    }
}