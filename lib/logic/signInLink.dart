import 'package:firebase_auth/firebase_auth.dart';

Future<bool> handleEmailLinkCredentials(Uri deepLink, String email) async {
  if (FirebaseAuth.instance.isSignInWithEmailLink(deepLink.toString())) {
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
          await user.linkWithCredential(emailCredential);
          print('Email successfully linked to phone number.');
          return true;
        } else {
          print('No current user to link email to.');
        }
      } catch (e) {
        print('Error linking email to phone number: $e');
      }
    }
  }
  return false;
}



