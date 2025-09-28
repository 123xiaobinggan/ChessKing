const express = require('express');
const router = express.Router();
const connectDB = require('../../db');
const { ObjectId } = require('mongodb');

async function main(req, context) {
    try {
        const { accountId, conversationId } = req.body;
        const db = await connectDB(); // ✅ await
        const convCollection = db.collection("Conversation");

        await convCollection.updateOne(
            { _id: new ObjectId(conversationId) },
            { $set: { [`unreadCnt.${accountId}`]: 0 } }
        );

        return { code: 0, msg: 'success' };
    } catch (e) {
        console.log('e', e);
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
