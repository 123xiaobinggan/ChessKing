// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db');
const { ObjectId } = require('mongodb'); // 用于 _id 操作

async function main(req, context) {
    try {
        const db = await connectDB();
        const { myAccountId, opponentAccountId } = req.body;

        const userCollection = db.collection('UserInfo');

        // 查找对方用户
        const userDoc = await userCollection.findOne({ accountId: opponentAccountId });

        if (!userDoc) {
            return { code: 1, msg: '未找到对应的用户信息' };
        }

        // 确保 friends 和 requestFriends 字段存在
        const friends = userDoc.friends || [];
        const requestFriends = userDoc.requestFriends || [];

        if (friends.includes(myAccountId)) {
            return { code: 1, msg: '已经是好友' };
        }
        if (requestFriends.includes(myAccountId)) {
            return { code: 1, msg: '已经发送过好友请求' };
        }

        // 更新 requestFriends 数组，添加 myAccountId
        const updateRes = await userCollection.updateOne(
            { _id: userDoc._id },
            { $push: { requestFriends: myAccountId } }
        );

        if (updateRes.modifiedCount === 1) {
            return { code: 0, msg: '发送成功' };
        } else {
            return { code: 1, msg: '更新用户信息失败' };
        }
    } catch (error) {
        console.error('函数执行出错:', error);
        return { code: 1, msg: '函数执行出错', error: error.message };
    }
}

router.post('/', async (req, res) => {
    try {
        const result = await main(req, {});
        res.json(result);
    } catch (err) {
        console.error('err', err);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
