import axios from "axios";


const key = "app-qXrq80lTHFNWYlFlNRKPzSR1"
const url = "https://api.dify.ai/v1/chat-messages"

const headers = {
    "Authorization": `Bearer ${key}`,
    "Content-type": "application/json"
}

const data = {
    "inputs": {
        "board": `
            //黑方
            {
                type: '車',
                isRed: false,
                pos: { row: 0, col: 0 },
            },
            {
                'type': '馬',
                isRed: false,
                pos: { row: 0, col: 1 },
            },
            {
                'type': '象',
                isRed: false,
                pos: { row: 0, col: 2 },
            },
            {
                'type': '仕',
                isRed: false,
                pos: { row: 0, col: 3 },
            },
            {
                'type': '將',
                isRed: false,
                pos: { row: 0, col: 4 },
            },
            {
                'type': '仕',
                isRed: false,
                pos: { row: 0, col: 5 },
            },
            {
                'type': '象',
                isRed: false,
                pos: { row: 0, col: 6 },
            },
            {
                'type': '馬',
                isRed: false,
                pos: { row: 0, col: 7 },
            },
            {
                'type': '車',
                isRed: false,
                pos: { row: 0, col: 8 },
            },
            {
                'type': '炮',
                isRed: false,
                pos: { row: 2, col: 1 },
            },
            {
                'type': '炮',
                isRed: false,
                pos: { row: 2, col: 7 },
            },
            {
                'type': '卒',
                isRed: false,
                pos: { row: 3, col: 0 },
            },
            {
                'type': '卒',
                isRed: false,
                pos: { row: 3, col: 2 },
            },
            {
                'type': '卒',
                isRed: false,
                pos: { row: 3, col: 4 },
            },
            {
                'type': '卒',
                isRed: false,
                pos: { row: 3, col: 6 },
            },
            {
                'type': '卒',
                isRed: false,
                pos: { row: 3, col: 8 },
            },

            // 红方
            {
                'type': '車',
                isRed: true,
                pos: { row: 9, col: 0 },
            },
            {
                'type': '馬',
                isRed: true,
                pos: { row: 9, col: 1 },
            },
            {
                'type': '相',
                isRed: true,
                pos: { row: 9, col: 2 },
            },
            {
                'type': '仕',
                isRed: true,
                pos: { row: 9, col: 3 },
            },
            {
                'type': '帥',
                isRed: true,
                pos: { row: 9, col: 4 },
            },
            {
                'type': '仕',
                isRed: true,
                pos: { row: 9, col: 5 },
            },
            {
                'type': '相',
                isRed: true,
                pos: { row: 9, col: 6 },
            },
            {
                'type': '馬',
                isRed: true,
                pos: { row: 9, col: 7 },
            },
            {
                'type': '車',
                isRed: true,
                pos: { row: 9, col: 8 },
            },
            {
                'type': '炮',
                isRed: true,
                pos: { row: 7, col: 1 },
            },
            {
                'type': '炮',
                isRed: true,
                pos: { row: 7, col: 7 },
            },
            {
                'type': '兵',
                isRed: true,
                pos: { row: 6, col: 0 },
            },
            {
                'type': '兵',
                isRed: true,
                pos: { row: 6, col: 2 },
            },
            {
                'type': '兵',
                isRed: true,
                pos: { row: 6, col: 4 },
            },
            {
                'type': '兵',
                isRed: true,
                pos: { row: 6, col: 6 },
            },
            {
                'type': '兵',
                isRed: true,
                pos: { row: 6, col: 8 },
            }
        `,
        "you": "red",
        "level": "初级"
    },
    "query": '请给出合适的落子走法',
    "response_mode": "blocking",
    "conversation_id": "",
    "user": "xiaobinggan",
    "files": [],
}

async function main() {
    try{
    const response = await axios.post(url, data, { headers })
    console.log(response.data.answer)
    }catch(error){
        console.log(error)
    }
}

main()