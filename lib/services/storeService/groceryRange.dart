import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/cupertino.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class MapRange{
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Map<String, Map<String,Map <String, Future<List<List>>>>> tescoGroceryRange = {};
  Map<String, Map<String,Map <String, Future<List<List>>>>> supervaluGroceryRange = {};

  MapRange(){
    tescoGroceryRange ={
      'Fresh Food':{
        'Cheese': {
          'All Cheese': loadTescoCSV('Fresh Food', 'Cheese', 'All Cheese'),
          'Cheddar Cheese': loadTescoCSV('Fresh Food', 'Cheese', 'Cheddar Cheese'),
          'Cheese Boards & Gifts': loadTescoCSV('Fresh Food', 'Cheese', 'Cheese Boards & Gifts'),
          'Cheese Spreads & Snacks': loadTescoCSV('Fresh Food', 'Cheese', 'Cheese Spreads & Snacks'),
          'Cottage & Soft Cheese': loadTescoCSV('Fresh Food', 'Cheese', 'Cottage & Soft Cheese'),
          'Offers on Cheese': loadTescoCSV('Fresh Food', 'Cheese', 'Offers on Cheese'),
          'Sliced & Grated Cheese': loadTescoCSV('Fresh Food', 'Cheese', 'Sliced & Grated Cheese'),
          'Speciality & Continental Cheese': loadTescoCSV('Fresh Food', 'Cheese', 'Speciality & Continental Cheese'),
        },
        'Yoghurt':{
          'All Yoghurt': loadTescoCSV('Fresh Food', 'Yoghurt', 'All Yoghurt'),
          'Offers on Yoghurt': loadTescoCSV('Fresh Food', 'Yoghurt', 'Offers on Yoghurt'),
          'Yoghurt Drinks': loadTescoCSV('Fresh Food', 'Yoghurt', 'Yoghurt Drinks'),
          'Yoghurts': loadTescoCSV('Fresh Food', 'Yoghurt', 'Yoghurts'),
        },
        'Fresh Fruit': {
          'All Fresh Fruit': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'All Fresh Fruit'),
          'Apples, Pears & Rhubarb': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Apples, Pears & Rhubarb'),
          'Avocados': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Avocados'),
          'Bananas': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Bananas'),
          'Berries & Cherries': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Berries & Cherries'),
          'Citrus Fruit': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Citrus Fruit'),
          'Dried Fruit & Nuts': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Dried Fruit & Nuts'),
          'Grapes': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Grapes'),
          'Nectarines & Peaches': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Nectarines & Peaches'),
          'Organic Fruit': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Organic Fruit'),
          'Plums & Apricots': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Plums & Apricots'),
          'Prepared Fruit': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Prepared Fruit'),
          'Tropical & Exotic Fruit': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Tropical & Exotic Fruit'),
          'Offers on Fresh Fruit': loadTescoCSV('Fresh Food', 'Fresh Fruit', 'Offers on Fresh Fruit'),
        },
        'Fresh Vegetables': {
          'All Fresh Vegetables': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'All Fresh Vegetables'),
          'Baby Vegetables': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Baby Vegetables'),
          'Broccoli, Cauliflower & Cabbage': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Broccoli, Cauliflower & Cabbage'),
          'Carrots & Root Vegetables': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Carrots & Root Vegetables'),
          'Chillies, Garlic & Ginger': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Chillies, Garlic & Ginger'),
          'Courgettes, Aubergines & Asparagus': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Courgettes, Aubergines & Asparagus'),
          'Mushrooms': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Mushrooms'),
          'Onions & Shallots': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Onions & Shallots'),
          'Organic Vegetables': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Organic Vegetables'),
          'Peas, Beans & Sweetcorn': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Peas, Beans & Sweetcorn'),
          'Potatoes': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Potatoes'),
          'Prepared Vegetables': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Prepared Vegetables'),
          'Seasonal Vegetables': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Seasonal Vegetables'),
          'Spinach, Greens & Kale': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Spinach, Greens & Kale'),
          'Stir Fry': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Stir Fry'),
          'Offers on Fresh Vegetables': loadTescoCSV('Fresh Food', 'Fresh Vegetables', 'Offers on Fresh Vegetables'),
        },
        'Salads & Dips': {
          'All Salads & Dips': loadTescoCSV('Fresh Food', 'Salads & Dips', 'All Salads & Dips'),
          'Chilled Dips': loadTescoCSV('Fresh Food', 'Salads & Dips', 'Chilled Dips'),
          'Coleslaw & Dressed Salads': loadTescoCSV('Fresh Food', 'Salads & Dips', 'Coleslaw & Dressed Salads'),
          'Fresh Herbs, Chillies & Spices': loadTescoCSV('Fresh Food', 'Salads & Dips', 'Fresh Herbs, Chillies & Spices'),
          'Prepared Salad & Salad Bags': loadTescoCSV('Fresh Food', 'Salads & Dips', 'Prepared Salad & Salad Bags'),
          'Salad Vegetables': loadTescoCSV('Fresh Food', 'Salads & Dips', 'Salad Vegetables'),
          'Tomatoes': loadTescoCSV('Fresh Food', 'Salads & Dips', 'Tomatoes'),
          'Offers on Salads & Dips': loadTescoCSV('Fresh Food', 'Salads & Dips', 'Offers on Salads & Dips'),
        },
        'Milk, Butter & Eggs': {
          'All Milk, Butter & Eggs': loadTescoCSV('Fresh Food', 'Milk, Butter & Eggs', 'All Milk, Butter & Eggs'),
          'Butter, Spreads & Margarine': loadTescoCSV('Fresh Food', 'Milk, Butter & Eggs', 'Butter, Spreads & Margarine'),
          'Eggs': loadTescoCSV('Fresh Food', 'Milk, Butter & Eggs', 'Eggs'),
          'Fresh Cream & Custard': loadTescoCSV('Fresh Food', 'Milk, Butter & Eggs', 'Fresh Cream & Custard'),
          'Fresh Milk': loadTescoCSV('Fresh Food', 'Milk, Butter & Eggs', 'Fresh Milk'),
          'Baking & Cooking': loadTescoCSV('Fresh Food', 'Milk, Butter & Eggs', 'Baking & Cooking'),
          'Offers on Milk, Butter & Eggs': loadTescoCSV('Fresh Food', 'Milk, Butter & Eggs', 'Offers on Milk, Butter & Eggs'),
        },
        'Dairy Alternatives': {
          'All Dairy Alternatives': loadTescoCSV('Fresh Food', 'Dairy Alternatives', 'All Dairy Alternatives'),
          'Dairy Alternatives': loadTescoCSV('Fresh Food', 'Dairy Alternatives', 'Dairy Alternatives'),
          'Offers on Dairy Alternatives': loadTescoCSV('Fresh Food', 'Dairy Alternatives', 'Offers on Dairy Alternatives'),
        },
        'Fresh Meat & Poultry': {
          'All Fresh Meat & Poultry': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'All Fresh Meat & Poultry'),
          'Fresh Bacon': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Fresh Bacon'),
          'Fresh Beef': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Fresh Beef'),
          'Fresh Chicken': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Fresh Chicken'),
          'Fresh Duck': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Fresh Duck'),
          'Fresh Lamb': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Fresh Lamb'),
          'Fresh Pork': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Fresh Pork'),
          'Fresh Turkey': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Fresh Turkey'),
          'Ready to Cook': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Ready to Cook'),
          'Breaded Poultry': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Breaded Poultry'),
          'Sausages': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Sausages'),
          'BBQ': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'BBQ'),
          'Pudding': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Pudding'),
          'Rashers': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Rashers'),
          'Offers on Fresh Meat & Poultry': loadTescoCSV('Fresh Food', 'Fresh Meat & Poultry', 'Offers on Fresh Meat & Poultry'),
        },
        'Stuffing & Accompaniments': {
          'All Stuffing & Accompaniments': loadTescoCSV('Fresh Food', 'Stuffing & Accompaniments', 'All Stuffing & Accompaniments'),
          'Breadcrumbs & Stuffing': loadTescoCSV('Fresh Food', 'Stuffing & Accompaniments', 'Breadcrumbs & Stuffing'),
          'Sauces': loadTescoCSV('Fresh Food', 'Stuffing & Accompaniments', 'Sauces'),
          'Breadcrumbs': loadTescoCSV('Fresh Food', 'Stuffing & Accompaniments', 'Breadcrumbs'),
          'Stuffing': loadTescoCSV('Fresh Food', 'Stuffing & Accompaniments', 'Stuffing'),
          'Other': loadTescoCSV('Fresh Food', 'Stuffing & Accompaniments', 'Other'),
          'Offers on Stuffing & Accompaniments': loadTescoCSV('Fresh Food', 'Stuffing & Accompaniments', 'Offers on Stuffing & Accompaniments'),
        },
        'Chilled Fish & Sea Food': {
          'All Chilled Fish & Sea Food': loadTescoCSV('Fresh Food', 'Chilled Fish & Sea Food', 'All Chilled Fish & Sea Food'),
          'Breaded & Prepared': loadTescoCSV('Fresh Food', 'Chilled Fish & Sea Food', 'Breaded & Prepared'),
          'Cod, Haddock & White Fish': loadTescoCSV('Fresh Food', 'Chilled Fish & Sea Food', 'Cod, Haddock & White Fish'),
          'Mackerel': loadTescoCSV('Fresh Food', 'Chilled Fish & Sea Food', 'Mackerel'),
          'Prawns & Seafood': loadTescoCSV('Fresh Food', 'Chilled Fish & Sea Food', 'Prawns & Seafood'),
          'Ready to Cook': loadTescoCSV('Fresh Food', 'Chilled Fish & Sea Food', 'Ready to Cook'),
          'Salmon & Trout': loadTescoCSV('Fresh Food', 'Chilled Fish & Sea Food', 'Salmon & Trout'),
          'Smoked Fish': loadTescoCSV('Fresh Food', 'Chilled Fish & Sea Food', 'Smoked Fish'),
          'Offers on Chilled Fish & Sea Food': loadTescoCSV('Fresh Food', 'Chilled Fish & Sea Food', 'Offers on Chilled Fish & Sea Food'),
        },
        'Cooked Meat': {
          'All Cooked Meat': loadTescoCSV('Fresh Food', 'Cooked Meat', 'All Cooked Meat'),
          'Cooked Chicken & Turkey': loadTescoCSV('Fresh Food', 'Cooked Meat', 'Cooked Chicken & Turkey'),
          'Deli Counter Cooked Meats': loadTescoCSV('Fresh Food', 'Cooked Meat', 'Deli Counter Cooked Meats'),
          'Frankfurters & Snacking': loadTescoCSV('Fresh Food', 'Cooked Meat', 'Frankfurters & Snacking'),
          'Sliced Beef': loadTescoCSV('Fresh Food', 'Cooked Meat', 'Sliced Beef'),
          'Sliced Ham': loadTescoCSV('Fresh Food', 'Cooked Meat', 'Sliced Ham'),
          'Value Ham & Luncheon Meats': loadTescoCSV('Fresh Food', 'Cooked Meat', 'Value Ham & Luncheon Meats'),
          'Polish Cooked Meat': loadTescoCSV('Fresh Food', 'Cooked Meat', 'Polish Cooked Meat'),
          'Offers on Cooked Meat': loadTescoCSV('Fresh Food', 'Cooked Meat', 'Offers on Cooked Meat'),
        },
        'Continental Meats & Antipasti': {
          'All Continental Meats & Antipasti': loadTescoCSV('Fresh Food', 'Continental Meats & Antipasti', 'All Continental Meats & Antipasti'),
          'Chorizo & Pancetta': loadTescoCSV('Fresh Food', 'Continental Meats & Antipasti', 'Chorizo & Pancetta'),
          'Continental Cooked Ham': loadTescoCSV('Fresh Food', 'Continental Meats & Antipasti', 'Continental Cooked Ham'),
          'Continental Meat Platters': loadTescoCSV('Fresh Food', 'Continental Meats & Antipasti', 'Continental Meat Platters'),
          'Olives & Antipasti': loadTescoCSV('Fresh Food', 'Continental Meats & Antipasti', 'Olives & Antipasti'),
          'Parma Ham, Prosciutto & Serrano Ham': loadTescoCSV('Fresh Food', 'Continental Meats & Antipasti', 'Parma Ham, Prosciutto & Serrano Ham'),
          'Pate': loadTescoCSV('Fresh Food', 'Continental Meats & Antipasti', 'Pate'),
          'Salami & Pepperoni': loadTescoCSV('Fresh Food', 'Continental Meats & Antipasti', 'Salami & Pepperoni'),
          'Offers on Continental Meats & Antipasti': loadTescoCSV('Fresh Food', 'Continental Meats & Antipasti', 'Offers on Continental Meats & Antipasti'),
        },
        'Chilled Food': {
          'All Chilled Food': loadTescoCSV('Fresh Food', 'Chilled Food', 'All Chilled Food'),
          'Polish Food': loadTescoCSV('Fresh Food', 'Chilled Food', 'Polish Food'),
          'Offers on Chilled Food': loadTescoCSV('Fresh Food', 'Chilled Food', 'Offers on Chilled Food'),
        },
        'Chilled Desserts': {
          'All Chilled Desserts': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'All Chilled Desserts'),
          'Chilled Dessert': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'Chilled Dessert'),
          'Sponges, Pies & Puddings': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'Sponges, Pies & Puddings'),
          'Trifles & Cheesecakes': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'Trifles & Cheesecakes'),
          'Fresh Cream Desserts': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'Fresh Cream Desserts'),
          'Individual Desserts': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'Individual Desserts'),
          'Indulgent Desserts': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'Indulgent Desserts'),
          'Rice Puddings': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'Rice Puddings'),
          'Low Fat Desserts': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'Low Fat Desserts'),
          'Offers on Chilled Desserts': loadTescoCSV('Fresh Food', 'Chilled Desserts', 'Offers on Chilled Desserts'),
        },
      }
    };

    supervaluGroceryRange = {
      'Fruits & Vegetables' : {

      },
      'Bakery': {
      }

    };

  }

  Future<List<List>> loadTescoCSV(String category, String subCategory, String subSubCategory) async{
    var d = const FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);
    final rawProducts = await rootBundle.loadString("assets/Tesco/$category/$subCategory/$subSubCategory.csv");
    List<List<dynamic>> listData = CsvToListConverter(csvSettingsDetector: d).convert(rawProducts);
    return listData;
  }


}

