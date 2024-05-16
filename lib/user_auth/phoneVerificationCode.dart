import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/home.dart';
import '../utilities/widgets.dart';
import 'firebase_auth_implementation/firebase_auth_services.dart';
import 'package:pinput/pinput.dart';

import 'login.dart';

class VerificationCode extends StatefulWidget {
  static const id = 'phone_verification_code_page';
  const VerificationCode({super.key});

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  @override
  void initState(){
    super.initState();
    getSMSVerification();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async{
                // Navigate to the home page with a fade transition
                try{
                  await _auth.setLoggedOut();
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    pageAnimationlr(const Login()),
                  );
                } catch (e){
                  print(e);
                }
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Setup 2FA with phone number'),
              Pinput(
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyDecorationWith(
                  border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration?.copyWith(
                      color: const Color.fromRGBO(234, 239, 243, 1),
                    )),
                validator: (s) {
                  return s == '2222' ? null : 'Pin is incorrect';
                  },
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (pin) => print(pin),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getSMSVerification() async{
    DocumentSnapshot userInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(_UID)
        .get();
    final session = await FirebaseAuth.instance.currentUser!.multiFactor.getSession();
    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      multiFactorSession: session,
      phoneNumber: userInfo['Phone Number'],
      verificationCompleted: (_) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_UID)
            .update({'isPhoneNumberVerified': true});
        Navigator.pushReplacement(
          context,
          pageAnimationlr(const Home()),
        );
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
            await FirebaseAuth.instance.currentUser!.multiFactor.enroll(
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
}
