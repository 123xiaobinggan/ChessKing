import axios from "axios";

// MatchPlayer
// const url = "https://chess-king-1gvhs90sfc60354d-1358387153.ap-shanghai.app.tcloudbase.com/MatchPlayer"
             
//Move
// const url = "https://chess-king-1gvhs90sfc60354d-1358387153.ap-shanghai.app.tcloudbase.com/Move"

//GetOpponentMove
// const url = "https://chess-king-1gvhs90sfc60354d-1358387153.ap-shanghai.app.tcloudbase.com/GetOpponentMove"

//GetVersion
const url = "http://120.48.156.237:3000/GetVersion"

// const params = {
//     // player: {
//     //     accountId: 'binggangan',
//     //     username: 'binggangan',
//     //     avatar: 'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/xiaobinggan.jpg?v=1754218446732',
//     //     level: '1-1',
//     //     isRed: false,
//     //     timeLeft: 900
//     // },
//     // type: 'ChineseChessMatch',
//     // roomId: ''
//     roomId: '3d918a1b68aea7ff0006103443f9d481',
//     // moves_length: 0,
//     // step:{
//     //     accountId: 'binggangan',
//     //     type: '車',
//     //     from: {
//     //         row: 9,
//     //         col: 0
//     //     },
//     //     to:{
//     //         row: 8,
//     //         col: 0
//     //     }
//     // }
//     // undo
//     step:{
//         accountId: 'binggangan',
//         type: '同意和棋',
//         from: {
//             row: -1,
//             col: -1
//         },
//         to:{
//             row: -1,
//             col: -1
//         }
//     }
//     // sendMessage
//     // step:{
//     //     accountId: 'binggangan',
//     //     type: '下午好',
//     //     from: {
//     //         row: -1,
//     //         col: -1
//     //     },
//     //     to:{
//     //         row: -1,
//     //         col: -1
//     //     }
//     // }
// }

async function main() {
    try {
        const res = await axios.post(url, {
            headers: {
                'Content-Type': 'application/json'
            }
        }
        )
        console.log(res.data)
    } catch (err) {
        console.log(err)
    }
}

main();