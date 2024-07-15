import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../../logic/personalDetails.dart';
import '../../models/userModel.dart';
import '../../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../../utilities/customButton.dart';
import '../../utilities/customNumberField.dart';
import '../../utilities/customTextField.dart';
import '../../utilities/widgets.dart';
import '../onboardingScreens/onboarding.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  UserModel? _userModel;
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  bool incorrectFormat = true, isLNEmpty = true, isFNEmpty = true, isEAEmpty = true, isMNEmpty = true;
  TextEditingController emailAddress = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  bool? _isEmailVerified;

  @override
  void initState() {
    super.initState();
    emailAddress.addListener(_onEmailChanged);
    firstName.addListener(_onChanged);
    lastName.addListener(_onChanged);
    mobileNumber.addListener(_onChanged);
    _openHiveBox();
  }

  Future<void> _openHiveBox() async {
    await Hive.initFlutter(); // Initialize Hive
    await Hive.openBox<UserModel>('userBox');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final box = Hive.box<UserModel>('userBox');
    // Replace 'yourUserId' with the actual ID or key you use to store user data
    _userModel = box.get(_UID);
    if (_userModel != null) {
      firstName.text = _userModel!.firstName;
      lastName.text = _userModel!.lastName;
      emailAddress.text = _userModel!.email;
      mobileNumber.text = _userModel!.phoneNumber.replaceAll('+353', '');
    }
    setState(() {
      _isEmailVerified = _userModel!.emailVerified;
    });
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  void _onEmailChanged() {
    // Check if the email is valid
    setState(() {
      incorrectFormat = isValidEmail(emailAddress.text);
      isEAEmpty = emailAddress.text.isEmpty;
    });
  }

  void _onChanged() {
    // Check if the name fields are empty
    setState(() {
      isLNEmpty = lastName.text.isEmpty;
      isFNEmpty = firstName.text.isEmpty;
      isMNEmpty = mobileNumber.text.isEmpty;
    });
  }

  Future<void> _updateUserModel() async {
    final box = Hive.box<UserModel>('userBox');
    _userModel = UserModel(
        firstName: firstName.text,
        lastName: lastName.text,
        email: emailAddress.text,
        phoneNumber: '+353${mobileNumber.text.replaceAll(' ', '')}',
        emailVerified: _auth.currentUser!.emailVerified
    );
    await box.put(_UID, _userModel!);
    // Firestore update
    await FirebaseFirestore.instance.collection('users').doc(_UID).set({
      'First Name': firstName.text,
      'Last Name': lastName.text,
      'Email Address': emailAddress.text,
      'Phone Number': '+353${mobileNumber.text.replaceAll(' ', '')}',
      'Email Verified': _auth.currentUser!.emailVerified,
    }, SetOptions(merge: true)); // Use merge to avoid overwriting existing fields

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_outlined),
            ),
            const Text('Go back')
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 8.0),
              child: Text(
                'Profile details',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(),
              ),
            ),
            Expanded(child: _buildListView())
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final titles = ['Account name', 'Email Address', 'Phone number'];
    final details = _userModel != null
        ? ['${_userModel!.firstName} ${_userModel!.lastName}', _userModel!.email, _userModel!.phoneNumber]
        : ['N/A', 'N/A', 'N/A'];
    final widgets = [accountNameWidget(), emailAddressWidget(), phoneNumberWidget()];
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isEmailVerified ?? true
                ? const SizedBox.shrink()
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                      children: [
                        Expanded(
                          child: Text(
                            'Verify your email address to complete your profile',
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Button(
                            context,
                            'Verify email',
                                () async {
                              await _auth.sendLinkToPhone(_userModel!.email);
                            },
                            null,
                            Theme.of(context).textTheme.labelMedium!.copyWith(
                              color: textButtonColor(true),
                              fontWeight: FontWeight.w500,
                            ),
                            buttonColor(true))
                      ],
                    ),
                  )
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Change this to the number of items you want in the list
              itemBuilder: (context, index) {
                return _buildListItem(context, titles[index], details[index], widgets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, String detail, Widget widget) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.mode_edit_outlined),
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom * 0.8, left: 8.0, top: 8.0, right: 8.0),
                            child: SizedBox(
                                height: 400,
                                child: widget
                            ),
                          );
                        }).then((_) {
                      _loadUserData();
                    });
                  },
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Divider(),
          )
        ],
      ),
    );
  }

  Widget accountNameWidget() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextBox(
                  context,
                  'First Name',
                  firstName.text,
                  Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: textColor(isFNEmpty),
                    fontWeight: FontWeight.normal,
                  ),
                  firstName,
                  TextInputType.text,
                  borderColor(isFNEmpty),
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z'-]")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextBox(
                  context,
                  'Last Name',
                  lastName.text,
                  Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: textColor(isLNEmpty),
                    fontWeight: FontWeight.normal,
                  ),
                  lastName,
                  TextInputType.text,
                  borderColor(isLNEmpty),
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z'-]")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, right: 8.0, left: 8.0, bottom: 8.0),
                child: Button(
                    context,
                    'Update account name',
                        () async {
                      if (!isFNEmpty && !isLNEmpty && (_userModel!.firstName != firstName.text || _userModel!.lastName != lastName.text)) {
                        await _updateUserModel();
                        Navigator.of(context).pop();
                      }
                    },
                    double.infinity,
                    Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: textButtonColor(!isFNEmpty && !isLNEmpty),
                        fontWeight: FontWeight.normal),
                    buttonColor(!isFNEmpty && !isLNEmpty)),
              ),
            ],
          );
        });
  }

  Widget emailAddressWidget() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextBox(
                    context,
                    'Email address',
                    emailAddress.text,
                    Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: textColor(isEAEmpty),
                      fontWeight: FontWeight.normal,
                    ),
                    emailAddress,
                    TextInputType.emailAddress,
                    borderColor(isEAEmpty)),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: incorrectFormat
                    ? const SizedBox.shrink()
                    : Padding(
                  key: ValueKey<bool>(incorrectFormat),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Incorrect email format',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.red),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, right: 8.0, left: 8.0, bottom: 8.0),
                child: Button(
                    context,
                    'Update email address',
                        () async {
                      setState(() {
                        incorrectFormat = isValidEmail(emailAddress.text);
                        isEAEmpty = emailAddress.text.isEmpty;
                      });try{
                        await _auth.currentUser?.reload();
                      } catch (e){
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              title: const Text('Session Expired'),
                              content: const Text('Your session has expired. Please sign in again.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    FirebaseAuth.instance.signOut();
                                    _auth.setLoggedOut();
                                    Navigator.of(context).pushReplacement(pageAnimationlr(const Onboarding()));
                                  },
                                  child: const Text('Sign In'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      await _auth.currentUser?.getIdToken(true); // Force refresh the token
                      User? updatedUser = FirebaseAuth.instance.currentUser;
                      print(updatedUser?.emailVerified);
                      if (!isEAEmpty && incorrectFormat && _userModel!.email != emailAddress.text) {
                        if(_userModel?.emailVerified ?? false){
                          await _auth.currentUser?.verifyBeforeUpdateEmail(emailAddress.text);
                          await _auth.currentUser?.reload();
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: const Text('Your are being logged out and will need to log back in',
                                  textAlign: TextAlign.center,
                                ),
                                actions: <Widget>[
                                  Center(
                                    child: Button(
                                        context,
                                        'Okay',
                                            (){
                                              FirebaseAuth.instance.signOut();
                                              _auth.setLoggedOut();
                                              Navigator.of(context).pushReplacement(pageAnimationlr(const Onboarding()));
                                            },
                                        MediaQuery.of(context).size.width * 0.7,
                                        Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                                        Colors.black
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          //await _updateUserModel();
                        }
                      }
                    },
                    double.infinity,
                    Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: textButtonColor(true),
                        fontWeight: FontWeight.normal),
                    buttonColor(true)),
              ),
            ],
          );
        });
  }

  Widget phoneNumberWidget() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
                child: Text(
                  'Phone Number',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: textColor(false),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
                child: PhoneNumberField(context, mobileNumber, borderColor(false)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, right: 8.0, left: 8.0, bottom: 8.0),
                child: Button(
                    context,
                    'Update phone number',
                        () async {
                      if (!isMNEmpty && _userModel!.phoneNumber != mobileNumber.text) {
                        await _updateUserModel();
                        Navigator.of(context).pop();
                      }
                    },
                    double.infinity,
                    Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: textButtonColor(true),
                      fontWeight: FontWeight.normal,
                    ),
                    buttonColor(true)),
              ),
            ],
          );
        });
  }
}