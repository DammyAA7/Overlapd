import 'package:flutter/material.dart';

bool isValidEmail(String email) {
  RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  return emailRegExp.hasMatch(email);
}

Color buttonColor(bool isValid) => isValid ? Colors.black : Colors.grey;

Color textButtonColor(bool isValid) =>  isValid ? Colors.white : Colors.black54;

Color borderColor(bool isValid) =>  isValid ? Colors.grey : Colors.black;

Color textColor(bool isValid) =>  isValid ? Colors.grey : Colors.black;