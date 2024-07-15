import 'package:flutter/material.dart';

import '../screens/onboardingScreens/accountRecovery.dart';
import '../utilities/widgets.dart';

bool isPhoneNumberValid(String phoneNumber) {
  // Remove any spaces from the phone number
  final sanitizedNumber = phoneNumber.replaceAll(' ', '');
  // Check if the sanitized number is exactly 9 digits long
  return sanitizedNumber.length == 9 && int.tryParse(sanitizedNumber) != null;
}

Color buttonColor(bool isValid) => isValid ? Colors.black : Colors.grey;

Color textButtonColor(bool isValid) => isValid ? Colors.white : Colors.black54;

Widget termsAndConditions(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 15),
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
                    fontSize: 15),
              ),
            ),
          ),
          TextSpan(
            text: ' and ',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 15),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'privacy policy',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget cantAccessAccount(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: () {
        Navigator.of(context).push(pageAnimationrl(const AccountRecovery()));
      },
      child: Text(
        'Don\'t have access to your phone number?',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15),
      ),
    ),
  );
}

Widget shrinkedBox() {
  return const SizedBox.shrink();
}
