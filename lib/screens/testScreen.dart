
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/logic/signInLink.dart';
import 'package:overlapd/screens/onboardingScreens/onboarding.dart';
import 'package:overlapd/services/permissions/permissions.dart';
import 'package:overlapd/utilities/customButton.dart';
import '../logic/personalDetails.dart';
import '../models/userModel.dart';
import '../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _isEmailVerified = false;
  UserModel? _userModel;
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
    final userModel = await getUserCredentials(_auth.getUserId());
    if (mounted) {
      setState(() {
        _userModel = userModel;
      });
    }
  }

  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser; // Refresh the user instance
      if (user!.emailVerified) {
        if (mounted) {
          setState(() {
            _isEmailVerified = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: _isEmailVerified
                ? Text(
              'Email is verified',
              style: Theme.of(context).textTheme.headline6,
            )
                : Button(
                context,
                'attach',
                    () async{
                      await _auth.sendLinkToPhone('dammyade07@gmail.com');
                      if (_userModel != null) {
                        print('First Name: ${_userModel!.firstName}');
                        print('Last Name: ${_userModel!.lastName}');
                        print('Email: ${_userModel!.email}');
                        print('Phone Number: ${_userModel!.phoneNumber}');
                      } else {
                        print('No user data found');
                      }
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
                      RequestPermissionManager(PermissionType.whenInUseLocation)
                          .onPermissionDenied(() {
                        // Handle permission denied for location
                        print('Location permission denied');
                      })
                          .onPermissionGranted(() {
                        // Handle permission granted for location
                        print('Location permission granted');
                      })
                          .onPermissionPermanentlyDenied(() {
                        // Handle permission permanently denied for location
                        print('Location permission permanently denied');
                      })
                          .execute();
                },
                MediaQuery.of(context).size.width * 0.3,
                Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                Colors.black
            ),
          )
        ],
      ),
    );
  }
  Future<void> handleDynamicLinks(String email) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      Uri deepLink = dynamicLinkData.link;
      bool success = await handleEmailLinkCredentials(deepLink, email);
      if (success && mounted) {
        _checkEmailVerification(); // Call navigation function
      }
    }).onError((error) {
      // Handle errors (e.g., show a message to the user)
      print('Error handling dynamic link: $error');
    });

    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      bool success = await handleEmailLinkCredentials(initialLink.link, email);
      if (success && mounted) {
        _checkEmailVerification(); // Call navigation function
      }
    }
  }


}
