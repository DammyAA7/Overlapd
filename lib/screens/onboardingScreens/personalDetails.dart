import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/screens/home/home_screen.dart';
import 'package:overlapd/screens/testScreen.dart';
import 'package:overlapd/utilities/customTextField.dart';
import 'package:overlapd/utilities/widgets.dart';
import '../../logic/personalDetails.dart';
import '../../logic/splash.dart';
import '../../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../../utilities/customButton.dart';

class PersonalDetails extends StatefulWidget {
  const PersonalDetails({super.key});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  bool incorrectFormat = true,
      isLNEmpty = true,
      isFNEmpty = true,
      isEAEmpty = true;
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    emailAddress.addListener(_onEmailChanged);
    firstName.addListener(_onChanged);
    lastName.addListener(_onChanged);
  }

  void _onEmailChanged() {
    // Check if the email is valid
    setState(() {
      incorrectFormat = isValidEmail(emailAddress.text);
      isEAEmpty = emailAddress.text.isEmpty;
    });
  }

  void _onChanged() {
    // Check if the email is valid
    setState(() {
      isLNEmpty = lastName.text.isEmpty;
      isFNEmpty = firstName.text.isEmpty;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.05,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 12.0, left: 8.0, right: 8.0),
                  child: Text(
                    'Let\'s get to know you',
                    style:
                        Theme.of(context).textTheme.headlineLarge!.copyWith(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextBox(
                    context,
                    'First Name',
                    'John',
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
                    'Guiness',
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
                      borderColor(isEAEmpty)),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: incorrectFormat
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey<bool>(incorrectFormat),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Incorrect email format',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: Colors.red),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, right: 8.0, left: 8.0, bottom: 8.0),
                  child: Button(
                      context,
                      'Continue',
                          () async{
                        if(!isFNEmpty && !isLNEmpty && !isEAEmpty && incorrectFormat){
                          createUserCredentials(_auth.currentUser, firstName.text, lastName.text, emailAddress.text);
                          await _auth.setLoggedInAsUser();
                          Navigator.of(context).pushReplacement(pageAnimationlr(const HomeScreen()));
                        }
                      },
                      double.infinity,
                      Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: textButtonColor(!isFNEmpty &&
                              !isLNEmpty &&
                              !isEAEmpty &&
                              incorrectFormat),
                          fontWeight: FontWeight.normal),
                      buttonColor(!isFNEmpty &&
                          !isLNEmpty &&
                          !isEAEmpty &&
                          incorrectFormat)),
                ),
              ],
            ),
          ),
        ));
  }
}
