import 'package:overlapd/screens/home/models/category.dart';
import 'package:overlapd/screens/home/models/product_model.dart';
import 'package:overlapd/screens/home/models/subcategory.dart';

class Store {
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final String? imageAss;
  String? distance;
  final List<Category> categories;
  List<Product>? products = [];
  List<SubCategory>? subCategories = [];

  Store(
      {required this.name,
      required this.address,
      this.phone,
      this.email,
      this.imageAss,
      required this.categories,
      this.distance,
      this.products,
      this.subCategories});

  factory Store.fromJson(Map<String, dynamic> json) {
    List<Product> products = [];
    List<SubCategory> subCategories = [];
    /// We have the case where it's going to be null because when we push the cart to the firestore we don't need to push the products again.
    if (json['products'] != null) {
    for (var cat in (json['products']
    as Map<String, dynamic>)
        .keys
        .map((e) => Category.fromJson(e, json['name'], json['products'][e]))
        .toList()) {
      for (var subCat in cat.subCategories) {
        subCategories.add(subCat);
        products.addAll(subCat.products);
      }
    }
    }

    return Store(
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      imageAss: json['image'] as String? ?? 'assets/storeLogos/tesco.png',
      categories: json['products'] != null ? (json['products'] as Map<String, dynamic>)
          .keys
          .map((e) => Category.fromJson(e, json['name'], json['products'][e]))
          .toList() : [],
      products: products,
      subCategories: subCategories,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'image': imageAss,
      'products': null /// It's better to keep it null as it's not needed (Complex to handle as it just duplicates the data)
       
    };
  }
}

class StoreItemModel {
  final String name;
  final String address;
  final String image;
  final String? distance;
  final List<String> hierarchy;

  StoreItemModel({
    required this.name,
    required this.address,
    required this.image,
    required this.hierarchy,
    this.distance,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      name: json['name'] as String,
      address: json['address'] as String,
      image: json['image'] as String,
      hierarchy: json['hierarchy'].cast<String>(),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'image': image,
      'hierarchy': hierarchy,
    };
  }
}
