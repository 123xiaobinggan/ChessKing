
const { spawn } = require("child_process");


module.exports = { pikafish,cancelAI, boardToFEN, uciToMove };

let currentEngine = null; // 保存正在运行的引擎

function pikafish(fen, depth = 8) {
    console.log('depth',depth);
    return new Promise((resolve, reject) => {
        const engine = spawn("/opt/Linux/pikafish-avx2");
        currentEngine = engine; // 保存引用，悔棋时能 kill

        let seenUciOk = false;
        let isReady = false;

        engine.stdout.on("data", (data) => {
            const lines = data.toString().split(/\r?\n/);
            for (const line of lines) {
                if (!line) continue;
                console.log("engine:", line);

                if (line.includes("uciok") && !seenUciOk) {
                    seenUciOk = true;
                    engine.stdin.write("setoption name EvalFile value /opt/Linux/pikafish.nnue\n");
                    engine.stdin.write("isready\n");
                    continue;
                }

                if (line.includes("readyok") && !isReady) {
                    isReady = true;
                    engine.stdin.write(`position fen ${fen}\n`);
                    engine.stdin.write(`go depth ${depth}\n`);
                    continue;
                }

                if (line.startsWith("bestmove")) {
                    const uciMove = line.split(" ")[1];
                    engine.kill();
                    if (currentEngine === engine) currentEngine = null; // 清理
                    resolve(uciMove);
                    return;
                }
            }
        });

        engine.stderr.on("data", (data) => {
            console.error("Pikafish stderr:", data.toString());
        });

        engine.on("error", (err) => {
            reject(err);
        });

        engine.on("exit", () => {
            if (currentEngine === engine) currentEngine = null;
        });

        engine.stdin.write("uci\n");
    });
}

function cancelAI() {
    if (currentEngine) {
        currentEngine.kill("SIGKILL");
        currentEngine = null;
        console.log("AI计算已被取消");
    }
}

//将棋盘转成Fen格式
function boardToFEN(board, redTurn = true) {
    // 初始化 10x9 棋盘
    const rows = Array.from({ length: 10 }, () => Array(9).fill('1'));
    console.log('redTurn',redTurn);
    // 映射棋子类型到 FEN
    const codeMap = {
        '將': 'k', '帥': 'K',
        '仕': 'a', '仕': 'A',
        '相': 'b', '象': 'B',
        '馬': 'n', '馬': 'N',
        '車': 'r', '車': 'R',
        '炮': 'c', '炮': 'C',
        '兵': 'p', '卒': 'p'
    };

    for (const p of board) {
        let r = p.pos.row;
        let c = p.pos.col;
        let isRed = p.isRed;

        const code = codeMap[p.type] || p.type;
        rows[r][c] = isRed ? code.toUpperCase() : code.toLowerCase();
    }

    // 压缩每行的空格
    const fenRows = rows.map(row => {
        let fenRow = '';
        let empty = 0;
        for (const cell of row) {
            if (cell === '1') empty++;
            else {
                if (empty > 0) {
                    fenRow += empty;
                    empty = 0;
                }
                fenRow += cell;
            }
        }
        if (empty > 0) fenRow += empty;
        return fenRow;
    });
    var dir='w'
    if(redTurn==false){
        dir = 'b'
    }
    
    return fenRows.join('/') + ' ' + dir;
}

//将Fen转成对象格式
function uciToMove(bestmove, board) {
    const cols = { a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8 };

    const fromCol = cols[bestmove[0]];
    const fromRow = 9-parseInt(bestmove[1]);
    const toCol = cols[bestmove[2]];
    const toRow = 9-parseInt(bestmove[3]);

    console.log('bestmove','from:',fromRow,' ',fromCol,';',
        'to:',toRow,' ',toCol
    );

    // 找到移动的棋子类型
    const movingPiece = board.find(p => p.pos.row === fromRow && p.pos.col === fromCol);
    if (!movingPiece) {
        throw new Error("找不到要移动的棋子");
    }

    return {
        step: {
            type: movingPiece.type,
            from: { row: fromRow, col: fromCol },
            to: { row: toRow, col: toCol }
        }
    };
}

