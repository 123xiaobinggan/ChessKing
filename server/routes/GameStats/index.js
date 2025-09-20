const express = require('express');
const router = express.Router();
const connectDB = require('../../db');


async function main(req, context) {
    try {
        const { accountId } = req.body;
        const db = await connectDB();
        const userInfoCollection = db.collection('UserInfo');
        const userRes = await userInfoCollection.findOne({ accountId: accountId });
        if (!userRes) {
            return { code: 1, msg: "用户不存在" }
        }
        // console.log('查询成功',{ ChineseChess: userRes.ChineseChess, Go: userRes.Go, mmilitary: userRes.military, Fir: userRes.Fir })
        return { code: 0, msg: "查询成功", data: { ChineseChess: userRes.ChineseChess, Go: userRes.Go, mmilitary: userRes.military, Fir: userRes.Fir } }
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