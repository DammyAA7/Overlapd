import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/onboardingScreens/onboarding.dart';
import 'package:overlapd/utilities/authUtilities/enterPhoneNumber.dart';
import 'package:overlapd/utilities/widgets.dart';

import '../../logic/personalDetails.dart';
import '../../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../../utilities/customButton.dart';
import '../../utilities/customNumberField.dart';

class ConfirmMobileNumber extends StatefulWidget {
  const ConfirmMobileNumber({super.key});

  @override
  State<ConfirmMobileNumber> createState() => _ConfirmMobileNumberState();
}

class _ConfirmMobileNumberState extends State<ConfirmMobileNumber> {
  bool isMNEmpty = true, wrongNumber = false;
  TextEditingController mobileNumber = TextEditingController();
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    mobileNumber.addListener(_onPhoneChanged);
  }

  Future<void> handleUnlinkPhoneNumber() async {
    String? userMobileNumber = await _auth.getUserMobileNumber();
    if (userMobileNumber == '+353${mobileNumber.text.replaceAll(' ', '')}') {
      if (_auth.currentUser?.phoneNumber != null) {
        await _auth.unlinkPhoneNumber();
        print('Phone number unlinked successfully');
      }
      Navigator.pushReplacement(context,
          pageAnimationlr(const EnterPhoneNumber(type: 'Account Recovery')));
      // Navigate to another screen or show success message
    } else {
      setState(() {
        wrongNumber = true;
      });
    }
  }

  void _onPhoneChanged() {
    // Check if the mobile number is valid
    setState(() {
      wrongNumber = false;
      if (mobileNumber.text.length == 11) {
        isMNEmpty = false;
      } else {
        isMNEmpty = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.10,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context, pageAnimationlr(const Onboarding()));
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
              child: Text('Enter mobile number associated with account',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith()),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
              child: PhoneNumberField(
                  context, mobileNumber, borderColor(isMNEmpty)),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: !wrongNumber
                  ? const SizedBox.shrink()
                  : Padding(
                      key: ValueKey<bool>(!wrongNumber),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Wrong Number',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: Colors.red),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 30.0, right: 8.0, left: 8.0, bottom: 8.0),
              child: Button(context, 'Continue', () async {
                if (!isMNEmpty) {
                  String? userMobileNumber = await _auth.getUserMobileNumber();
                  if (userMobileNumber ==
                      '+353${mobileNumber.text.replaceAll(' ', '')}') {
                    await handleUnlinkPhoneNumber();
                  } else {
                    setState(() {
                      wrongNumber = true;
                    });
                  }
                }
              },
                  double.infinity,
                  Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: textButtonColor(!isMNEmpty),
                      fontWeight: FontWeight.normal),
                  buttonColor(!isMNEmpty)),
            ),
          ],
        ),
      ),
    );
  }
}
