import 'package:shared_preferences/shared_preferences.dart';

class ConstantValue {
  
  ConstantValue._();
  static ConstantValue? _instance;
  static ConstantValue get instance {
    _instance ??= ConstantValue._();
    _instance?.initValue();
    return _instance!;
  }

  double? towerArea, fullLevel, offsetLevel;

  Future initValue() async {
    final prefs = await SharedPreferences.getInstance();
    towerArea = prefs.getDouble('towerArea')??0;
    fullLevel = prefs.getDouble('fullLevel')??0;
    offsetLevel = prefs.getDouble('offsetLevel')??0;
  }
}