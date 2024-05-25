import 'package:flutter/material.dart';

import '../../logic/personalDetails.dart';
import '../../utilities/customButton.dart';
import '../../utilities/customNumberField.dart';
import '../../utilities/customTextField.dart';

class AccountRecovery extends StatefulWidget {
  const AccountRecovery({super.key});

  @override
  State<AccountRecovery> createState() => _AccountRecoveryState();
}

class _AccountRecoveryState extends State<AccountRecovery> {
  TextEditingController emailAddress = TextEditingController();
  bool correctFormat = false, isEAEmpty = true, isMNEmpty = true;
  TextEditingController mobileNumber = TextEditingController();

  @override
  void initState() {

    super.initState();
    emailAddress.addListener(_onEmailChanged);
    mobileNumber.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    // Check if the mobile number is valid
    setState(() {
      if(mobileNumber.text.length == 11){
        isMNEmpty = false;
      } else{
        isMNEmpty = true;
      }
    });
  }

  void _onEmailChanged() {
    // Check if the email is valid
    setState(() {
      correctFormat = isValidEmail(emailAddress.text);
      isEAEmpty = emailAddress.text.isEmpty;
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
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
              child: Text(
                'Enter mobile number associated with account',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: textColor(isMNEmpty),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
              child: PhoneNumberField(context, mobileNumber, borderColor(isMNEmpty)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0, right: 8.0, left: 8.0, bottom: 8.0),
              child: Button(
                  context,
                  'Continue',
                      () async{
                    if(!isMNEmpty && !isEAEmpty && correctFormat){
        
                    }
                  },
                  double.infinity,
                  Theme.of(context).textTheme.labelLarge!.copyWith(color: textButtonColor(!isEAEmpty && correctFormat), fontWeight: FontWeight.normal),
                  buttonColor(!isMNEmpty && !isEAEmpty && correctFormat)),
            ),
          ],
        ),
      ),
    );
  }
}
