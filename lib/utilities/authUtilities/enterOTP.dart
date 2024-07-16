import 'dart:async';
import 'package:flutter/material.dart';
import 'package:overlapd/logic/enterOTP.dart';
import 'package:pinput/pinput.dart';

import '../../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../customButton.dart';

class EnterOTP extends StatefulWidget {
  final String mobileNumber;
  final String verificationId;
  final FirebaseAuthService authService;
  final String type;
  const EnterOTP(
      {super.key,
      required this.mobileNumber,
      required this.verificationId,
      required this.authService,
      required this.type});

  @override
  State<EnterOTP> createState() => _EnterOTPState();
}

class _EnterOTPState extends State<EnterOTP> {
  late String verifyMobileNumber;
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
  );
  bool incorrectCode = true;
  bool buttonEnabled = false;
  var code;

  int _start = 60;
  late Timer _timer;
  bool _showResendButton = false;

  @override
  void initState() {
    super.initState();
    startTimer();
    verifyMobileNumber = '+353${widget.mobileNumber.replaceAll(' ', '')}';
  }

  void startTimer() {
    setState(() {
      _start = 60;
      _showResendButton = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer.cancel();
          _showResendButton = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_start ~/ 60).toString().padLeft(2, '0');
    final seconds = (_start % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 12.0, left: 8.0, right: 8.0),
                child: Text(
                  'Enter the OTP sent to',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),
                child: Text(
                  '+353 ${widget.mobileNumber}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey, fontWeight: FontWeight.w300),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: Colors.grey, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration?.copyWith(
                    border: Border.all(color: Colors.black, width: 2),
                  )),
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onChanged: (s) {
                    if (s.length < 6) {
                      setState(() {
                        incorrectCode = true;
                        buttonEnabled = false;
                      });
                    }
                  },
                  onCompleted: (pin) {
                    setState(() {
                      buttonEnabled = true;
                      code = pin;
                    });
                  },
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: incorrectCode
                    ? const SizedBox.shrink()
                    : Padding(
                        key: ValueKey<bool>(incorrectCode),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'The OTP is incorrect! Please try again',
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
                  if (buttonEnabled) {
                    bool value = await verifyOTP(
                        context, widget.verificationId, code, widget.type);
                    setState(() {
                      incorrectCode = value;
                    });
                  }
                },
                    double.infinity,
                    Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: textButtonColor(buttonEnabled),
                        fontWeight: FontWeight.normal),
                    buttonColor(buttonEnabled)),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: !_showResendButton
                    ? Padding(
                        key: ValueKey<bool>(_showResendButton),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Resend code in $_formattedTime',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                        ),
                      )
                    : Padding(
                        key: ValueKey<bool>(_showResendButton),
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                            children: [
                              const TextSpan(
                                text: 'Didn\'t receive the code? ',
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    widget.authService.resendOTP(
                                        widget.mobileNumber,
                                        context); // Use auth service to resend OTP
                                    startTimer();
                                  },
                                  child: Text(
                                    ' Resend',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ));
  }
}
