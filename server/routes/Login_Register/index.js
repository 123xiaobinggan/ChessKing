const express = require('express');
const router = express.Router();
const connectDB = require('../../db'); // 引入数据库连接
const axios = require('axios');

async function main(req, context) {
    var ip = req.headers['x-real-ip'] || req.headers['x-forwarded-for'] || req.ip;
    ip = await resolveIp(ip)
    const { accountId, username, password, login, rid } = req.body;

    const db = await connectDB();
    const userCollection = db.collection('UserInfo');
    const user = await userCollection.findOne({ accountId });
    if (user) {
        if (login) {
            if (user.password !== password) {
                return { code: 1, msg: '账号或密码错误' };
            }
            await userCollection.updateOne({ _id: user._id }, { $set: { rid } });
            delete user.password;
            return { code: 0, msg: '登录成功', data: { ...user, ip } };
        } else {
            return { code: 1, msg: '账号已存在' };
        }
    } else {
        if (login) {
            return { code: 1, msg: '账号或密码错误' };
        } else {
            const data = {
                accountId,
                username,
                password,
                avatar: 'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png',
                description: "这个人很懒，什么都没有留下",
                phone: '',
                gold: 0,
                activity: 0,
                coupon: 0,
                friends: [],
                requestFriends: [],
                rid,
                ChineseChess: { level: '1-1', total: 0, win: 0, lose: 0, levelBar: 0 },
                Go: { level: '1-1', total: 0, win: 0, lose: 0, levelBar: 0 },
                military: { level: '1-1', total: 0, win: 0, lose: 0, levelBar: 0 },
                Fir: { level: '1-1', total: 0, win: 0, lose: 0, levelBar: 0 }
            };

            await userCollection.insertOne(data);
            delete data.password;
            return { code: 0, msg: '注册成功', data: { ...data, ip } };
        }
    }
}

router.post('/', async (req, res) => {
    console.log('收到请求', req.body);
    try {
        const result = await main(req, {});
        res.json(result);
    } catch (err) {
        res.status(500).json({ error: err.message });
        console.log('err', err)
    }
});

async function resolveIp(ip) {
    const host =
        "https://ipcity.market.alicloudapi.com"; // 请求地址 支持http 和 https 及 WEBSOCKET
    const path = "/ip/city/query"; // 后缀
    const appCode = "1dc84a4fe7fc40238d1a17ad665c59d3";
    // 构建查询参数
    const querys = 'ip='+ip+'&coordsys=WGS84';
    const urlSend = host+path+'?'+querys; // 拼接完整请求链接
    console.log('urlsend',urlSend);
    try {
        var res = await axios.get(urlSend, {
            headers: {
                'Authorization': 'APPCODE '+appCode, // 鉴权信息
            },
        });
        if (res.status == 200) {
            if (res.data['code'] == 200) {
                var city = '未知';
                if (res.data['data']['result']['city'] != '') {
                    city = res.data['data']['result']['city'];
                } else if (res.data['data']['result']['prov'] != '') {
                    city = res.data['data']['result']['province'];
                } else if (res.data['data']['result']['country'] != '') {
                    city = res.data['data']['result']['country'];
                } else if (res.data['data']['result']['continuent'] != '') {
                    city = res.data['data']['result']['continent'];
                }
                return city
            }
        }
    } catch (e) {
        console.log('err', e);
        return '未知';
    }
}


module.exports = router;
