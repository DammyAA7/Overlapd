import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/screens/activity/activity.dart';
import 'package:overlapd/screens/cart/provider/cart_provider.dart';
import 'package:overlapd/screens/category/provider/shop_by_category_provider.dart';
import 'package:overlapd/screens/home.dart';
import 'package:overlapd/screens/home/home_screen.dart';
import 'package:overlapd/screens/home/provider/home_provider.dart';
import 'package:overlapd/screens/onboardingScreens/confirmMobileNumber.dart';
import 'package:overlapd/screens/onboardingScreens/onboarding.dart';
import 'package:overlapd/screens/onboardingScreens/splash.dart';
import 'package:overlapd/pickers/picker.dart';
import 'package:overlapd/screens/store/provider/store_provider.dart';
import 'package:overlapd/screens/testScreen.dart';
import 'package:overlapd/services/storeService/groceryRange.dart';
import 'package:overlapd/services/userAuthService/forgottenPassword.dart';
import 'package:overlapd/services/userAuthService/emailVerification.dart';
import 'package:overlapd/services/userAuthService/phoneVerification.dart';
import 'package:overlapd/services/userAuthService/phoneVerificationCode.dart';
import 'package:overlapd/utilities/providers/userProviders.dart';
import 'package:overlapd/utilities/widgets.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:overlapd/screens/about.dart';
import 'package:overlapd/screens/history.dart';
import 'package:overlapd/screens/payment.dart';
import 'package:overlapd/screens/support.dart';
import 'package:overlapd/services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import 'models/userModel.dart';
import 'services/userAuthService/login.dart';
import 'services/userAuthService/signup.dart';
// import 'screens/home.dart';
import 'screens/settings.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<String>('deepLinkBox');  // Open a box to store the deep link URI
  Stripe.publishableKey = "pk_test_51OWmrwIaruu0MDtu9f0fOLYUdaDsxU6FHsV2TtXLw6CstWMCKPwZhhldZEWSmsStYYTYpfeRfzGVAZ9tfLKODOYt00gDUZP4EI";
  Stripe.instance.applySettings();

  // Check for the initial dynamic link if the app was started from a terminated state
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(MyApp(initialLink: initialLink));
}

class MyApp extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;

  MyApp({super.key, this.initialLink});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool isLoggedInAsUser = false;
  bool isLoggedInAsEmployee = false;
  Uri? deepLinkUri;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    _initialize();
    // Listen for dynamic links while the app is running or in the background
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData? dynamicLinkData) async {
      if (dynamicLinkData?.link != null) {
        Uri deepLink = dynamicLinkData!.link;
        _handleDynamicLink(deepLink);
      }
    }).onError((error) {
      print('Error handling dynamic link: $error');
    });
  }

  Future<void> _initialize() async {
    isLoggedInAsUser = await _auth.isLoggedInAsUser();
    isLoggedInAsEmployee = await _auth.isLoggedInAsEmployee();

    // Retrieve user data from Hive
    final userBox = Hive.box<UserModel>('userBox');
    userModel = userBox.get(_auth.getUserId());

    // Handle the initial link if it exists
    if (widget.initialLink != null) {
      deepLinkUri = widget.initialLink!.link;
      if (deepLinkUri.toString().contains('https://overlapd.page.link/7Yoh')){
        await Hive.box<String>('deepLinkBox').put('deepLinkUri', deepLinkUri.toString());
      }
      _handleDynamicLink(deepLinkUri!);
    }
  }

  void _handleDynamicLink(Uri deepLink) async {
    if (userModel == null) {
      print('No user data found');
      return;
    }

    final email = userModel!.email;
    if (deepLink.toString().contains('https://overlapd.page.link/bAmq')) {
      // Handle sign-in link
      bool success = await handleEmailLinkCredentials(deepLink, email);
      if (success) {
        _auth.currentUser?.reload();
        await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.uid).update({
          'Email Verified': _auth.currentUser?.emailVerified,
        });
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => const TestScreen()),
        );
      } else {
        // Handle sign-in failure
      }
    } else if (deepLink.toString().contains('https://overlapd.page.link/7Yoh')) {
      // Handle phone verification link
      bool success = await handleEmailLinkSignIn(deepLink, email);
      if (success) {
        navigatorKey.currentState?.pushReplacement(
          pageAnimationrl(const ConfirmMobileNumber()),
        );
      } else {
        // Handle sign-in failure
      }
    } else {
      // Handle other types of deep links
    }
  }

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
          ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => ShopByCategoryProvider()),
        ChangeNotifierProvider(create: (context) => StoreScreenProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            userProvider.initialize(user.uid);
          }
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Overlap',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
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
            home: SplashScreenWrapper(),//const Activity(),
            routes: {
              '/login_page': (context) => const Login(),
              '/signup_page': (context) => const SignUp(),
              '/home_page': (context) => const Home(),
              '/settings_page': (context) => const Setting(),
              '/history_page': (context) => const History(),
              '/about_page': (context) => const About(),
              '/support_page': (context) => const Support(),
              '/payment_page': (context) => const Payment(),
              '/picker_page': (context) => const Picker(),
              '/forgotten_password_page': (context) => const ForgotPassword(),
              '/email_verification_page': (context) => const EmailVerification(),
              '/phone_verification_page': (context) => const PhoneVerification(),
              '/phone_verification_code_page': (context) => const VerificationCode(verificationId: '', verificationType: ''),
            },
          );
        },
      ),
    );
  }
}

Future<bool> handleEmailLinkCredentials(Uri deepLink, String email) async {
  if (FirebaseAuth.instance.isSignInWithEmailLink(deepLink.toString())) {
    print('deeplink: ${deepLink.toString()}');
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
          await FirebaseAuth.instance.currentUser?.linkWithCredential(emailCredential);
          // Update Firestore document
          user.reload();
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'Email Verified': user.emailVerified,
          });
          print('Email successfully linked to phone number.');
          print(user.emailVerified);
          return true;
        }
      } catch (e) {
        print('Error linking email to phone number: $e');
      }
    }
  }
  return false;
}

Future<bool> handleEmailLinkSignIn(Uri deepLink, String email) async {
  if (FirebaseAuth.instance.isSignInWithEmailLink(deepLink.toString())) {
    if (email.isNotEmpty) {
      try {
        // Sign in the user with the email link
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailLink(
          email: email,
          emailLink: deepLink.toString(),
        );

        User? user = userCredential.user;
        if (user != null) {
          print('User successfully signed in.');
          return true; // Indicate success
        }
      } catch (e) {
        print('Error signing in with email link: $e');
      }
    }
  }
  return false; // Indicate failure
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate a delay for the splash screen
    bool isLoggedInAsUser = await _auth.isLoggedInAsUser();
    bool isLoggedInAsEmployee = await _auth.isLoggedInAsEmployee();
    String? storedUri = Hive.box<String>('deepLinkBox').get('deepLinkUri');
    Uri? deepLinkUri;
    if (storedUri != null) {
      deepLinkUri = Uri.parse(storedUri);
    }
    if (deepLinkUri != null) {
      // Do not navigate again if deep link was handled
      await Hive.box<String>('deepLinkBox').delete('deepLinkUri');
      return;
    } else if (isLoggedInAsUser) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (isLoggedInAsEmployee) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const Picker()),
      );
    } else {
      FirebaseAuth.instance.signOut();
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const Onboarding()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Splash(); // Display the splash screen while initialization is in progress
  }
}