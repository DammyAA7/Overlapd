import 'package:flutter/material.dart';
import 'package:overlapd/screens/cart/model/cart_model.dart';
import 'package:overlapd/screens/cart/provider/cart_provider.dart';
// import 'package:flutter/widgets.dart';
import 'package:overlapd/screens/category/model/shop_by_category_model.dart';
import 'package:overlapd/screens/category/provider/shop_by_category_provider.dart';
import 'package:overlapd/screens/category/widget/shop_bc_widgets.dart';
import 'package:overlapd/screens/home/models/category.dart';
import 'package:overlapd/screens/home/models/product_model.dart';
import 'package:overlapd/screens/home/models/store.dart';
import 'package:overlapd/screens/home/models/subcategory.dart';
import 'package:overlapd/screens/home/provider/home_provider.dart';
import 'package:overlapd/screens/home/widget/home_widgets.dart';
import 'package:pinput/pinput.dart';  
import 'package:provider/provider.dart';

class ShopByCategory extends StatefulWidget {
  const ShopByCategory({super.key});

  @override
  State<ShopByCategory> createState() => _ShopByCategoryState();
}

class _ShopByCategoryState extends State<ShopByCategory> {
  @override
  Widget build(BuildContext context) {
    final category = Provider.of<HomeProvider>(context).selectedCategory;

    Map<String, Category> shopCategoryItems = {};

    // Filter the categories based on the store name and add them to the shopCategoryItems list
    for (var i = 0; i < category.subCategories.length; i++) {
      if (shopCategoryItems.containsKey(category.subCategories[i].store)) {
        shopCategoryItems[category.subCategories[i].store]!.subCategories
            .add(category.subCategories[i]);
      } else {
        shopCategoryItems[category.subCategories[i].store] = Category(
            name: category.subCategories[i].store,
            store: category.subCategories[i].store,
            subCategories: [category.subCategories[i]]);
      }
      
    }
   

    return ChangeNotifierProvider(
        create: (context) => ShopByCategoryProvider(),
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: _buildAppBar(context),
            body: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  const SizedBox(
                    height: 9,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Category",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Selector<HomeProvider, TextEditingController?>(
                        selector: (p0, p1) => p1.searchController,
                        builder: (context, value, child) {
                          return SizedBox(
                            height: 50,
                            child: TextField(
                              controller: value,
                              decoration: InputDecoration(
                                hintText:
                                    "Search for a category. i.e ${category.name}",
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
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: shopCategoryItems.length,
                    
                      itemBuilder: (context, index) {
                        return _buildSearchResults(context, shopCategoryItems.values.elementAt(index), shopCategoryItems.keys.elementAt(index));
                      },
                    ),
                  ),
                  // _buildSearchResults(context, category.selectedCategory),
                  const SizedBox(
                    height: 20,
                  ),

                  // SizedBox(height: 39,),
                  // Padding(padding: EdgeInsets.only(left: 20),
                  // child: Row(
                  //   children: [
                  //     Container(
                  //       height: 52,
                  //       width: 52,
                  //       decoration: BoxDecoration(
                  //         color:
                  //       ),
                  //     )
                  // ],
                  // ),)
                ],
              ),
            ),
          ),
        ));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: InkWell(
        onTap: () {
          Navigator.pop(context, true);
        },
        child: const Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Icon(Icons.keyboard_backspace),
            Text("Go Back",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
          ],
        ),
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

  Widget _buildSearchResults(BuildContext context, Category store, String storeName) {
    List<Product> products = [];
    for (var i = 0; i < store.subCategories.length; i++) {
      products.addAll(store.subCategories[i].products);
    }
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${products.length} results for ${store.name}",
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          ),
          const SizedBox(
            height: 28,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                      color: const Color(0xffD9D9D9),
                      borderRadius: BorderRadius.circular(26)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.store,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        "10-20 mins",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 150,
            child: Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Consumer<CartProvider> (
                 builder: (context, providercart, childcart) {

                  return ListView.separated(
                    padding: const EdgeInsets.only(left: 5),
                    scrollDirection: Axis.horizontal,
                  
                    itemBuilder: (context, index) {
                      return ViewHierarchyItemWidget(products[index], () {
                        providercart.addToCart(CartModel(
                          store: Store(
                            name: storeName,
                            address: products[index].store!.address,
                            phone: 'products[index].store!.phone,',
                            categories: [],
                            email: 'products[index].store!.email,',
                            // image: "Store 1 Image",
                          ),
                          products: [products[index]],
                        ));
                        
                      });
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        width: 12,
                      );
                    },
                    // mod 3
                    itemCount: products.length > 3 ? 3 : products.length,
                  );
                 }
                );
              },
            ),
          ),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  "View all ${products.length > 3 ? products.length - 3 : 0} items",
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      decoration: TextDecoration.underline),
                ),
              )),
              const SizedBox(
                height: 20,
              )
        ],
      ),
    );
  }
}
