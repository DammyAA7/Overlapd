import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/home.dart';

import '../utilities/toast.dart';
import '../utilities/widgets.dart';
import 'firebase_auth_implementation/firebase_auth_services.dart';
import 'login.dart';

class Verification extends StatefulWidget {
  static const id = 'verification_page';
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  late Timer timer;
  final FirebaseAuthService _auth = FirebaseAuthService();
  @override
  void initState(){
    super.initState();
    _emailVerificationLink();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _auth.currentUser?.reload();
      if(_auth.currentUser!.emailVerified == true){
        timer.cancel();
        showToast(text: 'Email Verified');
        Navigator.pushReplacement(
          context,
          pageAnimationlr(const Home()),
        );
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
}
