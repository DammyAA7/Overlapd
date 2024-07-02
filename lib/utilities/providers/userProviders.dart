import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/logic/personalDetails.dart';
import 'package:overlapd/services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../../models/userModel.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _userModel;
  bool? _isEmailVerified;
  final FirebaseAuthService _auth = FirebaseAuthService();

  UserModel? get userModel => _userModel;
  bool? get isEmailVerified => _isEmailVerified;

  void _setupFirestoreListener(String uid) {
    FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _updateLocalStorage(snapshot, uid);
      } else {
        print('Document does not exist');
      }
    });
  }

  void _updateLocalStorage(DocumentSnapshot doc, String uid) async {
    final userInfo = doc.data() as Map<String, dynamic>;
    await Hive.openBox<UserModel>('userBox');
    await Hive.box<UserModel>('userBox').delete(uid);
    await _auth.storeUserInfoInHive(uid, userInfo);
    _loadUserCredentials(uid);
  }

  Future<void> _loadUserCredentials(String uid) async {
    //final box = Hive.box<UserModel>('userBox');
    final userModel = await getUserCredentials(uid);
    _userModel = userModel;
    _isEmailVerified = userModel?.emailVerified;
    notifyListeners();
  }

  void initialize(String uid) {
    _setupFirestoreListener(uid);
  }
}
