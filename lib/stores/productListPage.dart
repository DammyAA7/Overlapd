import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:overlapd/stores/groceryRange.dart';
import 'package:overlapd/stores/shoppingCart.dart';
import 'package:overlapd/utilities/toast.dart';
import 'package:provider/provider.dart';
import '../utilities/widgets.dart';



class Meat extends StatefulWidget {
  static const id = 'meat_page';
  final Stream<QuerySnapshot> snapshot;
  const Meat({super.key, required this.snapshot});

  @override
  State<Meat> createState() => _MeatState();
}

class _MeatState extends State<Meat> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                // Navigate to the home page with a fade transition
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Tesco',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: _buildProductList()
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: (){
              Navigator.push(
                context,
                  pageAnimationFromBottomToTop(const ShoppingCart())
              );
            },
            tooltip: 'View shopping cart',
            child: const Icon(Icons.shopping_cart_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Colors.blue
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: (){
                                setState(() {
                                  quantity += 1;
                                });
                                },
                              icon: const Icon(Icons.add)),
                          Text('$quantity'),
                          IconButton(
                              onPressed: (){
                                setState(() {
                                  if(quantity > 1){
                                    quantity -= 1;
                                  }
                                });
                                },
                              icon: const Icon(Icons.remove)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                SlidableAction(onPressed: ((context){
                  //add to cart
                  Product product = Product(
                      title: data['title'].toString(),
                      price: double.parse(data['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')),
                      pricePer: data['pricePer'].toString(),
                      imageUrl: data['imageUrl'].toString()
                  );
                  final cart = context.read<Cart>();
                  cart.addToCart(product, quantity);
                  setState(() {
                    quantity = 1;
                  });

                  showToast(text: 'Successfully Added to cart');
                }),
                  padding: const EdgeInsets.all(2.0),
                  flex: 1,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  backgroundColor: Colors.red,
                  icon: Icons.add_shopping_cart_rounded
                ),
              ],
            ),
            child: SizedBox(
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.network(data['imageUrl'].toString()),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['title'].toString(), overflow: TextOverflow.visible, maxLines: 2,),
                      Text(data['price'].toString()),
                      Text(data['pricePer'].toString())
                    ],
                  )
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1)
        ],
      ),
    );
  }

  Widget _buildProductList(){
    return StreamBuilder(
        stream: widget.snapshot,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the data is still loading, return a loading indicator
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            // If there is no data or the data is empty, display a message
            return const Text('No messages');
          } else {
            return SlidableAutoCloseBehavior(
              closeWhenOpened: true,
              child: ListView(
                children: snapshot.data!.docs.map((document) => _buildProductItem(document)).toList(),
              ),
            );
          }
        }
    );
  }


}
