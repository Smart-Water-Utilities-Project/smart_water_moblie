import 'dart:async';
import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/demostrate.dart';
import 'package:smart_water_moblie/core/data_parser.dart';
import 'package:smart_water_moblie/page/volume/chart.dart';
import 'package:smart_water_moblie/page/volume/trend.dart';
import 'package:smart_water_moblie/core/smart_water_api.dart';
import 'package:smart_water_moblie/page/volume/mode_select.dart';

class ModePageView extends StatefulWidget {
  const ModePageView({
    super.key,
    required this.showType
  });

  final ShowType showType;
  @override
  State<ModePageView> createState() => ModePageViewState();
}

class ModePageViewState extends State<ModePageView> with AutomaticKeepAliveClientMixin{
  PageController pageController = PageController();

  void resetPage() {
    if (pageController.positions.isNotEmpty) {
      pageController.jumpToPage(0);
    }
  }

  Future<List<dynamic>> fetchData((DateTime, DateTime) range) async {
    final passData = demoMode.chartDemo(timeSet: range);

    if (passData != null) {
      return passData;
    } else { 
      final response = await SmartWaterAPI.instance.getHistory(range);
      return response.value!;
    }
  }

  (List<SensorDataPack>?, SensorHeadData?) getData(List<dynamic> map, (DateTime, DateTime) range) {
    
    switch(widget.showType) {
      case ShowType.day: 
        return SensorDataParser.day(map, range);
      case ShowType.week: 
        return SensorDataParser.week(map, range);
      case ShowType.month:
        return SensorDataParser.month(map, range);
    }
  }

  (DateTime, DateTime) getTimeRange({int offset=0}) {
    switch (widget.showType) {
      case ShowType.day: return Date.reqDay(daysOffset: offset);
      case ShowType.week: return Date.reqWeek(weekOffset: offset);
      case ShowType.month: return Date.reqMonth(monthOffset: offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageView.builder(
      reverse: true,
      controller: pageController,
      itemBuilder: (context, index) {
        final range = getTimeRange(offset: index);
        final req = fetchData(range);
        return FutureBuilder(
          future: req, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final data = getData(snapshot.data??[], range);

              return WaterflowPageView(
                key: const ValueKey<int>(1),
                showType: widget.showType,
                timestamps: range, 
                data: data.$1!,
                heading: data.$2!
              );
            }
            
            return Center(
              child: WaterflowPageView(
                key: const ValueKey<int>(0),
                data: const [],
                timestamps: range, 
                showType: widget.showType,
                heading: SensorHeadData.none()
              )
            );
          }
        );
      }
    );
  }
  
  @override
  bool get wantKeepAlive => true;
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