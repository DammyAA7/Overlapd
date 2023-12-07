import 'package:firebase_auth/firebase_auth.dart';
import 'package:overlapd/utilities/toast.dart';

class FirebaseAuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch(e) {
      if(e.code == 'email-already-in-use'){
        showToast(text: 'The email address is already in use');
      } else {
        showToast(text: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch(e) {
      print(e.code);
      if(e.code == 'user-not-found' || e.code == 'wrong-password'){
        showToast(text: 'Invalid email or password');
      } else {
        showToast(text: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }

}