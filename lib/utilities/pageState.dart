import 'package:flutter/material.dart';

class CheckBoxState with ChangeNotifier {
  late List<bool?> isCheckedList;

  CheckBoxState(List<bool?> initialList) {
    isCheckedList = List.from(initialList);
  }

  void updateCheckBoxState(int index, bool? value) {
    isCheckedList[index] = value;
    notifyListeners();
  }
}