class Product {
  final String title;
  final double price;
  final String pricePer;
  final String imageUrl;
  bool substitutable;

  Product({
    required this.title,
    required this.price,
    required this.pricePer,
    required this.imageUrl,
    this.substitutable = true
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'pricePer': pricePer,
      'imageUrl': imageUrl,
      'substitutable': substitutable
    };
  }

  void setSubstitutable(bool value) {
    substitutable = value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Product &&
              runtimeType == other.runtimeType &&
              title == other.title &&
              price == other.price &&
              pricePer == other.pricePer &&
              imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      title.hashCode ^ price.hashCode ^ pricePer.hashCode ^ imageUrl.hashCode;
}

class Cart extends ChangeNotifier{
  Map<Product, int> cart = {};

  List<Map<String, dynamic>> toMapList() {
    return cart.entries
        .map((entry) => {
      'product': entry.key.toMap(),
      'quantity': entry.value,
    })
        .toList();
  }

  void addToCart(Product product, int quantity){
    if (cart.containsKey(product)) {
      // If the product exists, update the quantity
      cart.update(product, (existingQuantity) => existingQuantity + quantity);
    } else {
      // If the product doesn't exist, add it to the cart
      cart[product] = quantity;
    }
  }

  bool isProductInCart(String productName) {
    // Check if the product is in the cart based on its title
    return cart.keys.any((product) => product.title == productName);
  }

