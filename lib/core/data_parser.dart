import 'package:smart_water_moblie/page/volume/mode_select.dart';

class SensorDataPack {
  SensorDataPack({
    required this.xIndex,
    this.wUsage = 0,
    this.wTemp = 0,
    this.startTS,
    this.endTS
  });

  final int xIndex;

  // Water temperature average, max and min usage
  double wTemp, maxWTemp=double.negativeInfinity, minWTemp=double.infinity;

  double wUsage; // Water usage sum 
    
  double maxWUsage=double.negativeInfinity;

  int _wTempDataCount = 0, _allDataCount = 0;
  
  DateTime? startTS, endTS;

  int get length => _allDataCount;
  int get tempLength => _wTempDataCount;

  void update({
    DateTime? timestamp,
    double? waterUsage,
    double? waterTemp
  }) {
    _allDataCount += 1;

    if (timestamp != null) { // Process timestamp update procedure
      // If dataTS is earlier than startTS than replace
      if (timestamp.isBefore(startTS ?? DateTime.now().add(const Duration(days: 365)))) { startTS = timestamp; }

      // If dataTS is later than endTs than replace
      if (timestamp.isAfter(endTS ?? DateTime.fromMicrosecondsSinceEpoch(0))) { endTS = timestamp; }
    }

    if (waterUsage != null) {
      wUsage += waterUsage;
      maxWUsage = (waterUsage > maxWUsage) ? waterUsage : maxWUsage;
    }

    if (waterTemp != null) {
      wTemp = (waterTemp * _wTempDataCount + waterTemp) / (_wTempDataCount+1);
      maxWTemp = (waterTemp > maxWTemp) ? waterTemp : maxWTemp;
      minWTemp = (waterTemp < minWTemp) ? waterTemp : minWTemp;

      _wTempDataCount += 1;
    }
  }
}

class SensorHeadData {
  SensorHeadData({
    this.maxWf = 0,
    this.maxWt = 0,
    this.sumWf = 0,
    this.aveWt = 0,
    required this.startTs,
    required this.endTs
  });

  final double sumWf;
  final double maxWf, maxWt;
  final double aveWt;
  final DateTime? startTs, endTs;

  static SensorHeadData none() => SensorHeadData(
    maxWf: 0,
    maxWt: 0,
    sumWf: 0,
    aveWt: 0,
    startTs: DateTime.now(),
    endTs: DateTime.now()
  );

  static SensorHeadData fromPackList(List<SensorDataPack> data) {
    double sumWf=0, maxWf=0;
    double sumWt=0, maxWt=double.negativeInfinity, minWt=double.infinity;
    DateTime? startTS, endTS;

    int tempDataLength=0;
    
    data.forEach((element) {
      
      // Water flow handling
      sumWf += element.wUsage;
      maxWf = (element.wUsage > maxWf) ? element.wUsage : maxWf;

      // Water temp handling
      sumWt += element.wTemp * element.tempLength;
      maxWt = (element.wTemp > maxWt) ? element.wTemp : maxWt;
      minWt = (element.wTemp < minWt) ? element.wTemp : minWt;
      tempDataLength += element.tempLength;

      if (element.startTS == null || element.endTS == null) return;
      if (element.startTS!.isBefore(startTS ?? DateTime.now().add(const Duration(days: 365)))) { startTS = element.startTS; }
      if (element.endTS!.isAfter(endTS ?? DateTime.fromMicrosecondsSinceEpoch(0))) { endTS = element.endTS; }

    });

    return SensorHeadData(
      sumWf: sumWf,
      maxWf: maxWf,
      maxWt: maxWt,
      aveWt: sumWt / tempDataLength ,
      startTs: startTS,
      endTs: endTS,
    );
  }

}

class SensorDataParser {
  static (List<SensorDataPack>?, SensorHeadData?) day(List<dynamic>? data, (DateTime, DateTime) range) {
    if (data == null) return (null, null);

    double maxWf = 0, maxWt = 0, sumWf = 0;
    // final allNumbers = List<(int, double, DateTime?, DateTime?)>.generate(
    //   24, (i) => (i, 0.0, null, null)
    // );

    final sensorData = List<SensorDataPack>.generate(
      24, (i) => SensorDataPack(xIndex: i)
    );

    data.forEach((decoded) {
      // Get timestamp from currnet data
      final dataTS = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);
      sensorData[dataTS.hour].update(
        timestamp: dataTS,
        waterTemp: decoded["wt"],
        waterUsage: decoded["wf"]
      );

      /*// Get timestamp from map stored data
      final storedTS = allNumbers[dataTS.hour];
      DateTime? startTS=storedTS.$3, endTS=storedTS.$4;

      if (dataTS.isBefore(storedTS.$3 ?? DateTime.now().add(const Duration(days: 365)))) {
        startTS = dataTS; // If dataTS is earlier than startTS than replace
      }
 
      if (dataTS.isAfter(storedTS.$4 ?? DateTime.fromMicrosecondsSinceEpoch(0))) {
        endTS = dataTS; // If dataTS is later than endTs than replace 
      }

      allNumbers[dataTS.hour] = (dataTS.hour, storedTS.$2 + decoded["wf"], startTS, endTS);
      
      maxWf = (allNumbers[dataTS.hour].$2 > maxWf) ? allNumbers[dataTS.hour].$2 : maxWf;
      sumWf += allNumbers[dataTS.hour].$2; 
      maxWt = (decoded["wt"] > maxWt) ? decoded["wt"] : maxWt; 
      */
    });

