import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_water_moblie/appbar.dart';
import 'package:smart_water_moblie/core/data_parser.dart';

import 'package:smart_water_moblie/core/websocket.dart';
import 'package:smart_water_moblie/page/waterflow/chart.dart';
import 'package:smart_water_moblie/page/waterflow/mode_select.dart';

class WaterflowPage extends StatefulWidget {
  WaterflowPage({super.key});

  final Color dark = Colors.black;
  final Color normal = Colors.grey.shade800;
  final Color light = Colors.white;

  @override
  State<WaterflowPage> createState() => _WaterflowPageState();
}

class _WaterflowPageState extends State<WaterflowPage> {
  List<SensorDataPack> data = [];
  ShowType showType = ShowType.day;

  late final ModeSwitch modeSwitch;
  late final StreamSubscription<List<dynamic>> subscription;

  void setData(event) => setState(() {
    switch(showType) {
      case ShowType.day: data = SensorDataParser.day(event);
      case ShowType.week: data = SensorDataParser.week(event);
      case ShowType.month: data = SensorDataParser.month(event, reqMonth().$2.day);
    }
    debugPrint("[DATA_SET] $event");
  });

  (DateTime, DateTime) reqDay() {
    final now = DateTime.now();

    final startTime = DateTime(now.year, now.month, now.day);
    final endTime = startTime.add(const Duration(days: 1));

    return (startTime, endTime);
  }

  (DateTime, DateTime) reqWeek() {
    final now = DateTime.now();

    final startTime = now.subtract(Duration(days: now.weekday));
    final endTime = startTime.add(const Duration(days: 7));
    
    return (startTime, endTime);
  }

  (DateTime, DateTime) reqMonth() {
    final now = DateTime.now();

    final startTime = DateTime(now.year, now.month, 1);
    final endTime = now.month < 12 ? DateTime(now.year, now.month + 1, 0) : DateTime(now.year, 1, 0);
    
    
    return (startTime, endTime);
  }

  @override
  void initState() {
    super.initState();
    subscription = wsAPI.dataRecieveStream.listen(setData);
    modeSwitch = ModeSwitch(
      onChange: (ShowType event) {
        showType = event;

        switch (event) {
          case ShowType.day: wsAPI.getData(reqDay());
          case ShowType.week: wsAPI.getData(reqWeek());
          case ShowType.month: wsAPI.getData(reqMonth());
        }
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
  
  @override
  Widget build(BuildContext context) {
    // final mediaQuery = MediaQuery.of(context);
    // final barsSpace = 4.0 * mediaQuery.size.width / 400;
    // final barsWidth = 8.0 * mediaQuery.size.width / 400;

    final widgetList = [
      const SizedBox(height: 0),
      modeSwitch,
      WaterflowChart(
        maxY: 10,
        data: data
      )
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
          child: GeneralAppBar(
          title: "水流資料",
          appBar: AppBar()
        )
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widgetList.length,
          itemBuilder:(context, index) => widgetList[index],
          separatorBuilder:(context, index) {
            return const SizedBox(height: 10);
          }
        )
      )
    );
  }
}
