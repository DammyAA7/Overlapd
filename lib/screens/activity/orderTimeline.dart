import 'package:flutter/material.dart';

class OrderTimeline extends StatefulWidget {
  const OrderTimeline({super.key});

  @override
  State<OrderTimeline> createState() => _OrderTimelineState();
}

class _OrderTimelineState extends State<OrderTimeline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.shopping_cart_outlined, color: Colors.black),
                  )
              )
            ],
          )
      ),
    );
  }
}
