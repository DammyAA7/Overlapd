import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:overlapd/utilities/widgets.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../utilities/toast.dart';

class SignUp extends StatefulWidget {
  static const id = 'signup_page';

  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final FirebaseAuthService _auth = FirebaseAuthService();
  final InputBoxController _firstNameController = InputBoxController();
  final InputBoxController _lastNameController = InputBoxController();
  final InputBoxController _emailController = InputBoxController();
  final InputBoxController _passwordController = InputBoxController();
  final InputBoxController _rePasswordController = InputBoxController();

  bool _areFieldsValid() {
    String email = _emailController.getText();
    String password = _passwordController.getText();
    bool isEmailValid = email.isNotEmpty && _isValidEmail(email);
    bool isPasswordValid = _passwordController.getText().isNotEmpty && _isValidPassword(password);
    return _firstNameController.getText().isNotEmpty &&
        _lastNameController.getText().isNotEmpty &&
        isEmailValid && isPasswordValid &&
        _passwordController.getText() == _rePasswordController.getText();
  }

  bool _isValidEmail(String email) {
    // Use a regular expression to check the email format
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // Check if the password is at least 10 characters long
    if (password.length < 10) {
      return false;
    }

    // Check if the password contains at least 1 capital letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return false;
    }

    // Check if the password contains at least 1 number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return false;
    }

    // Check if the password contains at least 1 special character
    if (!RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
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
          child: Center(
            child: SingleChildScrollView(
              reverse: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create New Account',
                      style: Theme.of(context).textTheme.displayMedium),
                  pageText(context, 'First Name'),
                  letterInputBox('Enter First Name', true, false, _firstNameController),
                  pageText(context, 'Last Name'),
                  letterInputBox('Enter Last Name', true, false, _lastNameController),
                  pageText(context, 'Email Address'),
                  emailInputBox('Enter Email Address', true, false, _emailController),
                  pageText(context, 'Password'),
                  passwordInputBox('Enter Password', false, true, _passwordController),
                  pageText(context, 'Confirm Password'),
                  passwordConfirmationInputBox('Re-type Password', false, true, _passwordController, _rePasswordController),
                  const SizedBox(height: 15),
                  Center(
                    child: Column(
                      children: [
                        solidButton(context, 'Sign up', () {
                          _signUp();
                        }, _areFieldsValid()),
                        const SizedBox(height: 10),
                        const Text(
                          'Already have an account?',
                          textAlign: TextAlign.center,
                        ),
                        textButton(context, 'Log in', '/login_page')
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async{
    String email = _emailController.getText();
    String password = _passwordController.getText();

    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    if (user != null){
      await _auth.setLoggedInAsUser();
      createUserCredentials(user: user);
      showToast(text: "User created successfully");
      Navigator.pushNamed(context, '/email_verification_page');
    } else{
      print("Sign up error!");
    }

  }
  Future createUserCredentials({required User? user}) async{
    final docUser = FirebaseFirestore.instance.collection('users').doc(user?.uid);
    final json = {
      'First Name': _firstNameController.getText(),
      'Last Name': _lastNameController.getText(),
      'Email Address': _emailController.getText(),
      'Phone Number': '',
      'Address Book' : '',
      'isPhoneNumberVerified': false
    };
    await docUser.set(json);
  }
}