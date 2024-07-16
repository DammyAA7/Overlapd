import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/utilities/toast.dart';

import '../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';
import 'home/home.dart';

class Setting extends StatefulWidget {
  static const id = 'settings_page';
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool isModified = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  String? email;
  String? dob;
  DocumentSnapshot? userDetails;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userDocument();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void checkForModifications() {
    setState(() {
      isModified = firstNameController.text != userDetails?['Street Address'] ||
          lastNameController.text != userDetails?['Locality'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    // Navigate to the home page with a fade transition
                    Navigator.pushReplacement(
                      context,
                      pageAnimationlr(const Home()),
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ],
            )),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            const Text('Email'),
            Text(email!),
            addressInputBox('First Name', true, false, firstNameController.text,
                TextInputType.text, (newValue) {
              firstNameController.text = newValue;
              checkForModifications();
            }),
            addressInputBox('Last Name', true, false, lastNameController.text,
                TextInputType.text, (newValue) {
              lastNameController.text = newValue;
              checkForModifications();
            }),
          ]),
        ));
  }

  void userDocument() async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(_UID).get();
      if (userSnapshot.exists) {
        // If user document exists, update the firstName state
        setState(() {
          userDetails = userSnapshot;
          firstNameController =
              TextEditingController(text: userSnapshot['First Name']);
          lastNameController =
              TextEditingController(text: userSnapshot['Last Name']);
          email = userSnapshot['Email Address'];
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      showToast(text: 'Error loading data');
    }
  }
}
