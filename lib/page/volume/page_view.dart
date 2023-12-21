import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:smart_water_moblie/core/api.dart';
import 'package:smart_water_moblie/core/data_parser.dart';
import 'package:smart_water_moblie/core/demostrate.dart';
import 'package:smart_water_moblie/page/volume/chart.dart';
import 'package:smart_water_moblie/page/volume/mode_select.dart';
import 'package:smart_water_moblie/page/volume/trend.dart';

class ModePageView extends StatefulWidget {
  const ModePageView({
    super.key,
    required this.showType
  });

  final ShowType showType;
  @override
  State<ModePageView> createState() => ModePageViewState();
}

class ModePageViewState extends State<ModePageView> {
  PageController pageController = PageController();

  void resetPage() {
    if (pageController.positions.isNotEmpty) {
      pageController.jumpToPage(0);
    }
  }

  (DateTime, DateTime) reqDay({int daysOffset = 0}) {
    final now = DateTime.now();

    final startTime = DateTime(now.year, now.month, now.day-daysOffset);
    final endTime = startTime.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    return (startTime, endTime);
  }

  (DateTime, DateTime) reqWeek({int weekOffset = 0}) {
    final now = DateTime.now();

    final startTime = now.subtract(Duration(days: now.weekday + weekOffset*7)).add(const Duration(days: 1));
    final endTime = startTime.add(const Duration(days: 8)).subtract(const Duration(milliseconds: 1));
    
    return (startTime, endTime);
  }

  (DateTime, DateTime) reqMonth({int monthOffset = 0}) {
    final now = DateTime.now();

    final startTime = DateTime(now.year, now.month-monthOffset, 1);
    final endTime = DateTime(now.year, now.month-monthOffset+1, 1).subtract(const Duration(milliseconds: 1));

    return (startTime, endTime);
  }

  (DateTime, DateTime) getTimeRange({int offset=0}) {
    switch (widget.showType) {
      case ShowType.day: return reqDay(daysOffset: offset);
      case ShowType.week: return reqWeek(weekOffset: offset);
      case ShowType.month: return reqMonth(monthOffset: offset);
    }
  }

  Future<Response> fetchData((DateTime, DateTime) range) async {

    final passData = demoMode.chartDemo(timeSet: range);

    if (passData != null) {
      return Response(jsonEncode(passData), 200);
    } else { 
      return HttpAPI.getHistory(range);
    }
  }

  (List<SensorDataPack>?, SensorHeadData?) getData(body, (DateTime, DateTime) range) {
    final event = jsonDecode(body);
    switch(widget.showType) {
      case ShowType.day: 
        return SensorDataParser.day(event, range);
      case ShowType.week: 
        return SensorDataParser.week(event, range);
      case ShowType.month:
        return SensorDataParser.month(event, range);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      reverse: true,
      controller: pageController,
      itemBuilder: (context, index) {
        final range = getTimeRange(offset: index);
        final Future<Response> req = fetchData(range);
        return FutureBuilder(
          future: req, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final data = getData(snapshot.data!.body, range);

              return WaterflowPageView(
                showType: widget.showType,
                timestamps: range, 
                data: data.$1!,
                heading: data.$2!
              );
            }
            
            return Center(
              child: WaterflowPageView(
                showType: widget.showType,
                timestamps: range, 
                data: const [],
                heading: SensorHeadData.none()
              )
            );
          }
        );
      }
    );
  }
}

class WaterflowPageView extends StatefulWidget {
  const WaterflowPageView({
    super.key,
    // required this.data,
    // required this.heading,
    required this.showType,
    required this.timestamps,
    required this.data,
    required this.heading
  });

  // final List<SensorDataPack> data;
  // final SensorHeadData heading;
  
  final ShowType showType;
  final SensorHeadData heading;
  final List<SensorDataPack> data;
  final (DateTime, DateTime) timestamps;

  @override
  State<WaterflowPageView> createState() => _WaterflowPageViewState();
}

class _WaterflowPageViewState extends State<WaterflowPageView> with AutomaticKeepAliveClientMixin{
  final GlobalKey<TrendIndicatorState> trendKey = GlobalKey<TrendIndicatorState>();
  late final StreamSubscription<List<dynamic>> subscription;

  (List<SensorDataPack>?, SensorHeadData?) result = (null, null);

  /*
  void fetchData() {
    debugPrint("called fetch data");
    final passData = demoMode.chartDemo(timeSet: widget.timestamps);

    if (passData != null) {
      WebSocketAPI.chartDataReciever.sink.add(passData);
    } else { WebSocketAPI.instance.getData(widget.timestamps); }
  }*/

  // void setData(event) {
  //   switch(widget.showType) {
  //     case ShowType.day: 
  //       result = SensorDataParser.day(event);
  //       break;
  //     case ShowType.week: 
  //       result = SensorDataParser.week(event);
  //       break;
  //     case ShowType.month:
  //       result = SensorDataParser.month(event, widget.timestamps.$2.day+1);
  //       break;
  //   }
  //   data = result.$1??[];
  //   heading = result.$2??SensorHeadData.none();

  //   setState(() {});
  //   // trendKey.currentState?.refresh();
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // (data.isEmpty) ? Text("空") : Text("${widget.timestamps}"),
          WaterflowChart(
            data: widget.data,
            heading: widget.heading,
            selectedMode: widget.showType
          ),
          TrendIndicator(
            key: trendKey,
            sensorData: widget.data,
            headingData: widget.heading,
          ),
          // TextButton(
          //   child: Text("chk data"),
          //   onPressed: () => print(data.first.startTs),
          // )
        ]
      )
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}