import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

enum BottomBarEnum { Home, Activity, Support, Profile }

class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({Key? key, this.onChanged})
      : super(
          key: key,
        );

  int selectedIndex = 0;

  List<BottomMenuModel> bottomMenuList = [
    BottomMenuModel(
        icon: "assets/bottomBar/home.svg",
        activeIcon: "assets/bottomBar/home.svg",
        type: BottomBarEnum.Home,
        label: 'Home'),
    BottomMenuModel(
        icon: "assets/bottomBar/activity.svg",
        activeIcon: "assets/bottomBar/activity.svg",
        type: BottomBarEnum.Activity,
        label: 'Activity'),
    BottomMenuModel(
        icon: "assets/bottomBar/support.svg",
        activeIcon: "assets/bottomBar/support.svg",
        type: BottomBarEnum.Support,
        label: 'Support'),
    BottomMenuModel(
        icon: "assets/bottomBar/profile.svg",
        activeIcon: "assets/bottomBar/profile.svg",
        type: BottomBarEnum.Profile,
        label: 'Profile')
  ];

  Function(BottomBarEnum)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      height: 60,
      // decoration: BoxDecoration(
      //   color: theme.colorScheme.primary
      // ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        elevation: 0,
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: List.generate(bottomMenuList.length, (index) {
          return BottomNavigationBarItem(
            icon: SvgPicture.asset(bottomMenuList[index].icon,
                height: 25,
                width: 25,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn)
                // color: Colors.black
                ),
            activeIcon: SvgPicture.asset(bottomMenuList[index].activeIcon,
                height: 25,
                width: 25,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)

                // color: Colors.black
                ),
            label: bottomMenuList[index].label,
          );
        }),
        onTap: (index) {
          selectedIndex = index;
          onChanged?.call(bottomMenuList[index].type);
        },
      ),
    );
  }
}
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class BottomMenuModel {
  BottomMenuModel(
      {required this.icon,
      required this.activeIcon,
      required this.type,
      required this.label});

  String icon;

  String activeIcon;

  BottomBarEnum type;

  String label;
}

class DefaultWidget extends StatelessWidget {
  const DefaultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffffffff),
      padding: const EdgeInsets.all(10),
      child: const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please replace the respective Widget here',
              style: TextStyle(
                fontSize: 18,
              ),
            )
          ],
        ),
      ),
    );
  }
}
