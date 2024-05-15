import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_auth_implementation/firebase_auth_services.dart';

class PhoneVerification extends StatefulWidget {
  static const id = 'phone_verification_page';
  const PhoneVerification({super.key});

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  String? phoneNumber;
  User? user;

  @override
  void initState(){
    super.initState();
    getSMSVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Verification sent'),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> getSmsCodeFromUser(BuildContext context) async {
    String? smsCode;

    // Update the UI - wait for the user to enter the SMS code
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('SMS code:'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Sign in'),
            ),
            OutlinedButton(
              onPressed: () {
                smsCode = null;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
          content: Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (value) {
                smsCode = value;
              },
              textAlign: TextAlign.center,
              autofocus: true,
            ),
          ),
        );
      },
    );

    return smsCode;
  }

  void getSMSVerification() async{
    DocumentSnapshot userInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(_UID)
        .get();
    final session = await user?.multiFactor.getSession();
    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      multiFactorSession: session,
      phoneNumber: userInfo['Phone Number'],
      verificationCompleted: (_) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_UID)
            .update({'isPhoneNumberVerified': true});
      },
      verificationFailed: (_) {},
      codeSent: (String verificationId, int? resendToken) async {
        // See `firebase_auth` example app for a method of retrieving user's sms code:
        // https://github.com/firebase/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/auth.dart#L591
        final smsCode = await getSmsCodeFromUser(context);

        if (smsCode != null) {
          // Create a PhoneAuthCredential with the code
          final credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );

          try {
            await user?.multiFactor.enroll(
              PhoneMultiFactorGenerator.getAssertion(
                credential,
              ),
            );
          } on FirebaseAuthException catch (e) {
            print(e.message);
          }
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }
}
