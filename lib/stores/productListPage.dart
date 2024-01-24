import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:overlapd/stores/groceryRange.dart';
import 'package:overlapd/stores/shoppingCart.dart';
import 'package:overlapd/utilities/toast.dart';
import 'package:provider/provider.dart';
import '../utilities/widgets.dart';



class Meat extends StatefulWidget {
  static const id = 'meat_page';
  final Future<List<List>> productCSV;
  const Meat({super.key, required this.productCSV});

  @override
  State<Meat> createState() => _MeatState();
}

class _MeatState extends State<Meat> {
  List<List> productList = [];
  int quantity = 1;
  String filterProduct = "";
  bool scroll = true;
  TextEditingController searchText = TextEditingController();
  bool flag = true;
  Map<Product, int> productQuantities = {};
  Map<Product, bool> productFlags = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Navigate to the home page with a fade transition
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title:  Text(
          'Tesco',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: Consumer<Cart>(
        builder: (context, cart, child) => NotificationListener<UserScrollNotification>(
          onNotification: (notification){
            if(notification.direction == ScrollDirection.forward){
              if(!scroll) setState(() => scroll = true);
            } else if(notification.direction == ScrollDirection.reverse){
              if(scroll) setState(() => scroll = false);
            }
            return true;
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Visibility(
                  visible: scroll,
                  maintainState: true,
                  child: TextField(
                    controller: searchText, // Use the stored value
                    onChanged: (value){
                      setState(() {
                        filterProduct = value;
                      });
                    },
                    decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                        ),
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search_outlined),
                      suffixIcon: IconButton(onPressed: (){
                        setState((){
                          filterProduct = "";
                          searchText.clear();
                        });
                      }, icon: const Icon(Icons.clear))
                    ),
                  ),
                ),
                Expanded(
                    child: _buildProductList(cart)
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () async{
              await Navigator.push(
                context,
                  pageAnimationFromBottomToTop(const ShoppingCart()),
              );
              setState(() {});
            },
            tooltip: 'View shopping cart',
            child: const Icon(Icons.shopping_cart_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(List data, Cart cart){

    if (data[3] == 'Currently out of stock') {
      return const SizedBox.shrink();
    }

    bool isInCart = cart.isProductInCart(data[0].toString());

    if(filterProduct.isEmpty){
      return productListTile(data, isInCart, cart);
    }
    if(data[0].toString().toLowerCase().contains(filterProduct.toLowerCase())){
      return productListTile(data, isInCart, cart);
    }
    else{
      return const SizedBox.shrink();
    }

  }

  Padding productListTile(List data, bool isInCart, Cart cart) {
    Product product = Product(
        title: data[0].toString(),
        price: double.parse(data[1].toString().replaceAll(RegExp(r'[^0-9.]'), '')),
        pricePer: data[3].toString(),
        imageUrl: data[5].toString()
    );
    int quantity = productQuantities[product] ?? 1; // Get quantity for the product
    bool flag = productFlags[product] ?? true; // Get flag for the product
    if (isInCart) {
      flag = false; // Set flag to false if the product is in the cart
      quantity = cart.getQuantity(product) ?? 1; // Get quantity from the cart
    } else{
      flag = true; // Set flag to true if the product is not in the cart
      quantity = 1; // Set quantity to 1 if the product is not in the cart
    }

    return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Column(
      children: [
        SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 3,
                  child: Image.network(data[5].toString())),
              Expanded(
                  flex: 6,
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(data[0].toString(), overflow: TextOverflow.visible, maxLines: 2, style: Theme.of(context).textTheme.labelLarge,),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[
                            Text(data[1].toString(), style: Theme.of(context).textTheme.labelLarge,),
                            const SizedBox(width: 5),
                            Text(data[3].toString(), style: Theme.of(context).textTheme.labelMedium)
                        ]
                      ),

                    ],
                  )
              ),
              Expanded(
                  flex: 1,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: flag ? IconButton(
                      key: const Key('1'),
                      onPressed: () {
                        //add to cart
                        cart.addToCart(product, quantity);

                        showToast(text: 'Successfully Added to cart');
                        setState(() {
                          productFlags[product] = !flag; // Update flag in the map
                        });
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                    ) : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      key: const Key('2'),
                      children: [
                        Flexible(
                          flex: 1,
                          child: IconButton(
                              onPressed: (){
                                setState(() {
                                  quantity += 1;
                                });
                                productQuantities[product] = quantity; // Update quantity in the map
                                cart.addToCart(product, 1);
                              },

                              icon: const Icon(Icons.add)),
                        ),
                        Flexible(
                            flex: 1,
                            child: Text('$quantity', style: Theme.of(context).textTheme.labelLarge,)),
                        Flexible(
                          flex: 1,
                          child: IconButton(
                              onPressed: (){
                                setState(() {
                                  if(quantity > 0){
                                    quantity -= 1;
                                  }
                                  if(quantity == 0){
                                    productFlags[product] = !flag; // Update flag in the map
                                    quantity = 1;
                                  }
                                });
                                productQuantities[product] = quantity; // Update quantity in the map
                                cart.reduceQtyFromCart(product, 1);
                                productQuantities[product] = quantity; // Update quantity in the map
                              },
                              icon: const Icon(Icons.remove)),
                        ),
                      ],
                    ),
                  )
              )
            ],
          ),
        ),
        const Divider(thickness: 1)
      ],
    ),
  );
  }

  Widget _buildProductList(Cart cart){
    return FutureBuilder(
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.none &&
              snapshot.hasData) {
            // If the data is still loading, return a loading indicator
            return const CircularProgressIndicator();
          }
          return ListView.builder(
            itemCount: productList.length,
            itemBuilder: (context, index){
              if(index == 0 || productList[index][1] == 'Currently out of stock'){
                return const SizedBox.shrink();
              }
              return _buildProductItem(productList[index], cart);
            },
          );
          }, future: loadCSV(),
    );
  }

  Future loadCSV() async{
    productList = await widget.productCSV;
    return productList;
  }

}