    /*final sensorData = allNumbers.map((key) => SensorDataPack(
      xIndex: key.$1,
      wUsage: key.$2,
      startTS: key.$3,
      endTS: key.$4
    )).toList();*/
    
    // final startTsList = allNumbers.where((i) => i.$3 != null).toList();
    // final endTsList = allNumbers.where((i) => i.$4 != null).toList();

    /*final sensorHeading = SensorHeadData(
      maxWf: maxWf,
      maxWt: maxWt,
      sumWf: sumWf,
      startTs: range.$1,
      endTs: range.$2
    );*/

    final sensorHeading = SensorHeadData.fromPackList(sensorData);

    return (sensorData, sensorHeading);
    
  }

  static (List<SensorDataPack>?, SensorHeadData?) week(List<dynamic>? data, (DateTime, DateTime) range) {
    if (data == null) return (null, null);

    // final allNumbers = List<(int, double, DateTime?, DateTime?)>.generate(7, (i) => (i, 0.0, null, null));
    double maxWf = 0, maxWt = 0, sumWf = 0;

    final sensorData = List<SensorDataPack>.generate(7, (i) => SensorDataPack(xIndex: i));

    data.forEach((decoded) {
      final dataTS = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);
      sensorData[dataTS.weekday - 1].update(
        timestamp: dataTS,
        waterUsage: decoded["wf"],
        waterTemp: decoded["wt"]
      );
      /*
      final lastValue = allNumbers[dataTS.weekday - 1];
      DateTime? setStart=lastValue.$3, setEnd=lastValue.$4;
      
      if (dataTS.isBefore(lastValue.$3 ?? DateTime.now())) {
        setStart = dataTS;
      }
      if (dataTS.isAfter(lastValue.$4 ?? DateTime.fromMicrosecondsSinceEpoch(0))) {
        setEnd = dataTS;
      }

      allNumbers[dataTS.weekday - 1] = (lastValue.$1, lastValue.$2 + decoded["wf"], setStart, setEnd);

      maxWf = (allNumbers[dataTS.weekday-1].$2 > maxWf) ? allNumbers[dataTS.weekday-1].$2 : maxWf;
      sumWf += allNumbers[dataTS.weekday-1].$2; 
      maxWt = (decoded["wt"] > maxWt) ? decoded["wt"] : maxWt;*/
    });


    /*final sensorData = allNumbers.map((key) => SensorDataPack(
      xIndex: key.$1,
      wUsage: key.$2,
      startTS: key.$3,
      endTS: key.$4,
    )).toList();
    final sensorHeading = SensorHeadData(
      maxWf: maxWf,
      maxWt: maxWt,
      sumWf: sumWf,
      startTs: range.$1,
      endTs: range.$2
    );*/

    return (sensorData, SensorHeadData.fromPackList(sensorData));
  }

  static (List<SensorDataPack>?, SensorHeadData?) month(List<dynamic>? data, (DateTime, DateTime) range) {
    if (data == null) return (null, null);
    
    final daysOfMonth = range.$2.day+1;
    // double maxWf = 0, maxWt = 0, sumWf = 0;
    // final allNumbers = List<(int, double, DateTime?)>.generate(daysOfMonth, (i) => (i, 0.0, null));
    
    final sensorData = List<SensorDataPack>.generate(daysOfMonth, (i) => SensorDataPack(xIndex: i));
    data.forEach((decoded) {
      final dataTS = DateTime.fromMillisecondsSinceEpoch((decoded["t"] as int) * 60 * 1000);
      sensorData[dataTS.day - 1].update(
        timestamp: dataTS,
        waterUsage: decoded["wf"],
        waterTemp: decoded["wt"]
      );

      /*final lastValue = allNumbers[dataTS.day - 1];

      allNumbers[dataTS.day - 1] = (dataTS.day, lastValue.$2 + decoded["wf"], dataTS);
      maxWf = (allNumbers[dataTS.day - 1].$2 > maxWf) ? allNumbers[dataTS.day - 1].$2 : maxWf;
      sumWf += allNumbers[dataTS.day - 1].$2;
      maxWt = (decoded["wt"] > maxWt) ? decoded["wt"] : maxWt;*/
    });

    /*final sensorData = allNumbers.map((key) => SensorDataPack(
      xIndex: key.$1,
      wUsage: key.$2,
      startTS: key.$3,
      endTS: key.$3,
    )).toList();

    final sensorHeading = SensorHeadData(
      maxWf: maxWf,
      maxWt: maxWt,
      sumWf: sumWf,
      startTs: range.$1,
      endTs: range.$2
    );*/

    return (sensorData, SensorHeadData.fromPackList(sensorData));
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
    if (data.startTS == null || data.endTS == null) {
      return "無時間資料";
    }

    switch(type) {
      case ShowType.day:
        // final String heading = "${data.startTs!.year}年${data.startTs!.month}月${data.startTs!.day}";

        if (data.startTS!.minute == data.endTS!.minute) {
          return "${data.startTS!.hour}時${data.startTS!.minute}分";
        }

        return "${data.startTS!.hour}時${data.startTS!.minute}分 至 ${data.endTS!.hour}時${data.endTS!.minute}分";

      case ShowType.week:
        return "${data.startTS!.year}年${data.startTS!.month}月${data.startTS!.day}日";

      case ShowType.month: 
        return "${data.startTS!.year}年${data.startTS!.month}月${data.startTS!.day}日";
    }
  }
}