  int? getQuantity(Product product) {
    // Get the quantity of a product in the cart based on its title
    if (cart.containsKey(product)) {
      // If the product exists, update the quantity
      return cart[product];
    }
    return null;
  }


  void reduceQtyFromCart(Product product, int quantity){
    if (cart.containsKey(product)) {
      // If the product exists, update the quantity
      cart.update(product, (existingQuantity) => existingQuantity - quantity);
    }
    if(cart[product] == 0){
      cart.remove(product);
    }
  }

  void removeFromCart(Product product){
    cart.remove(product);
  }

  void clearCart() {
    cart.clear();
  }

  void updateQuantity(Product product, int quantity){
    cart.update(product, (value) => quantity);
  }

  String calculateTotalAmount() {
    double totalAmount = 0;
    cart.forEach((product, quantity) {
      totalAmount += product.price * quantity;
    });
    String formattedTotalAmount = '€${totalAmount.toStringAsFixed(2)}';
    return formattedTotalAmount;
  }

  List<String> totalAmountPlusFees(bool deliveryType) {
    double totalAmount = 0;
    double totalCart = 0;
    double deliveryFees = deliveryType ? 6.99 : 5.99;
    cart.forEach((product, quantity) {
      totalAmount += product.price * quantity;
    });
    totalCart = totalAmount;
    totalAmount += calculateServiceFees() + deliveryFees;
    String formattedTotalAmount = '€${totalAmount.toStringAsFixed(2)}';
    String formattedServiceFee = '€${calculateServiceFees().toStringAsFixed(2)}';
    String formattedDeliveryFee = '€${deliveryFees.toStringAsFixed(2)}';
    String formattedTotalCart = '€${totalCart.toStringAsFixed(2)}';
    return [formattedTotalAmount, formattedServiceFee,  formattedDeliveryFee, formattedTotalCart];
  }

  double calculateServiceFees(){
    double serviceFees = 0;
    double totalAmount = 0;
    cart.forEach((product, quantity) {
      totalAmount += product.price * quantity;
    });
    serviceFees = totalAmount * 0.11;
    if(serviceFees > 3.29){
      serviceFees = 3.29;
      return serviceFees;
    }
    return serviceFees;
  }

  String stripEuroSign(String amountWithEuroSign) {
    // Check if the string contains the Euro sign
    if (amountWithEuroSign.startsWith('€')) {
      // Strip the Euro sign and return the rest of the string
      return amountWithEuroSign.substring(1);
    }
    // If the Euro sign is not found, return the original string
    return amountWithEuroSign;
  }

}


