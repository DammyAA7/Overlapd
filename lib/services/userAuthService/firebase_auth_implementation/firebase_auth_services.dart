import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:overlapd/utilities/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utilities/authUtilities/enterOTP.dart';
import '../../../utilities/widgets.dart';
import '../phoneVerificationCode.dart';

class FirebaseAuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  String? _verificationId;
  int? _resendToken;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch(e) {
      if(e.code == 'email-already-in-use'){
        showToast(text: 'The email address is already in use');
      } else {
        showToast(text: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password, BuildContext context) async {
    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthMultiFactorException catch (e){
      final firstHint = e.resolver.hints.first;
      var r = e.resolver;
      if (firstHint is! PhoneMultiFactorInfo) {
        return null;
      }
      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: e.resolver.session,
        multiFactorInfo: firstHint,
        verificationCompleted: (_) {},
        verificationFailed: (_) {},
          codeSent: (verificationId, resendToken) async {
            // See `firebase_auth` example app for a method of retrieving user's sms code:
            // https://github.com/firebase/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/auth.dart#L591
            Navigator.pushReplacement(
              context,
              pageAnimationlr(VerificationCode(verificationId: verificationId, verificationType: 'Resolve', resolver: r)),
            );
          },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch(e) {
      print(e.code);
      if(e.code == 'user-not-found' || e.code == 'wrong-password'){
        showToast(text: 'Invalid email or password');
      } else {
        showToast(text: 'An error occurred: ${e.code}');
      }
    } catch(e){
      showToast(text: 'An error occurred: $e');
    }
    return null;
  }

  // Set the login status to true when the user logs in
  Future<void> setLoggedInAsUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedInAsUser', true);
  }

  // Set the login status to true when the employee logs in
  Future<void> setLoggedInAsEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedInAsEmployee', true);
  }


  // Check if the user is logged in
  Future<bool> isLoggedInAsUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedInAsUser') ?? false;
  }

  // Check if the employee is logged in
  Future<bool> isLoggedInAsEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedInAsEmployee') ?? false;
  }

  // Clear the login status when the user logs out
  Future<void> setLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedInAsEmployee', false);
    await prefs.setBool('isLoggedInAsUser', false);
  }

  String getUserId()  {
    User? user = _auth.currentUser;
    return (user?.uid)!;
  }

  String getUsername() {
    User? user = _auth.currentUser;
    return (user?.email)!;
  }


  Stream<DocumentSnapshot<Map<String, dynamic>>> getPersonalDetails(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Stream<DocumentSnapshot> getAccountInfo(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(
        uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getAccountInfoGet(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(
        uid).get();
  }


  Future<void> signInWithPhoneNumber(String phoneNumber, BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+353${phoneNumber.replaceAll(' ', '')}',
      verificationCompleted: (_){},
      verificationFailed: (FirebaseAuthException e) {
        //showToast(text: 'Verification failed. Please try again.');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        Navigator.of(context).push(pageAnimationrl(EnterOTP(
            mobileNumber: phoneNumber,
            verificationId: verificationId,
            authService: this,
        )));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }


  Future<void> resendOTP(String phoneNumber, BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+353${phoneNumber.replaceAll(' ', '')}',
      verificationCompleted: (_) {},
      verificationFailed: (FirebaseAuthException e) {
        showToast(text: 'Verification failed. Please try again.');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      forceResendingToken: _resendToken,
    );
  }
}