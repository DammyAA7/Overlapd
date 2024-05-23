import 'package:flutter/material.dart';

bool isPhoneNumberValid(String phoneNumber) {
  // Remove any spaces from the phone number
  final sanitizedNumber = phoneNumber.replaceAll(' ', '');
  // Check if the sanitized number is exactly 9 digits long
  return sanitizedNumber.length == 9 && int.tryParse(sanitizedNumber) != null;
}

Color buttonColor(bool isValid) => isValid ? Colors.black : Colors.grey;

Color textButtonColor(bool isValid) =>  isValid ? Colors.white : Colors.black54;