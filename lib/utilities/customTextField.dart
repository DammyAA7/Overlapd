import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget CustomTextBox(
    BuildContext context,
    String title,
    String hintText,
    TextStyle titleStyle,
    TextEditingController controller,
    TextInputType keyboardType,
    Color borderColor,
    [TextInputFormatter? inputFormatter]
    ) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 15.0),
        child: Text(
            title,
          style: titleStyle,
        ),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2), // Border color
          borderRadius: BorderRadius.circular(10.0), // Border radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatter != null ? [inputFormatter] : null,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    ],
  );
}