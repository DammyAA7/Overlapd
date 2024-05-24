
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/utilities/customButton.dart';
import '../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuthService _auth = FirebaseAuthService();
    return Scaffold(
      body: Center(
        child: Button(
            context,
            'attach',
                () async{
                  await _auth.sendSignInLinkToEmail('dammyade07@gmail.com');
                },
            MediaQuery.of(context).size.width * 0.3,
            Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
            Colors.black
        )
      ),
    );
  }

}
