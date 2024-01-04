import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_water_moblie/core/data_parser.dart';
import 'package:smart_water_moblie/core/smart_water_api.dart';

class TimelyProvider with ChangeNotifier {
  double _flow = 0, _temp = 0, _level = 0, _summary = 0,
         _bottomArea = 1, _maxHeight = 1,
         _dayUsage = 0, _monthUsage = 0;
         
  int _dayLimit = 1, _monthLimit = 1;

  double get flow => _flow;
  double get temp => _temp;
  double get level => _level;
  double get summary => _summary;
  double get bottomArea => _bottomArea;
  double get maxHeight => _maxHeight;
  double get dayUsage => _dayUsage;
  double get monthUsage => _monthUsage;
  double get capacity => _maxHeight * _bottomArea;
  int get dayLimit => _dayLimit;
  int get monthLimit => _monthLimit;

  void setTimely({double? flow, temp, level, summary, dayUsage, monthUsage, int? dayLimit, monthLimit }) {
    _flow = flow??_flow;
    _temp = temp??_temp;
    _level = level??_level;
    _summary = summary??_summary;
    _dayUsage = dayUsage??_dayUsage;
    _monthUsage = monthUsage??_monthUsage;
    _dayLimit = dayLimit??_dayLimit;
    _monthLimit = monthLimit??_monthLimit;

    notifyListeners();
  }

  Future initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _bottomArea = prefs.getDouble('bottomArea') ?? 1;
    _maxHeight = prefs.getDouble('maxHeight') ?? 1;
    _level = _maxHeight;
  }

  Future<void> setTankSize({double? area, double? height}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    _bottomArea = area??_bottomArea;
    await prefs.setDouble("bottomArea", area??_bottomArea);

    _maxHeight = height??_maxHeight;
    await prefs.setDouble("maxHeight", height??_maxHeight);

    notifyListeners();
  }

  Future<void> updateDayUsage() async {
    final response = await SmartWaterAPI.instance.getHistory(Date.reqDay());
    if (response.errorMsg != null) {
      debugPrint("ERROR fetching day usage");
      return;
    }
    final data = SensorDataParser.day(response.value, Date.reqDay());
    _dayUsage = data.$2?.sumWf??0;
    notifyListeners();
    return;
    
    // _dayUsage = response.value;
  }

  Future<void> updateMonthUsage() async {
    final response = await SmartWaterAPI.instance.getHistory(Date.reqMonth());
    if (response.errorMsg != null) {
      debugPrint("ERROR fetching day usage");
      return;
    }
    final data = SensorDataParser.month(response.value, Date.reqMonth());
    _monthUsage = data.$2?.sumWf??0;
    notifyListeners();
    return;
    
    // _dayUsage = response.value;
  }
}