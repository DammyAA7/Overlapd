import 'package:overlapd/screens/home/models/subcategory.dart';

class Category {
  final String name;
  final String imageAss;
  final String store;
  final List<SubCategory> subCategories;

  Category({
    required this.name,
    required this.store,
    required this.subCategories,
    this.imageAss = "assets/storeLogos/grocery.png",
  });

  factory Category.fromJson(
      String name, String store, Map<String, dynamic> json) {
    return Category(
      name: name,
      store: store,
      imageAss: json['image'] as String? ?? "assets/storeLogos/grocery.png",
      subCategories: json.entries
          .map((e) => SubCategory.fromJson(
                e.key,
                store,
                e.value as List<dynamic>,
              ))
          .toList(),
    );
  }
}
