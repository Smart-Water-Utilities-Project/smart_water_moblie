import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyProvider extends ChangeNotifier {
  double bottomArea = 1, maxHeight = 1;

  Future fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bottomArea = prefs.getDouble('bottomArea') ?? 1;
    maxHeight = prefs.getDouble('maxHeight') ?? 1;
  }

  Future<void> setTankSize({double? area, double? height}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (area != null) {
      await prefs.setDouble("bottomArea", area);
      bottomArea = prefs.getDouble('bottomArea') ?? 1;
    }

    if(height != null) {
      await prefs.setDouble("maxHeight", height);
      maxHeight = prefs.getDouble('maxHeight') ?? 1;
    }

    notifyListeners();
  }
}