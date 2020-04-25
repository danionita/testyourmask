import 'package:flutter/foundation.dart';

class Values with ChangeNotifier {
  String irValue;
  String redValue;

  void changeIr(String irValue) {
    this.irValue = irValue;
    notifyListeners();
  }
  void changeRed(String redValue) {
    this.redValue = redValue;
    notifyListeners();
  }
}
