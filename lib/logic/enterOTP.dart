import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/screens/home/home_screen.dart';
import 'package:overlapd/screens/onboardingScreens/welcomeScreen.dart';
import 'package:overlapd/screens/testScreen.dart';
import '../models/userModel.dart';
import '../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';

Future<bool> verifyOTP(BuildContext context, String verificationId, String pin, String type) async{
  final FirebaseAuthService auth = FirebaseAuthService();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  try{
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: pin,
    );

    if (type == 'Log in' || type == 'Sign up') {
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (type == 'Sign up') {
        await FirebaseFirestore.instance
            .collection('registeredPhoneNumbers')
            .doc(auth.currentUser?.phoneNumber)
            .set({'infoFilled': false});
      }
      final docSnapshot = await FirebaseFirestore.instance
          .collection('registeredPhoneNumbers')
          .doc(auth.currentUser?.phoneNumber)
          .get();
      final infoFilled = docSnapshot.data()?['infoFilled'];
      final welcomeScreenType = infoFilled == false ? 'Sign up' : 'Log in';
      Navigator.of(context).push(pageAnimationrl(
        WelcomeScreen(type: welcomeScreenType),
      ));
    } else {
      User? user = auth.currentUser;
      if (user != null) {
        await user.updatePhoneNumber(credential);
        FirebaseAuth.instance.currentUser?.reload();
        user = auth.currentUser;

        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser?.uid)
            .get();

        //Delete old number
        await firestore.collection('registeredPhoneNumbers')
            .doc(docSnapshot.data()?['Phone Number'])
            .delete();

        String newPhoneNumber = user?.phoneNumber ?? "";
        // Update the phone number in 'registeredPhoneNumbers' collection
        await firestore.collection('registeredPhoneNumbers')
            .doc(newPhoneNumber)
            .set({'infoFilled': true}, SetOptions(merge: true));
        // Update the phone number in Firestore

        // Update the phone number in the 'users' collection
        await firestore.collection('users')
            .doc(user?.uid)
            .update({'Phone Number': newPhoneNumber});
        final userInfo = await auth.getUserInfo(user!.uid);
        if (userInfo != null) {
          await Hive.box<UserModel>('userBox').delete(user.uid);
          await auth.storeUserInfoInHive(user.uid, userInfo);
        }
      }
      auth.setLoggedInAsUser();
      Navigator.of(context).push(pageAnimationrl(
          const HomeScreen()
      ));
    }
    return true;
  } catch (e) {
    return false;
  }
}

Color buttonColor(bool isValid) => isValid ? Colors.black : Colors.grey;

Color textButtonColor(bool isValid) => isValid ? Colors.white : Colors.black54;
