import 'package:flutter/material.dart';


Widget buildMenuItem(String label, IconData icon, VoidCallback onTap) {
  return Material(
    color: Colors.white,
    elevation: 4,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: () {
        onTap(); // 先执行操作
        
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    ),
  );
}
