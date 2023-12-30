

import 'package:cloud_firestore/cloud_firestore.dart';

class MapRange{
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Map<String, Map<String, Stream<QuerySnapshot>>> groceryRange = {};

  MapRange(){
    groceryRange ={
      'Pets': {
        'Cats & Kitten': streamFunction('Pets', 'Cats&Kitten'),
        'Dog & Puppy':streamFunction('Pets', 'Dog & Puppy'),
        'Small Animal, Fish & Bird':streamFunction('Pets', 'Small Animal, Fish & Bird'),
        'Christmas for Pets':streamFunction('Pets', 'Christmas for Pets'),
        'Offers on Pets':streamFunction('Pets', 'Offers on Pets'),
      },
      'Tesco Finest':{
        'Finest Fresh Food': streamFunction('TescoFinest', 'Finest Fresh Food'),
        'Finest Bakery': streamFunction('TescoFinest', 'Finest Bakery'),
        'Finest Drinks': streamFunction('TescoFinest', 'Finest Drinks'),
        'Finest Food Cupboard': streamFunction('TescoFinest', 'FinestFoodCupboard'),
        'Finest Frozen Food': streamFunction('TescoFinest', 'Finest Frozen Food'),

      }
    };
  }

  Stream<QuerySnapshot> streamFunction(String document, String subCollection) {
    return fireStore.collection('Tesco').doc(document).collection(subCollection).snapshots();
  }


}


