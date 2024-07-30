import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum BottomBarEnum { Home, Activity, Support, Profile }

class CustomBottomBar extends StatefulWidget {
  CustomBottomBar({Key? key, this.onChanged, required this.pages}) : super(key: key);

  Function(BottomBarEnum)? onChanged;

  List<Widget> pages;

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  int selectedIndex = 0;

  final List<BottomMenuModel> bottomMenuList = [
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

  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    if (index == selectedIndex) {
      navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        selectedIndex = index;
      });
      widget.onChanged?.call(bottomMenuList[index].type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: List.generate(bottomMenuList.length, (index) {
          return Navigator(
            key: navigatorKeys[index],
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(
                builder: (context) => widget.pages[index],
              );
            },
          );
        }),
      ),
      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
          items: bottomMenuList.map((menu) {
            return BottomNavigationBarItem(
              icon: SvgPicture.asset(
                menu.icon,
                height: 25,
                width: 25,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset(
                menu.activeIcon,
                height: 25,
                width: 25,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              label: menu.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BottomMenuModel {
  BottomMenuModel({
    required this.icon,
    required this.activeIcon,
    required this.type,
    required this.label,
  });

  final String icon;
  final String activeIcon;
  final BottomBarEnum type;
  final String label;
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
            ),
          ],
        ),
      ),
    );
  }
}
