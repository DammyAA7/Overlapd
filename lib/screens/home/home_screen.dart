import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:overlapd/screens/cart/provider/cart_provider.dart';
import 'package:overlapd/screens/cart/screen/cart_screen.dart';
import 'package:overlapd/screens/category/shop_by_category.dart';
import 'package:overlapd/screens/home/models/category.dart';
import 'package:overlapd/screens/home/models/store.dart';
import 'package:overlapd/screens/home/provider/home_provider.dart';
import 'package:overlapd/screens/home/widget/home_widgets.dart';
import 'package:overlapd/screens/store/provider/store_provider.dart';
import 'package:overlapd/screens/store/store_screen.dart';
import 'package:overlapd/utilities/bottomBarUtil/custom_bottom_bar.dart';
import 'package:overlapd/utilities/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});

  @override
  HomeScreenPageState createState() => HomeScreenPageState();
  static Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          return const HomeScreenPage();
        },
      ),
    );
  }
}

class HomeScreenPageState extends State<HomeScreenPage> {
  @override
  void initState() {
    super.initState();
    // Provider.of<HomeProvider>(context, listen: false).searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _buildAppBar(context),
          body: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Consumer<HomeProvider>(
                    builder: (context, provider, child) =>
                        provider.isEmailVerfied
                            ? const SizedBox()
                            : _buildVerifyYourEmail(context)),
                const SizedBox(height: 12),
                _buildOrderGroceries(context),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Selector<HomeProvider, TextEditingController?>(
                    selector: (context, provider) => provider.searchController,
                    builder: (context, searchController, child) {
                      return SizedBox(
                        height: 50,
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              Provider.of<HomeProvider>(context, listen: false)
                                  .clearSearch();
                            }
                            Provider.of<HomeProvider>(context, listen: false)
                                .searchCategory(value);
                            Provider.of<HomeProvider>(context, listen: false)
                                .searchStore(value);
                          },
                          onSubmitted: (value) {
                            if (value.isEmpty) {
                              Provider.of<HomeProvider>(context, listen: false)
                                  .clearSearch();
                            }
                            Provider.of<HomeProvider>(context, listen: false)
                                .searchCategory(value);
                            Provider.of<HomeProvider>(context, listen: false)
                                .searchStore(value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search items, supermarkets, etc",
                            hintStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFA6A6A6)),
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFFA6A6A6)),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildShopByCategory(context),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 26),
                    child: Text("Stores around you",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        )),
                  ),
                ),
                const SizedBox(height: 12),
                _buildUserProfile(context),
              ],
            ),
          )),
    );
  }

  /// AppBar Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      // leading:
      title: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF535353)),
          const SizedBox(
            width: 10,
          ),
          const Text("2972 Westheimer Rd ",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF535353),
              )
              // style: theme.textTheme.titleLarge,
              ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_sharp),
            onPressed: () {},
          ),
        ],
      ),
      actions: [
         IconButton(
          icon: Stack(
            children: [
                  const CircleAvatar(
                backgroundColor: Color(0xFFEDEDED),
                child: Icon(Icons.shopping_cart_outlined),
                foregroundColor: Colors.black,
              ),
              Positioned(
                left: 20,
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Consumer<CartProvider>(
                      builder: (context, provider, child) {
                        return Text(
                          provider.cart[1].products.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ),
          
            ],
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  /// Verify Email Widget
  Widget _buildVerifyYourEmail(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 158,
                child: Text(
                  "Verify your email address to complete your profile",
                  maxLines: 2,
                  // style: theme.textTheme.titleSmall,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Stack(
                  children: [
                    Positioned(
                      top: -10.4,
                      child: Transform(
                        transform: Matrix4.identity()..rotateZ(-1.097375287),
                        child: SizedBox(
                            width: 28.5,
                            height: 28.5,
                            child:
                                // draw an ellipse
                                Transform.rotate(
                              angle: 0.0,
                              child: Container(
                                width: 28.5,
                                height: 28.5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDEDED),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            )),
                      ),
                    ),
                    Positioned(
                      left: -5.9,
                      top: -7.6,
                      child: Transform(
                        transform: Matrix4.identity()..rotateZ(0.1135441011),
                        child: SizedBox(
                            width: 23.4,
                            height: 23.4,
                            child:
                                // draw an ellipse
                                Transform.rotate(
                              angle: 0.0,
                              child: Container(
                                width: 23.4,
                                height: 23.4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDEDED),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            )),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(8.4, 10.4, 7.5, 9.1),
                      child: const Text(
                        '90%',
                        style: TextStyle(
                          // 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 6.1,
                          height: 1.5,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 129),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 1,
                    ),
                    // progress bar
                  ],
                ),
              )
            ],
          ),
          CustomElevatedButton(
              onPressed: () {},
              text: "Verify Email",
              buttonTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              // style: theme.textTheme.titleSmall,
              width: 122,
              margin: const EdgeInsets.symmetric(vertical: 20),
              //  decoration: BoxDecoration(
              //    color: Colors.black,
              //    borderRadius: BorderRadius.circular(8),
              //  ),
              buttonStyle: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                //  shape: MaterialStateProperty.all(
                //    RoundedRectangleBorder(
                //      borderRadius: BorderRadius.circular(8),
                //    ),
                //  ),
              ))
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildOrderGroceries(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120.0,
            width: MediaQuery.of(context).size.width / 2.3,
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(
                      width: 35,
                    ),
                    Container(
                      height: 20,
                      width: 20,
                      margin: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                          // color: theme.colorScheme.primary600,
                          borderRadius: BorderRadius.circular(
                        5,
                      )),
                      child: Consumer<HomeProvider>(
                        builder: (context, provider, child) {
                          return Radio(
                            value: 0,
                            groupValue: provider.selectOption,
                            onChanged: (value) {
                              provider.selectOptionIndex(0);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 55,
                      ),
                      CircleAvatar(
                        backgroundColor: Color(0xFFD9D9D9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Order groceries",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    )
                    // style: theme.textTheme.bodyMedium,
                    ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 120.0,
            width: MediaQuery.of(context).size.width / 2.3,
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(
                      width: 35,
                    ),
                    Container(
                        height: 20,
                        width: 20,
                        margin: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                            // color: theme.colorScheme.primary600,
                            borderRadius: BorderRadius.circular(
                          5,
                        )),
                        child: Consumer<HomeProvider>(
                          builder: (context, provider, child) {
                            return Radio(
                              value: 1,
                              groupValue: provider.selectOption,
                              onChanged: (value) {
                                provider.selectOptionIndex(1);
                              },
                            );
                          },
                        ))
                  ],
                ),
                const Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 55,
                      ),
                      CircleAvatar(
                        backgroundColor: Color(0xFFD9D9D9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Deliver groceries",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    )
                    // style: theme.textTheme.bodyMedium,
                    ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildShopByCategory(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Shop by category",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              // style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: Consumer<HomeProvider>(
                builder: (context, provider, child) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        width: 32,
                      );
                    },
                    itemCount: provider.shopCategoryItems.length,
                    itemBuilder: (context, index) {
                      Category model = provider.shopCategoryItems[index];
                      return ShopCategoryItem(
                        model,
                        () {
                          provider.selectCategory(model);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ShopByCategory()),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildUserProfile(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 26,
                  ),
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 32,
                    );
                  },
                  itemCount: provider.stores.length,
                  itemBuilder: (context, index) {
                    Store model = provider.stores[index];
                    return StoreItem(
                      model,
                      () {
                        provider.selectStore(model);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StoreScreen()),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
// class _HomeScreenState extends State<HomeScreen> {
  static Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: const HomeScreen(),
    );
  }
}



class HomeScreenState extends State<HomeScreen> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Navigator(
          key: navigatorKey,
          onGenerateRoute: (setting) => PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    getCurrentPage(context, setting.name!),
                transitionDuration: Duration.zero,
              )),
      bottomNavigationBar: _buildBottomBar(context),
    ));
  }

  Widget _buildBottomBar(BuildContext context) {
    return CustomBottomBar(onChanged: (BottomBarEnum type) {
      Navigator.pushNamed(navigatorKey.currentContext!, getCurrentRoute(type));
    });
  }

  String getCurrentRoute(BottomBarEnum type) {
    switch (type) {
      case BottomBarEnum.Home:
        return '/home';
      case BottomBarEnum.Activity:
        return '/activity';
      case BottomBarEnum.Support:
        return '/support';
      case BottomBarEnum.Profile:
        return '/profile';
      default:
        return '';
    }
  }

  Widget getCurrentPage(BuildContext context, String route) {
    switch (route) {
      case '/home':
        return const HomeScreenPage();
      case '/activity':
        return const CartScreen();
      case '/support':
        return const DefaultWidget();
      case '/profile':
        return const DefaultWidget();
      default:
        return const HomeScreenPage();
    }
  }
}
