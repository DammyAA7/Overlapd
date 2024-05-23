import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget PhoneNumberField(BuildContext context, TextEditingController controller){
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Text(
              '+353',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            const VerticalDivider(
              color: Colors.grey,
              thickness: 1,
              width: 30,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '9 digit phone number',
                  hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                  PhoneNumberFormatter(),
                ],
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 5) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}