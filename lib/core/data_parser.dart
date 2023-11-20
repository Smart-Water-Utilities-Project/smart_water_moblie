import 'package:smart_water_moblie/page/waterflow/mode_select.dart';

class SensorDataPack {
  SensorDataPack({
    required this.xIndex,
    required this.waterflow,
    required this.startTs,
    required this.endTs,
    required this.maxWf,
    required this.maxWt
  });

  final int xIndex;
  final double waterflow;
  final DateTime? startTs, endTs;
  final double maxWf, maxWt;

}

class SensorDataParser {
  static List<SensorDataPack> day(List<dynamic>? data) {
    if (data == null) return [];

    double maxWf = 0, maxWt = 0;
    final allNumbers = List<(int, double, DateTime?, DateTime?)>.generate(
      24, (i) => (i, 0.0, null, null)
    );

    data.forEach((decoded) {
      final ts = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);
      final lastValue = allNumbers[ts.hour];
      DateTime? setStart=lastValue.$3, setEnd=lastValue.$4;
      
      if (ts.isBefore(lastValue.$3 ?? DateTime.now().add(const Duration(days: 365)))) {
        setStart = ts;
      }
      if (ts.isAfter(lastValue.$4 ?? DateTime.fromMicrosecondsSinceEpoch(0))) {
        setEnd = ts;
      }

      allNumbers[ts.hour] = (
        ts.hour, lastValue.$2 + decoded["wf"], setStart, setEnd
      );

      maxWf = (allNumbers[ts.hour].$2 > maxWf) ? allNumbers[ts.hour].$2 : maxWf;
      maxWt = (decoded["wt"] > maxWt) ? decoded["wt"] : maxWt;
    });

    return allNumbers.map((key) => SensorDataPack(
      xIndex: key.$1,
      waterflow: key.$2,
      startTs: key.$3,
      endTs: key.$4,
      maxWf: maxWf,
      maxWt: maxWt
    )).toList();
  }

  static List<SensorDataPack> week(List<dynamic>? data) {
    if (data == null) return [];

    final allNumbers = List<(int, double, DateTime?, DateTime?)>.generate(7, (i) => (i, 0.0, null, null));
    double maxWf = 0, maxWt = 0;

    data.forEach((decoded) {
      final ts = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);
      final lastValue = allNumbers[ts.weekday - 1];
      DateTime? setStart=lastValue.$3, setEnd=lastValue.$4;
      
      if (ts.isBefore(lastValue.$3 ?? DateTime.now())) {
        setStart = ts;
      }
      if (ts.isAfter(lastValue.$4 ?? DateTime.fromMicrosecondsSinceEpoch(0))) {
        setEnd = ts;
      }

      allNumbers[ts.weekday - 1] = (lastValue.$1, lastValue.$2 + decoded["wf"], setStart, setEnd);

      maxWf = (allNumbers[ts.weekday-1].$2 > maxWf) ? allNumbers[ts.weekday-1].$2 : maxWf;
      maxWt = (decoded["wt"] > maxWt) ? decoded["wt"] : maxWt;
    });

    // final List<String> weekDay = ["", "一", "二", "三", "四", "五", "六", "日"];
    
    return allNumbers.map((key) => SensorDataPack(
      xIndex: key.$1,
      waterflow: key.$2,
      startTs: key.$3,
      endTs: key.$4,
      maxWf: maxWf,
      maxWt: maxWt,
    )).toList();
  }

  static List<SensorDataPack> month(List<dynamic>? data, int daysOfMonth) {
    if (data == null) return [];

    double maxWf = 0, maxWt = 0;
    final allNumbers = List<(int, double, DateTime?)>.generate(daysOfMonth, (i) => (i, 0.0, null));
    
    data.forEach((decoded) {
      final ts = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);

      final lastValue = allNumbers[ts.day];
      allNumbers[ts.day] = (ts.day, lastValue.$2 + decoded["wf"], ts);

      maxWf = (allNumbers[ts.day].$2 > maxWf) ? allNumbers[ts.day].$2 : maxWf;
      maxWt = (decoded["wt"] > maxWt) ? decoded["wt"] : maxWt;
    });

    return allNumbers.map((key) => SensorDataPack(
      xIndex: key.$1,
      waterflow: key.$2,
      startTs: key.$3,
      endTs: key.$3,
      maxWf: maxWf,
      maxWt: maxWt
    )).toList();
  }

  static String displayLabel(SensorDataPack data, ShowType type) {
    switch(type) {
      case ShowType.day: 
        return "${data.xIndex} 時";

      case ShowType.week: 
        final List<String> weekDay = ["一", "二", "三", "四", "五", "六", "日"];
        return "星期${weekDay[data.xIndex]}";

      case ShowType.month:
        return "${data.xIndex+1} 日";
    }
  }

  static String displayTimeRange(SensorDataPack data, ShowType type) {
    if (data.startTs == null || data.endTs == null) {
      return "無時間資料";
    }

    switch(type) {
      case ShowType.day:
        final String heading = "${data.startTs!.year}年${data.startTs!.month}月${data.startTs!.day}";

        if (data.startTs!.minute == data.endTs!.minute) {
          return "${data.startTs!.hour}時${data.startTs!.minute}分";
        }

        return "${data.startTs!.hour}時${data.startTs!.minute}分 至 ${data.endTs!.hour}時${data.endTs!.minute}分";

      case ShowType.week:
        return "${data.startTs!.year}年${data.startTs!.month}月${data.startTs!.day}日";

      case ShowType.month: 
        return "${data.startTs!.year}年${data.startTs!.month}月${data.startTs!.day}日";
    }
  }
}
