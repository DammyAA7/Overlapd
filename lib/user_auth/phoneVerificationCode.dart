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
  final String verificationId;
  const VerificationCode({super.key, required this.verificationId});

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  bool incorrectCode = true;
  var code;

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w700),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF6EE8C5).withOpacity(0.8)),
      borderRadius: BorderRadius.circular(20),

    ),
  );

  @override
  void initState(){
    super.initState();
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: const Color(0xFF6EE8C5).withOpacity(0.8), width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration?.copyWith(
                        color: const Color(0xFF6EE8C5).withOpacity(0.3),
                      )),
                  validator: (s) {
                    return s == widget.verificationId ? null : 'Pin is incorrect';
                    },
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: (pin) async {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: pin,
                    );

                    try {
                      await FirebaseAuth.instance.currentUser!.multiFactor.enroll(
                        PhoneMultiFactorGenerator.getAssertion(
                          credential,
                        ),
                      );
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_UID)
                          .update({'isPhoneNumberVerified': true});
                      _checkUserRoleAndNavigate(_UID);
                      Navigator.pushReplacement(
                        context,
                        pageAnimationlr(const Home()),
                      );
                    } on FirebaseAuthException catch (e) {
                      print(e.message);
                    }
                    setState(() {
                      code = pin;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkUserRoleAndNavigate(String userId) async {
    final pickersCollection = FirebaseFirestore.instance.collection('employees');
    final snapshot = await pickersCollection.get();
    final pickerUids = snapshot.docs.map((doc) => doc.id).toList();
    DocumentSnapshot userInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get();

    if (pickerUids.contains(userId)) {
      // User is a picker (employee)
      Navigator.pushReplacementNamed(context, '/picker_page');
      await _auth.setLoggedInAsEmployee();
    } else {
      // User is not a picker (customer)
      await _auth.setLoggedInAsUser();
      if(_auth.currentUser?.emailVerified == true && userInfo['Phone Number'].toString().isNotEmpty && userInfo['isPhoneNumberVerified']){
        print(_auth.currentUser?.phoneNumber);
        print(_auth.currentUser?.multiFactor.getEnrolledFactors().toString());
        Navigator.pushReplacementNamed(context, '/home_page');
      } else if(_auth.currentUser?.emailVerified == true && userInfo['Phone Number'].toString().isEmpty) {
        Navigator.pushReplacementNamed(context, '/phone_verification_page');
      } else{

      }

    }
  }
}
