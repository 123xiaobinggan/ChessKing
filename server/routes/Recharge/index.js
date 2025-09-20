const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
    try {
        const { accountId, gold, coupon } = req.body;
        const db = await connectDB();
        const userCollection = db.collection('UserInfo')
        const userRes = await userCollection.findOne({ accountId: accountId });
        if (!userRes) {
            return { code: 1, msg: "用户不存在" }
        }
        userRes.gold += gold;
        userRes.coupon += coupon;
        await userCollection.updateOne(
            {
                accountId: accountId
            },
            {
                $set:
                {
                    gold: userRes.gold,
                    coupon: userRes.coupon
                }
            }
        );
        return { code: 0, msg: "更新成功", data: userRes };
    } catch (e) {
        console.log(e);
        return { code: 1, msg: e }
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
