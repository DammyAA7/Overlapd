import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/services/userAuthService/login.dart';
import 'package:overlapd/utilities/toast.dart';

import '../../utilities/widgets.dart';

class ForgotPassword extends StatefulWidget {
  static const id = 'forgotten_password_page';
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final InputBoxController _emailController = InputBoxController();

  bool _areFieldsValid() {
    String email = _emailController.getText();
    bool isEmailValid = email.isNotEmpty && _isValidEmail(email);
    return
      isEmailValid;
  }

  bool _isValidEmail(String email) {
    // Use a regular expression to check the email format
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegExp.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    // Add a listener to the email controller
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    // Check if the email is valid
    setState(() {});
  }
  @override
  void dispose() {
    _emailController.dispose();
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
              onPressed: () {
                // Navigate to the home page with a fade transition
                Navigator.pushReplacement(
                  context,
                  pageAnimationlr(const Login()),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send a reset link to change password'),
            pageText(context, 'Email Address'),
            emailInputBox('Enter your email address', false, false, _emailController),
            const SizedBox(height: 10),
            solidButton(context, 'Reset Password', _sendResetLink, _areFieldsValid()),
          ],
        ),
      ),
    );
  }

  void _sendResetLink() async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.getText());
      showToast(text: 'Successfully sent reset email link. Check inbox');
      Navigator.pushReplacement(
        context,
        pageAnimationlr(const Login()),
      );
    } on FirebaseAuthException catch(e){
      showToast(text: e.toString());
    }
  }
}
