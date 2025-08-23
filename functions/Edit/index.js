const tcb = require('@cloudbase/node-sdk')
const fs = require('fs')
// const Busboy = require('busboy')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})

exports.main = async (event, context) => {
    
    const {accountId, username, avatar,description, password, newPassword} = JSON.parse(event.body);
    const db = app.database();

    const res = await db.collection('UserInfo').where({accountId}).get();

    if (res.data.length > 0) { // 账号已存在，修改用户信息
        const user = res.data[0];
        if(user.password !== password && password){ // 密码错误，返回错误信息
            return {code: 1, msg: '密码错误'};
        }

        const data = {
            username: username || user.username, // 如果没有传入新的用户名，则保持原用户名不变,
            avatar: avatar || user.avatar, // 如果没有传入新的头像，则保持原头像不变,
            description: description || user.description, // 如果没有传入新的描述，则保持原描述不变,
            password: newPassword || user.password, // 如果没有传入新的密码，则保持原密码不变,
        };
        await db.collection('UserInfo').doc(user._id).update(data); // 更新用户信息
        return {code: 0, msg: '修改成功'}; // 返回成功信息和更新后的数据
        
    }

}