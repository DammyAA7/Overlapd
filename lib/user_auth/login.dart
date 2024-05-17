import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/user_auth/phoneVerificationCode.dart';

import 'package:overlapd/utilities/widgets.dart';

import 'firebase_auth_implementation/firebase_auth_services.dart';

class Login extends StatefulWidget {
  static const id = 'login_page';

  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final InputBoxController _emailController = InputBoxController();
  final InputBoxController _passwordController = InputBoxController();

  bool _areFieldsValid() {
    String email = _emailController.getText();
    bool isEmailValid = email.isNotEmpty && _isValidEmail(email);
    return
        isEmailValid &&
        _passwordController.getText().isNotEmpty;
  }

  bool _isValidEmail(String email) {
    // Use a regular expression to check the email format
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegExp.hasMatch(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFEFEFE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log in to your account',
                  style: Theme.of(context).textTheme.displayMedium),
              pageText(context, 'Email Address'),
              emailInputBox('Enter your email address', false, false, _emailController),
              const SizedBox(height: 10),
              pageText(context, 'Password'),
              passwordInputBoxForLogin('Enter your password', false, true, _passwordController),
              textButton(
                  context, 'Forgotten password?', '/forgotten_password_page'),
              Center(
                child: Column(
                  children: [
                    solidButton(context, 'Log in', _logIn, _areFieldsValid()),
                    const SizedBox(height: 10),
                    const Text(
                      'Don\'t have an account yet?',
                      textAlign: TextAlign.center,
                    ),
                    textButton(context, 'Sign Up', '/signup_page')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _logIn() async{
    String email = _emailController.getText();
    String password = _passwordController.getText();
    await _auth.signInWithEmailAndPassword(email, password, context);
    final pickersCollection = FirebaseFirestore.instance.collection('employees');
    final snapshot = await pickersCollection.get();
    final pickerUids = snapshot.docs.map((doc) => doc.id).toList();

    if (pickerUids.contains(_auth.currentUser?.uid)) {
      // User is a picker (employee)
      Navigator.pushReplacementNamed(context, '/picker_page');
      await _auth.setLoggedInAsEmployee();
    } else {
      // User is not a picker (customer)
      if(_auth.currentUser?.emailVerified == false ){
        print(_auth.currentUser?.phoneNumber);
        Navigator.pushReplacementNamed(context, '/email_verification_page');
      } else if(_auth.currentUser?.emailVerified == true) {
        reauthenticateUser();
        Navigator.pushReplacementNamed(context, '/phone_verification_page');
      }
    }
  }

  void reauthenticateUser() async {
    String email = _emailController.getText();
    String password = _passwordController.getText();
    final user = FirebaseAuth.instance.currentUser;
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user!.reauthenticateWithCredential(credential);
  }
}