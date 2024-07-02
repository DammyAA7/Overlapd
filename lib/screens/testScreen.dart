
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/logic/signInLink.dart';
import 'package:overlapd/screens/onboardingScreens/onboarding.dart';
import 'package:overlapd/screens/profile/profile.dart';
import 'package:overlapd/utilities/customButton.dart';
import 'package:overlapd/utilities/providers/userProviders.dart';
import 'package:provider/provider.dart';
import '../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handleDynamicLinks('dammyade07@gmail.com');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userModel = userProvider.userModel;
        final isEmailVerified = userProvider.isEmailVerified ?? false;
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: isEmailVerified ?? false
                      ? Text(
                    'Email is verified',
                    style: Theme.of(context).textTheme.headline6,
                  )
                      : Button(
                      context,
                      'attach',
                          () async{
                        await _auth.sendLinkToPhone('dammyade07@gmail.com');
                      },
                      MediaQuery.of(context).size.width * 0.3,
                      Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                      Colors.black
                  )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                    context,
                    'Sign out',
                        () async{
                      FirebaseAuth.instance.signOut();
                      _auth.setLoggedOut();
                      Navigator.of(context).pushReplacement(pageAnimationlr(const Onboarding()));
                    },
                    MediaQuery.of(context).size.width * 0.3,
                    Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                    Colors.black
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                    context,
                    'Request',
                        () async{
                      if (userModel != null) {
                        print('First Name: ${userModel.firstName}');
                        print('Last Name: ${userModel.lastName}');
                        print('Email: ${userModel.email}');
                        print('Phone Number: ${userModel.phoneNumber}');
                        print('Email Verified ${userModel.emailVerified}');
                      } else {
                        print('No user data found');
                      }
                      Navigator.of(context).push(pageAnimationrl(const Profile()));
                    },
                    MediaQuery.of(context).size.width * 0.3,
                    Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                    Colors.black
                ),
              )
            ],
          ),
        );
      },
    );
  }
  Future<void> handleDynamicLinks(String email) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      Uri deepLink = dynamicLinkData.link;
      bool success = await handleEmailLinkCredentials(deepLink, email);
      if (success && mounted) {
         // Call navigation function
      }
    }).onError((error) {
      // Handle errors (e.g., show a message to the user)
      print('Error handling dynamic link: $error');
    });

    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      bool success = await handleEmailLinkCredentials(initialLink.link, email);
      if (success && mounted) {
         // Call navigation function
      }
    }
  }


}
