const express = require('express');
const router = express.Router();
const connectDB = require('../../db'); // 引入数据库连接
const { ObjectId } = require('bson');

async function main(req, context) {
    try {
        const { roomId } = req.body;
        console.log('roomId', roomId);
        const db = await connectDB();
        const roomCollection = db.collection("Room");
        const room = await roomCollection.findOne({
            _id: new ObjectId(roomId)
        })
        if (!room) {
            return { code: 1, msg: "房间不存在" };
        }
        return { code: 0, room }
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