import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:overlapd/screens/about.dart';
import 'package:overlapd/screens/history.dart';
import 'package:overlapd/screens/payment.dart';
import 'package:overlapd/screens/support.dart';
import 'package:overlapd/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_auth/login.dart';
import 'user_auth/signup.dart';
import 'screens/home.dart';
import 'screens/settings.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool isLoggedIn = await _auth.isLoggedIn();
  await Hive.initFlutter();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> isUserLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF21D19F)),
        fontFamily: 'Darker Grotesque',
        textTheme: const TextTheme(
          labelLarge: TextStyle(fontSize: 18),
          displayMedium: TextStyle(fontSize: 35.0),
          bodyLarge: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w200,
              color: Color(0xFF072C22)),
          bodyMedium: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w300,
              color: Color(0xFF072C22)),
        ),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const Home() : const Login(),
        routes: {
          '/login_page': (context) => const Login(),
          '/signup_page': (context) => const SignUp(),
          '/home_page': (context) => const Home(),
          '/settings_page' : (context) => const Setting(),
          '/history_page' : (context) => const History(),
          '/about_page' : (context) => const About(),
          '/support_page' : (context) => const Support(),
          '/payment_page' : (context) => const Payment(),

        },
    );
  }
}

