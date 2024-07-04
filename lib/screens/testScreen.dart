
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/logic/signInLink.dart';
import 'package:overlapd/screens/onboardingScreens/onboarding.dart';
import 'package:overlapd/screens/profile/profile.dart';
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
  bool? _isEmailVerified;
  UserModel? _userModel;
  late final String _UID = _auth.getUserId();
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserCredentials();
    _setupFirestoreListener();
  }

  void _setupFirestoreListener() {
    FirebaseFirestore.instance.collection('users').doc(_UID).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _updateLocalStorage(snapshot);
      } else {
        print('Document does not exist');
      }
    });
  }

  void _updateLocalStorage(DocumentSnapshot doc) async {
      final userInfo = doc.data() as Map<String, dynamic>;
        await Hive.box<UserModel>('userBox').delete(_UID);
        await _auth.storeUserInfoInHive(_UID, userInfo);
        _loadUserCredentials();
  }

  Future<void> _loadUserCredentials() async {
    final userModel = await getUserCredentials(_auth.getUserId());
    if (mounted) {
      setState(() {
        _userModel = userModel;
        _isEmailVerified = userModel?.emailVerified;
      });
    }
    handleDynamicLinks(_userModel!.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: _isEmailVerified ?? false
                ? Text(
              'Email is verified',
              style: Theme.of(context).textTheme.headline6,
            )
                : Button(
                context,
                'attach',
                    () async{
                      await _auth.sendLinkToPhone(_userModel!.email);
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
                      if (_userModel != null) {
                        print('First Name: ${_userModel!.firstName}');
                        print('Last Name: ${_userModel!.lastName}');
                        print('Email: ${_userModel!.email}');
                        print('Phone Number: ${_userModel!.phoneNumber}');
                        print('Email Verified ${_userModel!.emailVerified}');
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
