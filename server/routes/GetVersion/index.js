const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
    try {
        const db = await connectDB();
        const versionCollection = db.collection('Version');
        const latestRecord = await versionCollection
            .findOne({}, { sort: { updateTime: -1 } });
        console.log('latestRecord',latestRecord)
        if (!latestRecord) {
            return { code: 1, msg: "没有版本" };
        }
        return { code: 0, data:latestRecord };
    }
    catch (e) {
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



/*
    {
        updateTime:
        url:
        version:
    }
*/