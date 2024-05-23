import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/onboardingScreens/welcomeScreen.dart';
import '../utilities/widgets.dart';

Future<bool> verifyOTP(BuildContext context, String verificationId, String pin) async{
  FirebaseAuth auth = FirebaseAuth.instance;
  try{
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: pin,
    );
    await auth.signInWithCredential(credential);
    Navigator.of(context).push(pageAnimationrl(
      const WelcomeScreen()
    ));
    return true;
  } catch(e){
    return false;
  }
}

Color buttonColor(bool isValid) => isValid ? Colors.black : Colors.grey;

Color textButtonColor(bool isValid) =>  isValid ? Colors.white : Colors.black54;