import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlapd/screens/cart/model/cart_model.dart';
import 'package:overlapd/screens/cart/provider/cart_provider.dart';
import 'package:overlapd/screens/category/widget/shop_bc_widgets.dart';
import 'package:overlapd/screens/home/models/store.dart';
import 'package:overlapd/screens/home/provider/home_provider.dart';
import 'package:overlapd/screens/store/provider/store_provider.dart';
import 'package:overlapd/screens/store/widget/category_widget.dart';
import 'package:provider/provider.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Store store = Provider.of<HomeProvider>(context).selectedStore;
    return ChangeNotifierProvider(
        create: (context) => StoreScreenProvider(),
        child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: _buildAppBar(context),
                body: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.maxFinite,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 6),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 0, 0, 4),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFE3E3E3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  child: Container(
                                                    width: 50,
                                                    height: 50,
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 8, 8, 8),
                                                    child: Image.asset(
                                                      store.imageAss!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  0.4, 0, 0.4, 4),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  store.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    height: 1.5,
                                                    color: Color(0xFF535353),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  0.5, 0, 0, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .fromLTRB(0, 0, 6.5, 0),
                                                    child: Text(
                                                      store.address,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        height: 1.5,
                                                        color:
                                                            Color(0xFF858585),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .fromLTRB(0, 1, 5.4, 1),
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xFF858585),
                                                      ),
                                                      child: Container(
                                                        width: 1,
                                                        height: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    store.distance!,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      height: 1.5,
                                                      color: Color(0xFF858585),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: SizedBox(
                                          width: 40,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 8, 0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFEDEDED),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.9),
                                                  ),
                                                  child: Container(
                                                    width: 16,
                                                    height: 16,
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        4.6, 4.9, 4.6, 5.1),
                                                    child: const SizedBox(
                                                        width: 6.8,
                                                        height: 6,
                                                        child: Icon(
                                                          Icons.favorite,
                                                          size: 9,
                                                        )),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFEDEDED),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.9),
                                                ),
                                                child: Container(
                                                  width: 16,
                                                  height: 16,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          4.8, 4.4, 4.8, 4.4),
                                                  child: const SizedBox(
                                                      width: 6.4,
                                                      height: 7.1,
                                                      child: Icon(
                                                        Icons.share,
                                                        size: 9,
                                                      )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Selector<StoreScreenProvider,
                                          TextEditingController?>(
                                        selector: (p0, p1) =>
                                            p1.searchController,
                                        builder: (context, value, child) {
                                          return SizedBox(
                                            height: 50,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .9,
                                            child: TextField(
                                              controller: value,
                                              decoration: InputDecoration(
                                                hintText:
                                                    "Search ${store.name}",
                                                hintStyle: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFFA6A6A6)),
                                                prefixIcon: const Icon(
                                                    Icons.search,
                                                    color: Color(0xFFA6A6A6)),
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: store.subCategories!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.subCategories![index].name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        (store.subCategories![index].products
                                                    .length <=
                                                3
                                            ? .35 / 2
                                            : store.subCategories![index]
                                                    .products.length *
                                                .07), // Adjust the height as needed
                                    child: GridView.builder(
                                      padding: const EdgeInsets.all(5),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing:  12,
                                        childAspectRatio:
                                            1, // Adjust this value to control the item size
                                      ),
                                      itemBuilder: (context, idx) {
                                        return ViewHierarchyItemWidget(
                                          store.subCategories![index]
                                              .products[idx],
                                              () {
                                            Provider.of<CartProvider>(
                                                context,
                                                listen: false)
                                                .addToCart(
                                                CartModel(
                                                  store: store,
                                                  products: [
                                                    store.subCategories![index]
                                                        .products[idx]
                                                  ],
                                                ));

                                                // update price
                                                // Provider.of<CartProvider>(
                                                //   context,
                                                //   listen: false,
                                                // ).calculatePrice();
                                              }
                                        );
                                      },
                                      itemCount: store.subCategories![index]
                                          .products.length,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      ]),
                    ),
                  ),
                ))));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: const Row(
        children: [
          SizedBox(
            width: 10,
          ),
          Icon(Icons.keyboard_backspace),
          Text("Go Back",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
        ],
      ),
      actions: [
        IconButton(
          icon: const CircleAvatar(
            backgroundColor: Color(0xFFEDEDED),
            child: Icon(Icons.shopping_cart_outlined),
            foregroundColor: Colors.black,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
