import 'package:overlapd/screens/home/models/product_model.dart';

class SubCategory {
  final String name;
  final List<Product> products;
  final String store;

  SubCategory({
    required this.name,
    required this.store,
    required this.products,
  });

  factory SubCategory.fromJson(String name, String store, List<dynamic> json) {
    return SubCategory(
      name: name,
      store: store,
      products:
          json.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
