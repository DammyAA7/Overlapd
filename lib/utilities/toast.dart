import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({required String text}) {
  Fluttertoast.showToast(
      msg: text,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: const Color(0xFF6EE8C5),
      textColor: Colors.white,
      fontSize: 16.0);
}
