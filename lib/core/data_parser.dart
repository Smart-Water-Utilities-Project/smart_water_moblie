import 'package:smart_water_moblie/page/volume/mode_select.dart';

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

class SensorHeadData {
  SensorHeadData({
    required this.maxWf,
    required this.maxWt,
    required this.sumWf,
    required this.startTs,
    required this.endTs
  });

  static SensorHeadData none() => SensorHeadData(
    maxWf: 0,
    maxWt: 0,
    sumWf: 0,
    startTs: DateTime.now(),
    endTs: DateTime.now()
  );

  final double sumWf;
  final double maxWf, maxWt;
  final DateTime? startTs, endTs;
}

class SensorDataParser {
  static (List<SensorDataPack>?, SensorHeadData?) day(List<dynamic>? data, (DateTime, DateTime) range) {
    if (data == null) return (null, null);

    double maxWf = 0, maxWt = 0, sumWf = 0;
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
      sumWf += allNumbers[ts.hour].$2; 
      maxWt = (decoded["wt"] > maxWt) ? decoded["wt"] : maxWt;
    });

    final sensorData = allNumbers.map((key) => SensorDataPack(
      xIndex: key.$1,
      waterflow: key.$2,
      startTs: key.$3,
      endTs: key.$4
    )).toList();
    
    final startTsList = allNumbers.where((i) => i.$3 != null).toList();
    final endTsList = allNumbers.where((i) => i.$4 != null).toList();

    final sensorHeading = SensorHeadData(
      maxWf: maxWf,
      maxWt: maxWt,
      sumWf: sumWf,
      startTs: range.$1,
      endTs: range.$2
    );

    return (sensorData, sensorHeading);
    
  }

  static (List<SensorDataPack>?, SensorHeadData?) week(List<dynamic>? data, (DateTime, DateTime) range) {
    if (data == null) return (null, null);

    final allNumbers = List<(int, double, DateTime?, DateTime?)>.generate(7, (i) => (i, 0.0, null, null));
    double maxWf = 0, maxWt = 0, sumWf = 0;


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
      sumWf += allNumbers[ts.weekday-1].$2; 
      maxWt = (decoded["wt"] > maxWt) ? decoded["wt"] : maxWt;
    });


    final sensorData = allNumbers.map((key) => SensorDataPack(
      xIndex: key.$1,
      waterflow: key.$2,
      startTs: key.$3,
      endTs: key.$4,
    )).toList();
    final sensorHeading = SensorHeadData(
      maxWf: maxWf,
      maxWt: maxWt,
      sumWf: sumWf,
      startTs: range.$1,
      endTs: range.$2
    );

    return (sensorData, sensorHeading);
  }

  static (List<SensorDataPack>?, SensorHeadData?) month(List<dynamic>? data, (DateTime, DateTime) range) {
    if (data == null) return (null, null);
    
    final daysOfMonth = range.$2.day+1;
    double maxWf = 0, maxWt = 0, sumWf = 0;
    final allNumbers = List<(int, double, DateTime?)>.generate(daysOfMonth, (i) => (i, 0.0, null));
    
    data.forEach((decoded) {
      final ts = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);
      final lastValue = allNumbers[ts.day - 1];

      allNumbers[ts.day - 1] = (ts.day, lastValue.$2 + decoded["wf"], ts);
      maxWf = (allNumbers[ts.day - 1].$2 > maxWf) ? allNumbers[ts.day - 1].$2 : maxWf;
      sumWf += allNumbers[ts.day - 1].$2;
      maxWt = (decoded["wt"] > maxWt) ? decoded["wt"] : maxWt;
    });

    final sensorData = allNumbers.map((key) => SensorDataPack(
      xIndex: key.$1,
      waterflow: key.$2,
      startTs: key.$3,
      endTs: key.$3,
    )).toList();

    final sensorHeading = SensorHeadData(
      maxWf: maxWf,
      maxWt: maxWt,
      sumWf: sumWf,
      startTs: range.$1,
      endTs: range.$2
    );

    return (sensorData, sensorHeading);
  }

  static String displayLabel(SensorDataPack data, ShowType type) {
    switch(type) {
      case ShowType.day: 
        return "${data.xIndex} 時";

      case ShowType.week: 
        final List<String> weekDay = ["一", "二", "三", "四", "五", "六", "日"];
        if (data.xIndex < weekDay.length) {
          return "星期${weekDay[data.xIndex]}"; 
        }
        return "星期${data.xIndex}";

      case ShowType.month:
        return "${data.xIndex} 日";
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
