import 'package:smart_water_moblie/page/waterflow/mode_select.dart';

class SensorDataPack {
  SensorDataPack({
    required this.xIndex,
    required this.waterflow,
    required this.startTs,
    required this.endTs
  });

  final int xIndex;
  final double waterflow;
  final DateTime? startTs, endTs;
}

class SensorDataParser {
  static List<SensorDataPack> day(List<dynamic>? data) {
    if (data == null) return [];

    // List < Hours, Waterflow, start_TS, end_TS>
    final allNumbers = List<(int, double, DateTime?, DateTime?)>
      .generate(23, (i) => (i, 0.0, null, null));

    data.forEach((decoded) {
      DateTime? setStart, setEnd;
      final ts = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);
      final lastValue = allNumbers[ts.hour];
      
      if (ts.isBefore(lastValue.$3 ?? DateTime.now())) { setStart = ts; }
      if (ts.isAfter(lastValue.$4 ?? DateTime.fromMicrosecondsSinceEpoch(0))) { setEnd = ts; }
      print(ts.hour);
      allNumbers[ts.hour] = (
        ts.hour, lastValue.$2 + decoded["wf"], setStart, setEnd
      );
    });

    return allNumbers.map((key) => SensorDataPack(xIndex: key.$1, waterflow: key.$2, startTs: key.$3, endTs: key.$4 )).toList();
  }

  static List<SensorDataPack> week(List<dynamic>? data) {
    if (data == null) return [];

    final allNumbers = List<(int, double)>.generate(7, (i) => (i + 1, 0.0));

    data.forEach((decoded) {
      final ts = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);
      
      final lastValue = allNumbers[ts.weekday - 1];
      allNumbers[ts.weekday - 1] = (ts.weekday, lastValue.$2 + decoded["wf"]);
    });

    final weekDay = ["", "一", "二", "三", "四", "五", "六", "日"];
    
    return [];
    // return allNumbers.map((key) => SensorDataPack(xIndex: key.$1, waterflow: key.$2)).toList();
  }

  static List<SensorDataPack> month(List<dynamic>? data, int daysOfMonth) {
    if (data == null) return [];

    final allNumbers = List<(int, double)>.generate(daysOfMonth, (i) => (i += 1, 0.0));

    data.forEach((decoded) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);

      final lastValue = allNumbers[timestamp.day - 1];
      allNumbers[timestamp.day - 1] = (timestamp.day, lastValue.$2 + decoded["wf"]);
    });

    return [];
    // return allNumbers.map((key) => SensorDataPack(xIndex: key.$1, waterflow: key.$2)).toList();
  }

  static String displayLabel(SensorDataPack data, ShowType type) {
    switch(type) {
      case ShowType.day: 
        return "${data.xIndex} 時";
      case ShowType.week: 
        final weekDay = ["", "一", "二", "三", "四", "五", "六", "日"];
        return "星期${weekDay[0]}";

      case ShowType.month: return "${0} 日";
    }
  }

  static String displayTimeRange(DateTime? start, DateTime? end, ShowType type) {
    if (start == null || end == null) return "無時間資料";
    switch(type) {
      case ShowType.day:
      
        final heading = "${start.year}年${start.month}月${start.day}";
        if (start.minute == end.minute) {return "$heading ${start.hour}時${start.minute}分";}
        return "$heading ${start.hour}時${start.minute}分 至 ${end.hour}時${end.minute}分";

      case ShowType.week: 
        return "";

      case ShowType.month: 
        return "";
    }
  }
}
