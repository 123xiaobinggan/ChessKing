const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
    try {
        const { accountId1, accountId2 } = req.body;
        const db = await connectDB();
        const conversationCollection = db.collection('Conversation');

        // 查询是否已有会话
        const conversation = await conversationCollection.findOne({
            members: { $all: [accountId1, accountId2], $size: 2 }
        });

        if (conversation) {
            return { code: 0, conversationId: conversation._id };
        } else {
            const newConversation = await conversationCollection.insertOne({
                members: [accountId1, accountId2],
                lastMessage: '',
                lastTime: new Date(),
                unreadCnt: {
                    [accountId1]: 0,
                    [accountId2]: 0
                }
            });

            return { code: 0, conversationId: newConversation.insertedId };
        }
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
