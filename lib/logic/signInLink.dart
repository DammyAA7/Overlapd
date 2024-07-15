import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void handleDynamicLinks(String email) async {
  // Handle the initial dynamic link if the app is opened with a dynamic link
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialLink != null) {
    handleEmailLinkSignIn(initialLink.link, email);
  }

  // Handle the dynamic link while the app is in the foreground
  FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
    handleEmailLinkSignIn(data.link, email);
  }).onError((error) {
    print('Error occurred while handling dynamic link: $error');
  });
}

void handleDynamicLinkSignIn(String email) async {
  // Handle the initial dynamic link if the app is opened with a dynamic link
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialLink != null) {
    handleEmailLinkSignIn(initialLink.link, email);
  }

  // Handle the dynamic link while the app is in the foreground
  FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
    handleEmailLinkSignIn(data.link, email);
  }).onError((error) {
    print('Error occurred while handling dynamic link: $error');
  });
}

Future<bool> handleEmailLink(Uri deepLink, String email) async {
  if (FirebaseAuth.instance.isSignInWithEmailLink(deepLink.toString())) {
    if (email.isNotEmpty) {
      try {
        // Get email credential
        final AuthCredential emailCredential =
            EmailAuthProvider.credentialWithLink(
          email: email,
          emailLink: deepLink.toString(),
        );

        // Link email credential to the current user
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseAuth.instance.currentUser
              ?.linkWithCredential(emailCredential);
          print('Email successfully linked to phone number.');
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
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailLink(
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
