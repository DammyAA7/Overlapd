import 'package:flutter/material.dart';
import 'package:overlapd/screens/home/models/category.dart';
import 'package:overlapd/screens/home/models/store.dart';

class StoreItem extends StatelessWidget {
  const StoreItem(this.store, this.onTap, {super.key});

  final Store store;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 67,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(26),
                    image: DecorationImage(
                        image: AssetImage(store.imageAss!), fit: BoxFit.fill)),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                store.name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff535353)),
              ),
              SizedBox(height: 6),
              Text(
                store.distance ?? '10-20 mins',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFBABABA)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ShopCategoryItem extends StatelessWidget {
  const ShopCategoryItem(this.shopCategory, this.onTap, {super.key});

  final Category shopCategory;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 41,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 21),
          child: Column(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(18),
                    image: DecorationImage(
                        image: AssetImage(shopCategory.imageAss),
                        fit: BoxFit.cover)),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                child: Text(
                  shopCategory.name,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  style:
                      const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  // style:
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// class StoreItemModel {
//   StoreItemModel(
//       {this.name, this.distance, this.id, this.image, this.address}) {
//     name = name ?? 'Tesco';
//     distance = distance ?? '10-20 mins';
//     id = id ?? '1';
//     image = image ?? 'assets/storeLogos/tesco.png';
//   }

//   String? name;
//   String? distance;
//   String? id;
//   String? image;
//   String? address;
// }

// class ShopCategoryModel {
//   ShopCategoryModel({this.name, this.id, this.image}) {
//     name = name ?? 'Grocery';
//     id = id ?? '1';
//     image = image ?? 'assets/images/grocery.png';
//   }

//   String? name;
//   String? id;
//   String? image;
// }

// class HomeModel {
//   List<ShopCategoryModel> shopCategoryItems = [
//     (ShopCategoryModel(name: 'Snacks')),
//     (ShopCategoryModel(name: 'Bakery')),
//     (ShopCategoryModel(name: 'Fruits')),
//     (ShopCategoryModel(name: 'Drinks')),
//     (ShopCategoryModel(name: 'Coffee')),
//     (ShopCategoryModel(name: 'Meat')),
//   ];

// }
