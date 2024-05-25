
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _handleDynamicLinks();
  }
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

  void _handleDynamicLinks() async {
    // Handle the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      _handleEmailLinkSignIn(initialLink.link);
    }

    // Handle the dynamic link while the app is in the foreground
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
      _handleEmailLinkSignIn(data.link);
    }).onError((error) {
      print('Error occurred while handling dynamic link: $error');
    });
  }

  Future<void> _handleEmailLinkSignIn(Uri deepLink) async {
    if (FirebaseAuth.instance.isSignInWithEmailLink(deepLink.toString())) {
      const String email = 'dammyade07@gmail.com'; // Replace with the user's email

      if (email.isNotEmpty) {
        try {
          // Get email credential
          final AuthCredential emailCredential = EmailAuthProvider.credentialWithLink(
            email: email,
            emailLink: deepLink.toString(),
          );

          // Link email credential to the current user
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseAuth.instance.currentUser
                ?.linkWithCredential(emailCredential);
            print('Email successfully linked to phone number.');
          }
        } catch (e) {
          print('Error linking email to phone number: $e');
        }
      }
    }
  }

}
