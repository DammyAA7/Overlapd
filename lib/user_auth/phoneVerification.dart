import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:overlapd/user_auth/phoneVerificationCode.dart';
import 'package:overlapd/utilities/toast.dart';

import '../utilities/widgets.dart';
import 'firebase_auth_implementation/firebase_auth_services.dart';
import 'login.dart';

class PhoneVerification extends StatefulWidget {
  static const id = 'phone_verification_page';
  const PhoneVerification({super.key});

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  final InputBoxController _phoneNumber = InputBoxController();
  FocusNode focusNode = FocusNode();


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
              pageText(context, 'Phone number'),
              IntlPhoneField(
                focusNode: focusNode,
                decoration: InputDecoration(
                  contentPadding:
                  const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
                  filled: true,
                  fillColor: const Color(0xFF6EE8C5).withOpacity(0.1),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: const Color(0xFF6EE8C5).withOpacity(0.6),
                      width: 2.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      color: const Color(0xFF6EE8C5).withOpacity(0.6),
                      width: 4.5,
                    ),
                  ),
                  errorStyle: const TextStyle(
                    fontSize: 18.0, // Adjust as needed
                    fontWeight: FontWeight.bold,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.red.withOpacity(0.6),
                      width: 3.5,
                    ),
                  ),
                  hintStyle: const TextStyle(
                      color: Color(0xFF727E7B),
                      fontFamily: 'Darker Grotesque',
                      fontSize: 22.0
                  ),
                ),
                languageCode: "ie",
                onChanged: (phone) {
                  _phoneNumber.controller.text = phone.completeNumber;

                },
                onCountryChanged: (country) {
                  if(country.name != 'Ireland'){
                    showToast(text: 'Country not supported. Only available in Ireland');
                  }
                },
              ),
              solidButton(context, 'Send code', () => storeNumber(), _phoneNumber.getText().isNotEmpty)
            ],
          ),
        ),
      ),
    );
  }

  void storeNumber() async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_UID)
        .update({'Phone Number': _phoneNumber.getText()});

    getSMSVerification();
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
      verificationCompleted: (_) {},
      verificationFailed: (_) {},
      codeSent: (verificationId, resendToken){
        // See `firebase_auth` example app for a method of retrieving user's sms code:
        // https://github.com/firebase/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/auth.dart#L591
        Navigator.pushReplacement(
          context,
          pageAnimationlr(VerificationCode(verificationId: verificationId,)),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }
}
