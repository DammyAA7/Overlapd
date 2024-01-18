import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:overlapd/utilities/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Set the login status to true when the user logs in
  Future<void> setLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Clear the login status when the user logs out
  Future<void> setLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  String getUserId()  {
    User? user = _auth.currentUser;
    return (user?.uid)!;
  }

  String getUsername() {
    User? user = _auth.currentUser;
    return (user?.email)!;
  }


  Stream<DocumentSnapshot<Map<String, dynamic>>> getPersonalDetails(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Stream<DocumentSnapshot> getIdentityStatus(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(
        uid).snapshots();
  }


}