import 'package:flutter/material.dart';

Widget Button(
    BuildContext context,
    String buttonName,
    Function() onPressed,
    double width,
    TextStyle style,
    Color color
    ) {
  return SizedBox(
    width: width,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: color,
        elevation: 0,
      ),
      child: Text(
        buttonName,
        maxLines: 1,
        style: style
      ),
    ),
  );
}