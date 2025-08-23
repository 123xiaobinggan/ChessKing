import 'package:flutter/material.dart';
import 'dart:io';

Widget avatarImage(String path, bool isNetwork) {
  if (isNetwork) {
    return ClipOval(child: Image.network(path, fit: BoxFit.cover));
  }
  else{
    return ClipOval(child: Image.file(File(path), fit: BoxFit.cover));
  }
}
