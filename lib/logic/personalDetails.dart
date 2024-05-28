import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

bool isValidEmail(String email) {
  RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  return emailRegExp.hasMatch(email);
}

Color buttonColor(bool isValid) => isValid ? Colors.black : Colors.grey;

Color textButtonColor(bool isValid) =>  isValid ? Colors.white : Colors.black54;

Color borderColor(bool isValid) =>  isValid ? Colors.grey : Colors.black;

Color textColor(bool isValid) =>  isValid ? Colors.grey : Colors.black;

Future createUserCredentials(User? user, String firstName, String lastName, String email) async{
  final docUser = FirebaseFirestore.instance.collection('users').doc(user?.uid);
  final userBox = Hive.box('userInformation');
  final json = {
    'First Name': firstName,
    'Last Name': lastName,
    'Email Address': email,
    'Phone Number': user?.phoneNumber,
    'Address Book' : '',
  };
  userBox.put(user?.uid, json);
  await docUser.set(json);
}

Future<Map<String, dynamic>?> getUserCredentials(String uid) async {
  final userBox = Hive.box('userBox');
  return userBox.get(uid);
}