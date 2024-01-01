import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimelyProvider with ChangeNotifier {
  double _flow = 0, _temp = 0, _level = 0, _summary = 0,
         _bottomArea = 1, _maxHeight = 1;

  double get flow => _flow;
  double get temp => _temp;
  double get level => _level;
  double get summary => _summary;
  double get bottomArea => _bottomArea;
  double get maxHeight => _maxHeight;
  double get capacity => _maxHeight * _bottomArea;

  void setTimely({double? flow, double? temp, double? level, double? summary}) {
    _flow = flow??_flow;
    _temp = temp??_temp;
    _level = level??_level;
    _summary = summary??_summary; 

    notifyListeners();
  }

  

  Future initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _bottomArea = prefs.getDouble('bottomArea') ?? 1;
    _maxHeight = prefs.getDouble('maxHeight') ?? 1;
  }

  Future<void> setTankSize({double? area, double? height}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    _bottomArea = area??_bottomArea;
    await prefs.setDouble("bottomArea", area??_bottomArea);

    _maxHeight = height??_maxHeight;
    await prefs.setDouble("maxHeight", height??_maxHeight);

    notifyListeners();
  }
}