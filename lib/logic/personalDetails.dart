import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/userModel.dart';

bool isValidEmail(String email) {
  RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  return emailRegExp.hasMatch(email);
}

Color buttonColor(bool isValid) => isValid ? Colors.black : Colors.grey;

Color textButtonColor(bool isValid) => isValid ? Colors.white : Colors.black54;

Color borderColor(bool isValid) => isValid ? Colors.grey : Colors.black;

Color textColor(bool isValid) => isValid ? Colors.grey : Colors.black;

Future createUserCredentials(User? user, String firstName, String lastName, String email) async{
  final docUser = FirebaseFirestore.instance.collection('users').doc(user?.uid);

  final userBox = Hive.box<UserModel>('userBox');

  final userModel = UserModel(
    firstName: firstName,
    lastName: lastName,
    email: email,
    phoneNumber: user?.phoneNumber ?? '',
    emailVerified: user?.emailVerified ?? false
  );
  // Save to Hive
  userBox.put(user?.uid, userModel);

  final json = {
    'First Name': firstName,
    'Last Name': lastName,
    'Email Address': email,
    'Phone Number': user?.phoneNumber,
    'Email Verified': user?.emailVerified
  };

  await docUser.set(json);

  // Update infoFilled field to true
  await FirebaseFirestore.instance
      .collection('registeredPhoneNumbers')
      .doc(user?.phoneNumber)
      .update({'infoFilled': true});
}

Future<UserModel?> getUserCredentials(String? uid) async {
  if (uid == null) return null;

  final userBox = Hive.box<UserModel>('userBox');

  // Retrieve from Hive
  UserModel? userModel = userBox.get(uid);

  // If not found in Hive, try fetching from Firestore
  if (userModel == null) {
    final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        userModel = UserModel(
          firstName: data['First Name'],
          lastName: data['Last Name'],
          email: data['Email Address'],
          phoneNumber: data['Phone Number'],
          emailVerified: data['Email Verified']
        );
        // Save to Hive for future retrieval
        userBox.put(uid, userModel);
      }
    }
  }

  return userModel;
}