import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void handleDynamicLinkCredentials(String email) async {
  // Handle the initial dynamic link if the app is opened with a dynamic link
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialLink != null) {
    handleEmailLinkCredentials(initialLink.link, email);
  }

  // Handle the dynamic link while the app is in the foreground
  FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
    handleEmailLinkCredentials(data.link, email);
  }).onError((error) {
    print('Error occurred while handling dynamic link: $error');
  });
}

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



