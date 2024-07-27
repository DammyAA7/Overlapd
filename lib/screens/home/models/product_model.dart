import 'package:overlapd/screens/home/models/store.dart';

class Product {
  final String title;
  final String price;
  final String promotionalPrice;
  final String pricePer;
  final String productUrl;
  final String imageUrl;
  final int productId;
  final StoreItemModel? store;

  Product({
    required this.title,
    required this.price,
    required this.promotionalPrice,
    required this.pricePer,
    required this.productUrl,
    required this.imageUrl,
    required this.productId,
    required this.store,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['Title'] as String,
      price: json['Price'] as String,
      promotionalPrice: json['Promotional Price'] as String,
      pricePer: json['Price Per'] as String,
      productUrl: json['Product URL'] as String,
      imageUrl: json['Image URL'] as String,
      productId: json['productId'] as int,
      store:
          json['store'] != null ? StoreItemModel.fromJson(json['store']) : null,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Price': price,
      'Promotional Price': promotionalPrice,
      'Price Per': pricePer,
      'Product URL': productUrl,
      'Image URL': imageUrl,
      'productId': productId,
      'store': store?.toJson(),
    };
  }
}
