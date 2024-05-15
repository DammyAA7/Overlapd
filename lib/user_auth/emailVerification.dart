import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/home.dart';
import 'package:overlapd/user_auth/phoneVerification.dart';

import '../utilities/toast.dart';
import '../utilities/widgets.dart';
import 'firebase_auth_implementation/firebase_auth_services.dart';
import 'login.dart';

class EmailVerification extends StatefulWidget {
  static const id = 'email_verification_page';
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  late Timer timer;
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool isNumberVerified = false;
  late final String _UID = _auth.getUserId();
  @override
  void initState(){
    super.initState();
    isPhoneNumberVerified();
    _emailVerificationLink();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _auth.currentUser?.reload();
      if(_auth.currentUser!.emailVerified == true){
        timer.cancel();
        showToast(text: 'Email Verified');
        if(isNumberVerified){
          Navigator.pushReplacement(
            context,
            pageAnimationlr(const Home()),
          );
        } else{
          Navigator.pushReplacement(
            context,
            pageAnimationlr(const PhoneVerification()),
          );
        }
      }
    });
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
              const Text('Verification sent'),
              ElevatedButton(onPressed: (){
                try{
                  _emailVerificationLink();
                  showToast(text: 'Verification sent');
                } catch (e){
                  showToast(text: e.toString());
                }

              }, child: const Text('Resend Verification Email'))
            ],
          ),
        ),
      ),
    );
  }
  void _emailVerificationLink(){
    try{
      _auth.currentUser?.sendEmailVerification();
    } catch (e){
      showToast(text: 'Error sending verification link. Try again!');
    }
  }

  void isPhoneNumberVerified() async{
    DocumentSnapshot userInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(_UID)
        .get();
    setState(() {
      isNumberVerified = userInfo['isPhoneNumberVerified'];
    });
  }
}
