
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/logic/signInLink.dart';
import 'package:overlapd/utilities/customButton.dart';
import '../logic/personalDetails.dart';
import '../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _isEmailVerified = false;
  Map<String, dynamic>? _userJson;
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handleDynamicLinks('dammyade07@gmail.com');
    _checkEmailVerification();
    _loadUserCredentials();
  }

  Future<void> _loadUserCredentials() async {
    final userJson = await getUserCredentials(_auth.getUserId());
    setState(() {
      _userJson = userJson;
    });
  }

  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser; // Refresh the user instance
      if (user!.emailVerified) {
        setState(() {
          _isEmailVerified = true;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isEmailVerified
            ? Text(
          'Email is verified',
          style: Theme.of(context).textTheme.headline6,
        )
            : Button(
            context,
            'attach',
                () async{
                  //await _auth.sendSignInLinkToEmail('dammyade07@gmail.com');
                  print('First Name: ${_userJson!['First Name']}');
                },
            MediaQuery.of(context).size.width * 0.3,
            Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
            Colors.black
        )
      ),
    );
  }

}
