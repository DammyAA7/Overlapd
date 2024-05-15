import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:overlapd/utilities/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

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
  Future<void> setLoggedInAsUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedInAsUser', true);
  }

  // Set the login status to true when the employee logs in
  Future<void> setLoggedInAsEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedInAsEmployee', true);
  }


  // Check if the user is logged in
  Future<bool> isLoggedInAsUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedInAsUser') ?? false;
  }

  // Check if the employee is logged in
  Future<bool> isLoggedInAsEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedInAsEmployee') ?? false;
  }

  // Clear the login status when the user logs out
  Future<void> setLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedInAsEmployee', false);
    await prefs.setBool('isLoggedInAsUser', false);
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

  Stream<DocumentSnapshot> getAccountInfo(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(
        uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getAccountInfoGet(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(
        uid).get();
  }


}