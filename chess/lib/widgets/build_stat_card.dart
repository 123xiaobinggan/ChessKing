import 'package:flutter/material.dart';

Widget buildStatCard({
  required String title,
  required VoidCallback onTap,
  required Map<String, dynamic> stats,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5CC), // 米黄色
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade200,
            offset: const Offset(1, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // 左侧图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // color: Colors.brown.shade100,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              stats['icon'], // 替换为你的图标路径
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),

          // 中间数据部分
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(width: 20), // 标题右侧空出空间
                    Text(
                      '${stats['等级']}', // 等级
                      style: const TextStyle(fontSize: 16, color: Colors.brown),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 数据展示
                // 数据展示（每行 3 个等宽）
                Column(
                  children: _chunkEntries(stats.entries.skip(2).toList()).map((
                    chunk,
                  ) {
                    return Row(
                      children:
                          chunk.map((entry) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: FittedBox(
                                    alignment: Alignment.centerLeft, // 保持靠左
                                    fit: BoxFit.scaleDown, // 只缩小不放大
                                    child: Text(
                                      '${entry.key}: ${entry.value}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList()
                            // 如果 chunk.length < 3，填补空 Expanded 保持三列对齐
                            ..addAll(
                              List.generate(
                                3 - chunk.length,
                                (_) =>
                                    const Expanded(child: SizedBox(width: 30)),
                              ),
                            ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // 右侧箭头
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.brown),
        ],
      ),
    ),
  );
}

List<List<MapEntry<String, dynamic>>> _chunkEntries(
  List<MapEntry<String, dynamic>> entries,
) {
  final List<List<MapEntry<String, dynamic>>> chunks = [];
  for (var i = 0; i < entries.length; i += 3) {
    chunks.add(
      entries.sublist(i, i + 3 > entries.length ? entries.length : i + 3),
    );
  }
  return chunks;
}
