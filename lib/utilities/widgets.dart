import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget pageText(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 4),
    child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
  );
}
class InputBoxController {
  final TextEditingController controller = TextEditingController();
  void dispose() {
    controller.dispose();
  }

  String getText() {
    return controller.text;
  }
}

Widget letterInputBox(String hintText, bool autoCorrect, bool obscureText,
    InputBoxController inputBoxController) {
  return widgetInputBox(
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.text,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: inputBoxController,
    inputFormatter: FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
    validator: (String? value) {
      if (value != null && value.isNotEmpty) {
        if (RegExp(r'[0-9]').hasMatch(value)) {
          return 'Invalid character: Numbers are not allowed.';
        }
      }
      return null; // No error
    },
  );
}

Widget emailInputBox(String hintText, bool autoCorrect, bool obscureText,
    InputBoxController inputBoxController) {
  return widgetInputBox(
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.emailAddress,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: inputBoxController,
    validator: (String? value) {
      if (value != null && value.isNotEmpty) {
        if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
          return 'Invalid email address.';
        }
      }
      return null; // No error
    },
  );
}

Widget passwordInputBoxForLogin(String hintText, bool autoCorrect, bool obscureText,
    InputBoxController inputBoxController) {
  return widgetInputBox(
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.visiblePassword,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: inputBoxController,
  );
}


Widget passwordInputBox(String hintText, bool autoCorrect, bool obscureText,
    InputBoxController inputBoxController) {
  return widgetInputBox(
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.visiblePassword,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: inputBoxController,
    validator: (String? value) {
      if (value != null && value.isNotEmpty) {
        // Check if the password is at least 10 characters long
        if (value.length < 10) {
          return 'Password must be at least 10 characters long.';
        }

        // Check if the password contains at least 1 capital letter
        if (!RegExp(r'[A-Z]').hasMatch(value)) {
          return 'Password must contain at least 1 capital letter.';
        }

        // Check if the password contains at least 1 number
        if (!RegExp(r'[0-9]').hasMatch(value)) {
          return 'Password must contain at least 1 number.';
        }

        // Check if the password contains at least 1 special character
        if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
          return 'Password must contain at least 1 special character.';
        }
      }

      return null; // No error
    },
  );
}

Widget passwordConfirmationInputBox(
    String hintText,
    bool autoCorrect,
    bool obscureText,
    InputBoxController passwordController,
    InputBoxController confirmationController,
    ) {
  return widgetInputBox(
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.visiblePassword,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: confirmationController,
    validator: (String? value) {
      if (value != null && value.isNotEmpty) {
        // Check if the confirmation password matches the initially typed password
        if (value != passwordController.controller.text) {
          return 'Passwords do not match.';
        }
      }

      return null; // No error
    },
  );
}



Widget widgetInputBox({
  required String hintText,
  required bool autoCorrect,
  required bool obscureText,
  required TextInputType textType,
  Function(String)? onChanged,
  TextInputFormatter? inputFormatter,
  String? Function(String?)? validator,
  required InputBoxController inputBoxController,
}) {
  List<TextInputFormatter> formatters = [];
  if (inputFormatter != null) {
    formatters.add(inputFormatter);
  }

  inputBoxController.controller.addListener(() {
    if (onChanged != null) {
      onChanged(inputBoxController.controller.text);
    }
  });

  bool hasError = validator != null && validator(inputBoxController.controller.text) != null;

  return TextField(
    controller: inputBoxController.controller,
    onChanged: onChanged,
    obscureText: obscureText,
    autocorrect: autoCorrect,
    keyboardType: textType,
    inputFormatters: formatters,
    decoration: InputDecoration(
      contentPadding:
      const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      filled: true,
      fillColor: hasError
          ? Colors.red.withOpacity(0.1)
          : const Color(0xFF6EE8C5).withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(
          color: hasError
              ? Colors.red.withOpacity(0.6)
              : const Color(0xFF6EE8C5).withOpacity(0.6),
          width: 2.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(
          style: BorderStyle.solid,
          color: hasError
              ? Colors.red.withOpacity(0.6)
              : const Color(0xFF6EE8C5).withOpacity(0.6),
          width: 4.5,
        ),
      ),
      errorText: hasError ? validator!(inputBoxController.controller.text) : null,
      errorStyle: const TextStyle(
        fontSize: 14.0, // Adjust as needed
        fontWeight: FontWeight.bold,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(
          color: Colors.red.withOpacity(0.6),
          width: 3.5,
        ),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF727E7B),
        fontFamily: 'Darker Grotesque',
      ),
      hintText: hintText,
    ),
  );
}


Widget textButton(BuildContext context, String buttonText, String routeName) {
  return TextButton(
    onPressed: () {
      Navigator.pushReplacementNamed(context, routeName);
    },
    style: TextButton.styleFrom(foregroundColor: Colors.black),
    child: Text(buttonText),
  );
}

Widget solidButton(
    BuildContext context,
    String buttonName,
    Function() onPressed,
    bool isEnabled,
    ) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: isEnabled ? const Color(0xFF21D19F) : Colors.grey,
        elevation: 0,
      ),
      child: Text(
        buttonName,
        style: TextStyle(
          color: isEnabled ? const Color(0xFFF6FEFC) : Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
