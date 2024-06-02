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
  bool userExistsSignUp = true, userExistsLogIn = true;

  @override
  void initState() {
    super.initState();
    mobileNumber.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    // Check if the mobile number is valid
    setState(() {
      userExistsSignUp = true;
      userExistsLogIn = true;
    });
  }

  Widget getConditionalWidget() {
    switch (widget.type) {
      case 'Sign up':
        return termsAndConditions(context);
      case 'Log in':
        return cantAccessAccount(context);
      default:
        return shrinkedBox();
    }
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
              child: PhoneNumberField(context, mobileNumber, Colors.black),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: userExistsSignUp
                  ? const SizedBox.shrink()
                  : Padding(
                key: ValueKey<bool>(userExistsSignUp),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Account already exists!',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.red),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: userExistsLogIn
                  ? const SizedBox.shrink()
                  : Padding(
                key: ValueKey<bool>(userExistsLogIn),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Account does not exist!',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.red),
                ),
              ),
            ),
            getConditionalWidget(),
            Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 8.0, left: 8.0),
              child: Button(
                  context,
                  'Get OTP',
                      () async{
                    if(isPhoneNumberValid(mobileNumber.text) && widget.type == 'Sign up'){
                      bool phoneRegistered = await isPhoneNumberRegistered(mobileNumber.text);
                      if(phoneRegistered){
                        setState(() {
                          userExistsSignUp = false;
                        });
                      } else {
                        _auth.signInWithPhoneNumber(mobileNumber.text, context, widget.type);
                      }

                    } else if(isPhoneNumberValid(mobileNumber.text) && widget.type == 'Log in'){
                      bool phoneRegistered = await isPhoneNumberRegistered(mobileNumber.text);
                      if(!phoneRegistered){
                        setState(() {
                          userExistsLogIn = false;
                        });
                      } else {
                        _auth.signInWithPhoneNumber(mobileNumber.text, context, widget.type);
                      }
                    } else {
                      _auth.signInWithPhoneNumber(mobileNumber.text, context, widget.type);
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
