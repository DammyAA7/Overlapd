import 'package:flutter/material.dart';
import 'package:overlapd/screens/onboardingScreens/onboarding.dart';
import 'package:overlapd/utilities/customButton.dart';
import 'package:overlapd/utilities/customNumberField.dart';

import '../../logic/enterPhoneNumber.dart';
import '../../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../widgets.dart';

class EnterPhoneNumber extends StatefulWidget {
  final String type;
  const EnterPhoneNumber({super.key, required this.type});

  @override
  State<EnterPhoneNumber> createState() => _EnterPhoneNumberState();
}

class _EnterPhoneNumberState extends State<EnterPhoneNumber> {
  TextEditingController mobileNumber = TextEditingController();
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    mobileNumber.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    // Check if the mobile number is valid
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.20,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(pageAnimationlr(
                    const Onboarding()
                ));
              },
              icon: const Icon(Icons.arrow_back_outlined),
            ),
            const Text('Go back')
          ],
        ),
      ),
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 8.0, right: 8.0),
              child: Text(
                  'Enter your mobile number',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
              child: Text(
                'Mobile number',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey, fontWeight: FontWeight.w300),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
              child: PhoneNumberField(context, mobileNumber),
            ),
        widget.type == 'Sign up' ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontSize: 15
              ),
              children: [
                const TextSpan(
                  text: 'By proceeding, I accept the',
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      ' terms of service',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 15
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 15
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'privacy policy',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 15
                        ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) : Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: Text(
              'Don\'t have access to your phone number?',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 15
              ),
            ),
          ),
        ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 8.0, left: 8.0),
              child: Button(
                  context,
                  'Get OTP',
                      () {
                    if(isPhoneNumberValid(mobileNumber.text)){
                      _auth.signInWithPhoneNumber(mobileNumber.text, context);
                    }
                      },
                  double.infinity,
                  Theme.of(context).textTheme.labelLarge!.copyWith(color: textButtonColor(isPhoneNumberValid(mobileNumber.text)), fontWeight: FontWeight.normal),
                  buttonColor(isPhoneNumberValid(mobileNumber.text))),
            )
          ],
        ),
      )
    );
  }
}
