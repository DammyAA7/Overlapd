import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  final DeliveryService _service = DeliveryService();
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  // Navigate to the home page with a fade transition
                  Navigator.pop(
                      context);
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Shopping Cart',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
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
                                                  final cart = context.read<Cart>();
                                                  setState(() {
                                                    quantity += 1;
                                                    cart.updateQuantity(product, quantity);
                                                  });
                                                },
                                                icon: const Icon(Icons.add)),
                                            Text('$quantity'),
                                            IconButton(
                                                onPressed: (){
                                                  final cart = context.read<Cart>();
                                                  setState(() {
                                                    if(quantity > 1){
                                                      quantity -= 1;
                                                      cart.updateQuantity(product, quantity);
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
                                    //remove from cart
                                    final cart = context.read<Cart>();
                                    cart.removeFromCart(product);
                                    setState(() {});
                                    showToast(text: 'Successfully removed from cart');
                                  }),
                                      padding: const EdgeInsets.all(2.0),
                                      flex: 1,
                                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete_forever_rounded
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                height: 150,
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.network(product.imageUrl),
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.title, overflow: TextOverflow.visible, maxLines: 2,),
                                        Text('€${product.price.toString()}'),
                                        Text(product.pricePer)
                                      ],
                                    )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 2,
                            )
                          ],
                        );
                      }
                  ),
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total: ${value.calculateTotalAmount()}', style: const TextStyle(fontSize: 30)),
                  ],
                ),
              ),
              solidButton(context, 'Checkout', (){
                _checkout('12 Dalriada Court', 'Tesco', value.cart, value.calculateTotalAmount());
              }, value.cart.isNotEmpty)
            ],
          ),
        ),
      ),
    );
  }

  void _checkout(String setAddress, String chosenStore, Map<Product, int> products, String amount) async{
    List<Map<String, dynamic>> productListMap = context.read<Cart>().toMapList();
    await _service.openDelivery(setAddress, chosenStore, productListMap, amount);
    context.read<Cart>().clearCart();
    Navigator.of(context).pushReplacement(
        pageAnimationFromTopToBottom(const Home()));
    showToast(text: 'Delivery Confirmed');
  }

}
