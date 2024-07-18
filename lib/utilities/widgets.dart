import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../screens/about.dart';
import '../screens/payment.dart';
import '../screens/settings.dart';
import '../screens/support.dart';
import 'package:overlapd/screens/history.dart';

import 'customButton.dart';

Widget pageText(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 4),
    child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
  );
}

class InputBoxController {
  final TextEditingController controller = TextEditingController();
  VoidCallback? _listener;
  void dispose() {
    controller.dispose();
  }

  String getText() {
    return controller.text;
  }

  void clear() {
    controller.clear();
  }

  void addListener(VoidCallback listener) {
    _listener = listener;
    controller.addListener(_listener!);
  }

  // Method to remove the listener from the controller
  void removeListener() {
    if (_listener != null) {
      controller.removeListener(_listener!);
    }
  }
}

Widget multilineLetterInputBox(String hintText, bool autoCorrect,
    bool obscureText, InputBoxController inputBoxController) {
  return widgetInputBox(
    maxLines: null,
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.multiline,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: inputBoxController,
  );
}

Widget supportLetterInputBox(String hintText, bool autoCorrect,
    bool obscureText, InputBoxController inputBoxController) {
  return widgetInputBox(
    maxLines: 1,
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.text,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: inputBoxController,
  );
}

Widget numberInputBox(String hintText, bool autoCorrect, bool obscureText,
    InputBoxController inputBoxController) {
  return widgetInputBox(
    maxLines: 1,
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.number,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: inputBoxController,
  );
}

Widget letterInputBox(String hintText, bool autoCorrect, bool obscureText,
    InputBoxController? inputBoxController) {
  return widgetInputBox(
    maxLines: 1,
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

Widget alphanumericInputBox(String hintText, bool autoCorrect, bool obscureText,
    InputBoxController inputBoxController, String? initialValue) {
  return widgetInputBox(
    maxLines: 1,
    hintText: hintText,
    autoCorrect: autoCorrect,
    obscureText: obscureText,
    textType: TextInputType.text,
    initialValue: initialValue,
    onChanged: (value) {
      // You can perform any additional actions when the text changes here
    },
    inputBoxController: inputBoxController,
    inputFormatter:
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9'\s-]")),
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

Widget addressInputBox(
  String hintText,
  bool autoCorrect,
  bool obscureText,
  String? initialValue,
  TextInputType type,
  Function(String) onSaved,
) {
  return TextFormField(
    initialValue: initialValue,
    obscureText: obscureText,
    autocorrect: autoCorrect,
    keyboardType: type,
    onChanged: onSaved,
    style: const TextStyle(
      color: Color(0xFF727E7B),
      fontSize: 22.0,
    ),
    decoration: InputDecoration(
      contentPadding:
          const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
      filled: true,
      fillColor: const Color(0xFF6EE8C5).withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(
          color: const Color(0xFF6EE8C5).withOpacity(0.6),
          width: 2.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(
          style: BorderStyle.solid,
          color: const Color(0xFF6EE8C5).withOpacity(0.6),
          width: 4.5,
        ),
      ),
      hintStyle: const TextStyle(color: Color(0xFF727E7B), fontSize: 22.0),
      hintText: hintText,
    ),
  );
}

Widget emailInputBox(String hintText, bool autoCorrect, bool obscureText,
    InputBoxController inputBoxController) {
  return widgetInputBox(
    maxLines: 1,
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
        if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
            .hasMatch(value)) {
          return 'Invalid email address.';
        }
      }
      return null; // No error
    },
  );
}

Widget passwordInputBoxForLogin(String hintText, bool autoCorrect,
    bool obscureText, InputBoxController inputBoxController) {
  return widgetInputBox(
    maxLines: 1,
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
    maxLines: 1,
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
    maxLines: 1,
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
  String? initialValue,
  String? Function(String?)? validator,
  required int? maxLines,
  InputBoxController? inputBoxController,
}) {
  List<TextInputFormatter> formatters = [];
  if (inputFormatter != null) {
    formatters.add(inputFormatter);
  }

  inputBoxController?.controller.addListener(() {
    if (onChanged != null) {
      onChanged(inputBoxController.controller.text);
    }
  });

  bool hasError = validator != null &&
      validator(inputBoxController?.controller.text) != null;

  return TextFormField(
    maxLines: maxLines == null ? maxLines : 1,
    initialValue: initialValue,
    controller: inputBoxController?.controller,
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
      errorText:
          hasError ? validator!(inputBoxController?.controller.text) : null,
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
          fontSize: 22.0),
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

Widget sideBarCard(BuildContext context, Icon icon, String title,
    String subtitle, Widget pageRoute) {
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
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
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

Widget EventCard(Widget child) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Container(
      constraints: BoxConstraints(
          minHeight: 100,
          maxHeight: 300
      ), // Minimum height for the container
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    ),
  );
}

Widget statusTimelineTile({
  required bool isFirst,
  required bool isLast,
  required bool isPast,
  required eventCard
}){
  return TimelineTile(
    alignment: TimelineAlign.start,
    isFirst: isFirst,
    isLast: isLast,
    beforeLineStyle: LineStyle(
        thickness: 2,
        color: isPast ?  Colors.green.shade900 : Colors.grey.shade400
    ),
    indicatorStyle: IndicatorStyle(
        width: 25,
        color: isPast ? Colors.green.shade900 : Colors.grey.shade400,
        iconStyle: IconStyle(
            iconData: isPast ? Icons.done : Icons.close,
            color: Colors.white
        )
    ),
    endChild: EventCard(eventCard)
  );
}


Widget timelineTileText(BuildContext context, String header, String first, String second, bool? addButton){
  addButton ??= false;
  return  Padding(
    padding: const EdgeInsets.all(4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 10),
        Text(first,
            overflow: TextOverflow.visible,
            maxLines: 3,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300)
        ),
        Text(second,
            overflow: TextOverflow.visible,
            maxLines: 3,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300)
        ),
        addButton ? Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Button(
              context,
              'Track Delivery',
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: const Text('Your delivery is 3 minutes away',
                            textAlign: TextAlign.center,
                          ),
                          content: Text('You can track the exact location of your delivery person on Google maps',
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                          ),
                          actions: <Widget>[
                            Center(
                              child: Button(
                                context,
                                'Open map',
                                  (){},
                                  MediaQuery.of(context).size.width * 0.7,
                                  Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                                  Colors.black
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
              MediaQuery.of(context).size.width * 0.5,
              Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
              Colors.grey
          ),
        ) : const SizedBox.shrink()
      ],
    ),
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
            sideBarCard(context, const Icon(Icons.person), userName,
                "Personal Information", const Setting()),
            sideBarCard(context, const Icon(Icons.payment), "Payment", "",
                const Payment()),
            sideBarCard(context, const Icon(Icons.access_time_outlined),
                "History", "", const History()),
            sideBarCard(context, const Icon(Icons.support_agent_outlined),
                "Support", "", const Support()),
            sideBarCard(context, const Icon(Icons.info_outline_rounded),
                "About", "", const About())
          ],
        ),
      ),
    )),
  );
}

