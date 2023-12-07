import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'user_auth/login.dart';
import 'user_auth/signup.dart';
import 'screens/home.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const Login(),
        routes: {
          '/login_page': (context) => const Login(),
          '/signup_page': (context) => const SignUp(),
          '/home_page': (context) => const Home()
        },
    );
  }
}

