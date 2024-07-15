import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/home/home.dart';
import 'package:overlapd/utilities/toast.dart';
import '../../utilities/widgets.dart';
import 'firebase_auth_implementation/firebase_auth_services.dart';
import 'package:pinput/pinput.dart';

import 'login.dart';

class VerificationCode extends StatefulWidget {
  static const id = 'phone_verification_code_page';
  final String verificationId;
  final String verificationType;
  final resolver;
  const VerificationCode(
      {super.key,
      required this.verificationId,
      required this.verificationType,
      this.resolver});

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
    textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w700),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF6EE8C5).withOpacity(0.8)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  @override
  void initState() {
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                // Navigate to the home page with a fade transition
                try {
                  await _auth.setLoggedOut();
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    pageAnimationlr(const Login()),
                  );
                } catch (e) {
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
                    border: Border.all(
                        color: const Color(0xFF6EE8C5).withOpacity(0.8),
                        width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration?.copyWith(
                    color: const Color(0xFF6EE8C5).withOpacity(0.3),
                  )),
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onChanged: (s) {
                    if (s.length < 6) {
                      setState(() {
                        incorrectCode = true;
                      });
                    }
                  },
                  onCompleted: (pin) async {
                    setState(() {
                      code = pin;
                    });
                    final credential = PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: pin,
                    );
                    if (widget.verificationType == 'Enroll') {
                      try {
                        await FirebaseAuth.instance.currentUser!.multiFactor
                            .enroll(
                          PhoneMultiFactorGenerator.getAssertion(
                            credential,
                          ),
                        );
                        setState(() {
                          incorrectCode = true;
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_UID)
                            .update({'isPhoneNumberVerified': true});
                        _checkUserRoleAndNavigate();
                      } on FirebaseAuthException catch (e) {
                        print(e.message);
                        setState(() {
                          incorrectCode = false;
                        });
                      }
                    } else if (widget.verificationType == 'Resolve') {
                      try {
                        await widget.resolver.resolveSignIn(
                          PhoneMultiFactorGenerator.getAssertion(
                            credential,
                          ),
                        );
                        setState(() {
                          incorrectCode = true;
                        });
                        _checkUserRoleAndNavigate();
                      } on FirebaseAuthException catch (e) {
                        print(e.message);
                        setState(() {
                          incorrectCode = false;
                        });
                      }
                    }
                  },
                ),
              ),
              incorrectCode
                  ? const SizedBox.shrink()
                  : const Text('Pin is incorrect')
            ],
          ),
        ),
      ),
    );
  }

  void _checkUserRoleAndNavigate() async {
    await _auth.setLoggedInAsUser();
    Navigator.pushReplacementNamed(context, '/home_page');
  }
}