Widget itemTile(String itemName, int itemQTY, void Function()? add,
    void Function()? subtract) {
  String capitalizedItemName = itemName
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');
  return Padding(
    padding: const EdgeInsets.only(top: 25),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: const Color(0xFF21D19F).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20)),
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
            ],
          )
        ],
      ),
    ),
  );
}

class BaseButton extends StatelessWidget {
  const BaseButton(
      {Key? key,
      required this.text,
      this.onPressed,
      this.buttonStyle,
      this.isDisabled,
      this.buttonTextStyle,
      this.height,
      this.width,
      this.alignment,
      this.margin})
      : super(key: key);

  final String text;

  final VoidCallback? onPressed;

  final ButtonStyle? buttonStyle;

  final bool? isDisabled;

  final TextStyle? buttonTextStyle;

  final double? height;

  final double? width;

  final Alignment? alignment;

  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class CustomElevatedButton extends BaseButton {
  CustomElevatedButton(
      {Key? key,
      this.decoration,
      this.leftIcon,
      this.rightIcon,
      EdgeInsets? margin,
      VoidCallback? onPressed,
      ButtonStyle? buttonStyle,
      Alignment? alignment,
      TextStyle? buttonTextStyle,
      bool? isDisabled,
      double? height,
      double? width,
      required String text})
      : super(
          key: key,
          text: text,
          onPressed: onPressed,
          buttonStyle: buttonStyle,
          isDisabled: isDisabled,
          buttonTextStyle: buttonTextStyle,
          height: height,
          width: width,
          alignment: alignment,
          margin: margin,
        );

  final BoxDecoration? decoration;

  final Widget? leftIcon;

  final Widget? rightIcon;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: buildElevatedButtonWidget)
        : buildElevatedButtonWidget;
  }

  Widget get buildElevatedButtonWidget => Container(
        height: this.height ?? 31,
        width: this.width ?? double.maxFinite,
        margin: margin,
        decoration: decoration,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: isDisabled ?? false ? null : onPressed ?? () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leftIcon ?? const SizedBox.shrink(),
              Text(
                text,
                style: buttonTextStyle ?? const TextStyle(fontSize: 16),
              ),
              rightIcon ?? const SizedBox.shrink()
            ],
          ),
        ),
      );
}

// Image Widget

class CustomImageView extends StatelessWidget {
  const CustomImageView({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.alignment,
    this.margin,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment? alignment;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
    );
  }
}
