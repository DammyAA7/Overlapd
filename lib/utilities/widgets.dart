import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../screens/about.dart';
import '../screens/payment.dart';
import '../screens/settings.dart';
import '../screens/support.dart';
import 'package:overlapd/screens/history.dart';

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

  void clear() {
    controller.clear();
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
    inputFormatter: FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z'-]")),
    validator: (String? value) {
      if (value != null && value.isNotEmpty) {
        if (!RegExp(r"^[a-zA-Z'-]+$").hasMatch(value)) {
          return 'Invalid character: Numbers are not allowed.';
        }
      }
      return null; // No error
    },
  );
}

Widget alphanumericInputBox(
    String hintText,
    bool autoCorrect,
    bool obscureText,
    InputBoxController inputBoxController,
    ) {
  return widgetInputBox(
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.text,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: inputBoxController,
    inputFormatter: FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9'\s-]")),
    validator: (String? value) {
      if (value != null && value.isNotEmpty) {
        if (!RegExp(r"^[a-zA-Z0-9'\s-]+$").hasMatch(value)) {
          return 'Invalid characters: Only letters, numbers, spaces, hyphen, and apostrophe are allowed.';
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
    style: const TextStyle(
      color: Color(0xFF727E7B),
      fontFamily: 'Darker Grotesque',
      fontSize: 22.0,
    ),
    decoration: InputDecoration(
      contentPadding:
      const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
      filled: true,
      fillColor: hasError
          ? Colors.red.withOpacity(0.1)
          : const Color(0xFF6EE8C5).withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(
          color: hasError
              ? Colors.red.withOpacity(0.6)
              : const Color(0xFF6EE8C5).withOpacity(0.6),
          width: 2.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
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
        fontSize: 18.0, // Adjust as needed
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
        fontSize: 22.0
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
    height: 70,
    child: ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isEnabled ? const Color(0xFF21D19F) : Colors.grey,
        elevation: 0,
      ),
      child: Text(
        buttonName,
        maxLines: 1,
        style: TextStyle(
          color: isEnabled ? const Color(0xFFF6FEFC) : Colors.white70,
          fontWeight: FontWeight.w500,
          fontSize: 22,

        ),
      ),
    ),
  );
}

Widget sideBarCard(
    BuildContext context,
    Icon icon,
    String title,
    String subtitle,
    Widget pageRoute
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      onTap: () {
    // Navigate to the home page with a fade transition
    Navigator.pushReplacement(
    context,
    pageAnimationrl(pageRoute),
  );
},
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: icon,
      ),
      title: Text(title,
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20
          )
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold
          )
      ),
    ),
  );
}

PageRouteBuilder<dynamic> pageAnimationlr(Widget pageRoute) {

  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => pageRoute,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutQuart;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}

PageRouteBuilder<dynamic> pageAnimationrl(Widget pageRoute) {

  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => pageRoute,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutQuart;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}

PageRouteBuilder<dynamic> pageAnimationFromBottomToTop(Widget pageRoute) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => pageRoute,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutQuart;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}

PageRouteBuilder<dynamic> pageAnimationFromTopToBottom(Widget pageRoute) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => pageRoute,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, -1.0); // Top-to-bottom transition
      const end = Offset.zero;
      const curve = Curves.easeInOutQuart;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}



Drawer buildDrawer(BuildContext context, String userName) {
  return Drawer(
    backgroundColor: Colors.white,
    child: SafeArea(
        child: Container(
          width: 288,
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                sideBarCard(context, const Icon(Icons.person),userName, "Personal Information", const Setting()),
                sideBarCard(context, const Icon(Icons.payment), "Payment", "", const Payment()),
                sideBarCard(context, const Icon(Icons.access_time_outlined), "History", "", const History()),
                sideBarCard(context, const Icon(Icons.support_agent_outlined), "Support", "", const Support()),
                sideBarCard(context, const Icon(Icons.info_outline_rounded), "About", "", const About())
              ],
            ),
          ),
        )
    ),
  );
}

Widget itemTile(String itemName, int itemQTY, void Function()? add, void Function()? subtract){
  String capitalizedItemName = itemName
      .split(' ')
      .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');
  return Padding(
    padding: const EdgeInsets.only(top: 25),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF21D19F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              capitalizedItemName,
            ),
          ),
          const SizedBox(width: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            IconButton(onPressed: subtract, icon: const Icon(Icons.remove)),
            Text('$itemQTY'),
            IconButton(onPressed: add, icon: const Icon(Icons.add)),
          ],)

        ],
      ),
    ),
  );
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

