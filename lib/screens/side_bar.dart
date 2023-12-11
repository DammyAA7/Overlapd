import 'package:flutter/material.dart';
import 'package:overlapd/screens/about.dart';
import 'package:overlapd/screens/history.dart';
import 'package:overlapd/screens/payment.dart';
import 'package:overlapd/screens/settings.dart';
import 'package:overlapd/screens/support.dart';

import '../utilities/widgets.dart';

class SideBar extends StatefulWidget {
  static const id = 'sidebar';
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
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
                  sideBarCard(context, const Icon(Icons.person), "Oluwadamilola Adebayo", "Personal Information", const Setting()),
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


}
