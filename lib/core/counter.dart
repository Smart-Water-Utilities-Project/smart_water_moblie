
import 'package:flutter/material.dart';

class CounterModel with ChangeNotifier {
  double value = 0;
  double get count => value;

  void set(double val) {
    value = val;
    notifyListeners();
  }
}

class Controller {
  static CounterModel flow = CounterModel();
  static CounterModel temp = CounterModel();
  static CounterModel level = CounterModel(); 
  static CounterModel summary = CounterModel();
}