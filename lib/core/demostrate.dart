import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_water_moblie/core/counter.dart';
import 'package:smart_water_moblie/core/extension.dart';

class DemoMode {
  Timer? timelyUpdateTimer;
  late bool timely, waterflow;

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    timely = prefs.getBool('timelyDataDemo') ?? false;
    waterflow = prefs.getBool('waterflowChartDemo') ?? false;
    await setTimely(timely);
    await setWaterflow(waterflow);

  }

  Future<void> setTimely(bool isDemo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('timelyDataDemo', isDemo);
    timely = isDemo;

    if (timely) {
      if (timelyUpdateTimer?.isActive ?? false) {return;}
      const oneSec = Duration(milliseconds: 1000);
      timelyUpdateTimer = Timer.periodic(oneSec, (Timer t) {
        Controller.summary.set(Controller.summary.value + 1.3);
        Controller.temp.set(Random().nextDouble() * 32);
        Controller.flow.set(Random().nextInt(1000).toDouble());
        Controller.level.set(Random().nextInt(1000).toDouble());
      });
    } else {
      Controller.summary.set(0);
      Controller.temp.set(0);
      Controller.flow.set(0);
      Controller.level.set(0);
      timelyUpdateTimer?.cancel();
    }
  }

  Future<void> setWaterflow(bool isDemo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('waterflowChartDemo', isDemo);
    waterflow = isDemo;
  }

  List<Map<String, dynamic>>? chartDemo({
    required (DateTime, DateTime) timeSet, //(startTime, endTime)
    int dataPerHour=2
  }) {
    if (!waterflow) {return null;}
    List<Map<String, dynamic>> data = [];
    // final hourRange = timeSet.$2.subtract(Duration(hours: timeSet.$1.hour)).hour;
    final msTs = timeSet.$2.toMinutesSinceEpoch() - timeSet.$1.toMinutesSinceEpoch();
    final hourRange = msTs/60 + 1;
    
    for (int i=1; i<hourRange; i++) {
      final startTs = timeSet.$1.add(Duration(hours: i-1));
      final endTs = timeSet.$1.add(Duration(hours: i));
      
      for (int j=0; j<dataPerHour; j++) {
        final tsRange = (endTs.toMinutesSinceEpoch() - startTs.toMinutesSinceEpoch()).floor();
        final ts = Random().nextDouble() * tsRange + startTs.toMinutesSinceEpoch();

        final waterflow = Random().nextDouble() * 256;
        final watertemp = Random().nextDouble() * 15 + 20;
        final waterlevel = Random().nextDouble() * 15 + 20;

        data.add({"t": ts.floor(), "wf": waterflow, "wt": watertemp, "wl": waterlevel});
      }
    }
    return data;
  }
}

DemoMode demoMode = DemoMode();