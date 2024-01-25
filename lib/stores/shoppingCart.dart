import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:overlapd/stores/checkout.dart';
import 'package:provider/provider.dart';
import '../deliveries/delivery_service.dart';
import '../screens/home.dart';
import '../utilities/toast.dart';
import '../utilities/widgets.dart';
import 'groceryRange.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              // Navigate to the home page with a fade transition
              Navigator.pop(
                  context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          centerTitle: true,
          title:  Text(
            'Cart',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
        body: value.cart.isEmpty ? const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.center,
              child: Text('Shopping cart is empty')),
        ) : Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(
                child: SlidableAutoCloseBehavior(
                  closeWhenOpened: true,
                  child: ListView.builder(
                      itemCount: value.cart.length,
                      itemBuilder: (context, index) {
                        final Product product = value.cart.keys.elementAt(index);
                        int quantity = value.cart.values.elementAt(index);
                        return  Column(
                          children: [
                            SizedBox(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Image.network(product.imageUrl)
                                  ),
                                  Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(product.title, overflow: TextOverflow.visible, maxLines: 2, style: Theme.of(context).textTheme.labelLarge,),
                                          Row(
                                            children: [
                                              Text('€${product.price.toString()}', style: Theme.of(context).textTheme.labelLarge,),
                                              Text(product.pricePer, style: Theme.of(context).textTheme.labelMedium,)
                                            ],
                                          )
                                        ],
                                      )
                                  ),
                                  Expanded(
                                      child: Column(
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
                                                  // Update quantity in the map
                                                  value.addToCart(product, 1);
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
                                                      quantity = 1;
                                                    }
                                                  });
                                                  value.reduceQtyFromCart(product, 1);
                                                },
                                                icon: const Icon(Icons.remove)),
                                          ),
                                        ],
                                      ),
                                  )
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                            )
                          ],
                        );
                      }
                  ),
                ),
              ),
              const Divider(thickness: 1),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:'),
                    Text(value.calculateTotalAmount())
                  ],
                ),
              ),
              solidButton(context, 'Continue to Checkout', (){
                Navigator.push(
                    context,
                    pageAnimationFromBottomToTop(const Checkout())
                );
              }, value.cart.isNotEmpty)
            ],
          ),
        ),
      ),
    );
  }

}
