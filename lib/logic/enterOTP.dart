import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/onboardingScreens/welcomeScreen.dart';
import 'package:overlapd/screens/testScreen.dart';
import '../utilities/widgets.dart';

Future<bool> verifyOTP(BuildContext context, String verificationId, String pin,
    String type) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: pin,
    );

    if (type == 'Log in' || type == 'Sign up') {
      await auth.signInWithCredential(credential);
      Navigator.of(context).push(pageAnimationrl(const WelcomeScreen()));
    } else {
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        await currentUser.updatePhoneNumber(credential);
      }
      Navigator.of(context).push(pageAnimationrl(const TestScreen()));
    }
    return true;
  } catch (e) {
    return false;
  }
}

Color buttonColor(bool isValid) => isValid ? Colors.black : Colors.grey;

Color textButtonColor(bool isValid) => isValid ? Colors.white : Colors.black54;
