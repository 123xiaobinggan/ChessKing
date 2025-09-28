const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
    try {
        const { conversationId, createdAt } = req.body;
        console.log('conversationId,createdAt', conversationId, createdAt);
        const db = await connectDB();
        const messageCollection = db.collection('Message');

        const query = {
            conversationId,
        };


        query.createdAt = { $lt: new Date(createdAt) };


        const messages = await messageCollection
            .find(query)
            .sort({ createdAt: -1 }) // 时间倒序（最新的在前）
            .limit(20)
            .toArray();
        console.log('messages', messages.map(m => m.content));
        return { code: 0, messages };
    } catch (e) {
        console.error('e', e);
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
