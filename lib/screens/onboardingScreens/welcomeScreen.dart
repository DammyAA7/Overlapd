import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/screens/home/home_screen.dart';
import 'package:overlapd/screens/onboardingScreens/personalDetails.dart';
import 'package:overlapd/screens/testScreen.dart';
import 'package:overlapd/services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../../models/userModel.dart';
import '../../services/permissions/permissions.dart';

class WelcomeScreen extends StatefulWidget {
  final String type;
  const WelcomeScreen({super.key, required this.type});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  @override
  void initState() {
    super.initState();
    if (widget.type == 'Log in') {
      handleLogin();
    } else if (widget.type == 'Sign up') {
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

      RequestPermissionManager(PermissionType.notification)
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
      handleSignup();
    }
  }

  Future<void> handleSignup() async {
    // Delay navigation to personal details screen by 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const PersonalDetails(), // Navigate to your personal details screen
        ),
      );
    });
  }

  Future<void> handleLogin() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userInfo = await _auth.getUserInfo(user.uid);
      if (userInfo != null) {
        await Hive.box<UserModel>('userBox').delete(user.uid);
        await _auth.storeUserInfoInHive(user.uid, userInfo);
      }
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(), // Navigate to your personal details screen
          ),
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome to Overlap!',
          style: Theme.of(context)
              .textTheme
              .displayLarge!
              .copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
