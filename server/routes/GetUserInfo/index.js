const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
    try {
        const { accountId } = req.body;
        const db = await connectDB();

        const userCollection = db.collection('UserInfo');
        const user = await userCollection.findOne({ accountId })
        console.log('user',user)
        if (!user) {
            return { code: 1, msg: "用户不存在" }
        }
        return { code: 0, ...user };
    } catch (e) {
        console.log('e', e);
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
