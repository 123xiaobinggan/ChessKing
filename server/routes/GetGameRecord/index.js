const express = require('express');
const router = express.Router();
const connectDB = require('../../db'); // 引入数据库连接

async function main(req, context) {
    try {
        const { accountId, type, createdAt } = req.body;
        const db = await connectDB();
        const roomCollection = db.collection('Room');
        console.log(accountId, type, createdAt);
        const createdAtNum = parseInt(createdAt, 10);
        // 查询条件
        const query = {
            $and: [
                {
                    $or: [
                        { "player1.accountId": accountId },
                        { "player2.accountId": accountId }
                    ]
                },
                { type: { $regex: type } },
                { createdAt: { $lt: createdAtNum } } // 确保是 Date 类型
            ]
        };

        // 按时间倒序，取最近的 10 条
        const records = await roomCollection
            .find(query)
            .sort({ createdAt: -1 })
            .limit(10)
            .toArray();
        console.log(records.map(e=>e.createdAt));
        return { code: 0, records };
    } catch (e) {
        console.log('e', e)
        return { code: 1, msg: e.message };
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