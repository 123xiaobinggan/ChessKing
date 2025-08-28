// 云函数：inviteFriend.js
const tcb = require('@cloudbase/node-sdk');
const JPush = require('jpush-sdk');

// 初始化极光客户端
const client = JPush.buildClient('74dacc1e2e26774220395b0e', '4de60b2fb9fda99e39c12292');

// 初始化 CloudBase
const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
});

exports.main = async (event, context) => {
    const db = app.database();
    const UserInfoCollection = db.collection('UserInfo');

    // 判断 event.body 是否需要解析
    let body;
    if (typeof event.body === 'string') {
        body = JSON.parse(event.body);
    } else {
        body = event.body;
    }

    const { accountId, invitation } = body;

    // 查找被邀请用户的 registrationId
    let rid = '';
    try {
        const user = await UserInfoCollection.where({ accountId: invitation['accountId'] }).get();
        if (user.data.length > 0) {
            rid = user.data[0].rid;
        } else {
            return { code: 1, msg: '被邀请用户不存在' };
        }
    } catch (err) {
        console.error(err);
        return { code: 1, msg: '查询用户失败' };
    }

    // 发送推送
    try {
        await sendInvite(
            rid,
            invitation['type'],
            accountId,
            invitation['roomId'],
            invitation['gameTime'],
            invitation['stepTime']
        );
        return { code: 0, msg: '推送已发送' };
    } catch (err) {
        console.error(err);
        return { code: 1, msg: '推送失败' };
    }
}

// 发送邀请推送
function sendInvite(registrationId, type, fromUser, roomId, gameTime, stepTime) {
    console.log('type',typeTransfer(type))
    return new Promise((resolve, reject) => {
        client.push()
            .setPlatform('android')
            .setAudience(JPush.registration_id(registrationId))
            .setNotification(
                typeTransfer(type), // 通知标题
                JPush.android(
                    `${fromUser}:邀请你弈棋，点击迎战`, // 通知内容
                    typeTransfer(type), // Android通知标题，如果为空默认用上面的内容
                    1,    // 通知角标
                    { roomId, type: typeTransfer(type), accountId: fromUser, gameTime, stepTime } // extras
                )
            )
            .send((err, res) => {
                if (err) {
                    console.error(err);
                    reject(err);
                } else {
                    console.log('推送结果:', res);
                    resolve(res);
                }
            });
    });
}

// 根据棋类类型映射标题
function typeTransfer(type) {
    if (type.includes('ChineseChess')) return '中国象棋';
    else if (type.includes('Go')) return '围棋';
    else if (type.includes('Military')) return '军棋';
    else return '五子棋';
}
