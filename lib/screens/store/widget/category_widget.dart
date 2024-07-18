import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final EdgeInsets padding;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Container(
        padding: padding,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 8,
            height: 1.5,
            color: Color(0xFF8C8C8C),
          ),
        ),
      ),
    );
  }
}
