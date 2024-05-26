import 'package:flutter/material.dart';
import 'package:overlapd/screens/onboardingScreens/verificationSent.dart';

import '../../logic/personalDetails.dart';
import '../../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../../utilities/customButton.dart';
import '../../utilities/customTextField.dart';
import '../../utilities/widgets.dart';

class AccountRecovery extends StatefulWidget {
  const AccountRecovery({super.key});

  @override
  State<AccountRecovery> createState() => _AccountRecoveryState();
}

class _AccountRecoveryState extends State<AccountRecovery> {
  TextEditingController emailAddress = TextEditingController();
  bool correctFormat = false, isEAEmpty = true, userExists = true;
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {

    super.initState();
    emailAddress.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    // Check if the email is valid
    setState(() {
      correctFormat = isValidEmail(emailAddress.text);
      isEAEmpty = emailAddress.text.isEmpty;
      userExists = true;
    });
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
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_outlined),
            ),
            const Text('Go back')
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 8.0, right: 8.0),
              child: Text(
                'Account Recovery',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextBox(
                  context,
                  'Email address',
                  'john.guiness@email.com',
                  Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: textColor(isEAEmpty),
                    fontWeight: FontWeight.normal,
                  ),
                  emailAddress,
                  TextInputType.emailAddress,
                  borderColor(isEAEmpty && !correctFormat)
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: isEAEmpty || correctFormat
                  ? const SizedBox.shrink()
                  : Padding(
                key: ValueKey<bool>(!isEAEmpty || correctFormat),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Incorrect email format',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.red),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: userExists
                  ? const SizedBox.shrink()
                  : Padding(
                key: ValueKey<bool>(!isEAEmpty || correctFormat),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Email address does not exist in database',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0, right: 8.0, left: 8.0, bottom: 8.0),
              child: Button(
                  context,
                  'Continue',
                      () async{
                    if(!isEAEmpty && correctFormat){
                      bool exists = await _auth.checkIfUserExists(emailAddress.text);
                      if(!exists){
                        setState(() {
                          userExists = false;
                        });
                      } else{
                        await _auth.sendSignInLinkToEmail(emailAddress.text);
                        Navigator.push(
                          context,
                          pageAnimationrl(VerificationSent(emailAddress: emailAddress.text)),
                        );
                      }
                    }
                  },
                  double.infinity,
                  Theme.of(context).textTheme.labelLarge!.copyWith(color: textButtonColor(!isEAEmpty && correctFormat), fontWeight: FontWeight.normal),
                  buttonColor(!isEAEmpty && correctFormat)),
            ),
          ],
        ),
      ),
    );
  }
}
