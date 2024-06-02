import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/screens/onboardingScreens/onboarding.dart';

import '../../logic/splash.dart';
import '../../models/userModel.dart';
import '../../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../testScreen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    checkLoginStatus();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values
    );
    super.dispose();
  }

  void checkLoginStatus() async {
    // Check if user is logged in as user
    final isUserLoggedIn = await isUserLoggedInAsUser();
    print(isUserLoggedIn);
    if (isUserLoggedIn) {
      // User is logged in as user, navigate to TestScreen
      final FirebaseAuthService _auth = FirebaseAuthService();
      User? user = _auth.currentUser;
      final userInfo = await _auth.getUserInfo(user!.uid);
      if (userInfo != null) {
        await Hive.box<UserModel>('userBox').delete(user.uid);
        await _auth.storeUserInfoInHive(user.uid, userInfo);
      }
          Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const TestScreen(),
      ));
    } else {
      // User is not logged in as user, navigate to Onboarding
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const Onboarding(),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
            'Overlap',
            style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
