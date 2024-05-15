
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/pickers/picker.dart';
import 'package:overlapd/stores/groceryRange.dart';
import 'package:overlapd/user_auth/forgottenPassword.dart';
import 'package:overlapd/user_auth/verification.dart';
import 'package:provider/provider.dart';
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
  bool isLoggedInAsUser = await _auth.isLoggedInAsUser();
  bool isLoggedInAsEmployee = await _auth.isLoggedInAsEmployee();
  await Hive.initFlutter();
  Stripe.publishableKey = "pk_test_51OWmrwIaruu0MDtu9f0fOLYUdaDsxU6FHsV2TtXLw6CstWMCKPwZhhldZEWSmsStYYTYpfeRfzGVAZ9tfLKODOYt00gDUZP4EI";
  Stripe.instance.applySettings();
  runApp(ChangeNotifierProvider(
      create: (context) => Cart(),
      child: MyApp(isLoggedInAsUser: isLoggedInAsUser, isLoggedInAsEmployee: isLoggedInAsEmployee)
  ));
}

Future<bool> isUserLoggedInAsUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedInInAsUser') ?? false;
}

Future<bool> isUserLoggedInAsEmployee() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedInInAsEmployee') ?? false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedInAsUser;
  final bool isLoggedInAsEmployee;
  final FirebaseAuthService _auth = FirebaseAuthService();
  MyApp({super.key, required this.isLoggedInAsUser, required this.isLoggedInAsEmployee});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget _getHomeWidget() {
      if (isLoggedInAsUser) {
        if(_auth.currentUser?.emailVerified == true){
          return const Home();
        } else {
          return const Verification();
        }

      } else if (isLoggedInAsEmployee) {
        return const Picker();
      } else {
        return const Login();
      }
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF21D19F)),
        fontFamily: 'Cabin',
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
      home: _getHomeWidget(),
        routes: {
          '/login_page': (context) => const Login(),
          '/signup_page': (context) => const SignUp(),
          '/home_page': (context) => const Home(),
          '/settings_page' : (context) => const Setting(),
          '/history_page' : (context) => const History(),
          '/about_page' : (context) => const About(),
          '/support_page' : (context) => const Support(),
          '/payment_page' : (context) => const Payment(),
          '/picker_page' : (context) => const Picker(),
          '/forgotten_password_page' : (context) => const ForgotPassword(),
          '/verification_page' : (context) => const Verification()
        },
    );
  }
}

