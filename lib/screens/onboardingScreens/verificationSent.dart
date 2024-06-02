import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/logic/signInLink.dart';
import 'package:overlapd/screens/onboardingScreens/confirmMobileNumber.dart';

import '../../utilities/widgets.dart';

class VerificationSent extends StatefulWidget {
  final String emailAddress;
  const VerificationSent({super.key, required this.emailAddress});

  @override
  State<VerificationSent> createState() => _VerificationSentState();
}

class _VerificationSentState extends State<VerificationSent> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handleDynamicLinks(widget.emailAddress);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.20,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_outlined),
            ),
            const Text('Go back')
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'A link has been sent to your email address',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Click the link and you\'ll be redirected back to the app to continue your account recovery',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleDynamicLinks(String email) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      Uri deepLink = dynamicLinkData.link;
      bool success = true;//await handleEmailLinkSignIn(deepLink, email);
      if (success) {
        Navigator.push(
          context,
          pageAnimationrl(const ConfirmMobileNumber()),
        ); // Call navigation function
      } else {
        // Handle failure (e.g., show a message to the user)
      }
    }).onError((error) {
      // Handle errors (e.g., show a message to the user)
      print('Error handling dynamic link: $error');
    });
  }
}
