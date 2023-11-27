import 'package:flutter/material.dart';

import 'package:smart_water_moblie/appbar.dart';
import 'package:smart_water_moblie/page/waterflow/page_view.dart';
import 'package:smart_water_moblie/page/waterflow/mode_select.dart';

class WaterflowPage extends StatefulWidget {
  WaterflowPage({super.key});

  final Color dark = Colors.black;
  final Color light = Colors.white;
  final Color normal = Colors.grey.shade800;

  @override
  State<WaterflowPage> createState() => _WaterflowPageState();
}

class _WaterflowPageState extends State<WaterflowPage> {

  PageController pageController = PageController();
  List<GlobalKey<ModePageViewState>> indexKeys = [
    GlobalKey<ModePageViewState>(),
    GlobalKey<ModePageViewState>(),
    GlobalKey<ModePageViewState>()
  ]; // Use to reset child pageview to index 0
  
  void onSwitchChange(ShowType event) {
    pageController.animateToPage(
      event.index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutSine
    );
    setState(() {});
  }

  void onDoubleClick(ShowType event) {
    indexKeys[event.index].currentState?.resetPage();
  }

  // (DateTime, DateTime) reqDay({int daysOffset = 0}) {
  //   final now = DateTime.now();

  //   final startTime = DateTime(now.year, now.month, now.day-daysOffset);
  //   final endTime = startTime.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

  //   return (startTime, endTime);
  // }

  // (DateTime, DateTime) reqWeek({int weekOffset = 0}) {
  //   final now = DateTime.now();

  //   final startTime = now.subtract(Duration(days: now.weekday + weekOffset*7)).add(const Duration(days: 1));
  //   final endTime = startTime.add(const Duration(days: 8)).subtract(const Duration(milliseconds: 1));
    
  //   return (startTime, endTime);
  // }

  // (DateTime, DateTime) reqMonth({int monthOffset = 0}) {
  //   final now = DateTime.now();

  //   final startTime = DateTime(now.year, now.month-monthOffset, 1);
  //   final endTime = DateTime(now.year, now.month-monthOffset+1, 1).subtract(const Duration(milliseconds: 1));

  //   return (startTime, endTime);
  // }

  // (DateTime, DateTime) getTimeRange({int offset=0}) {
  //   switch (showType) {
  //     case ShowType.day: return reqDay(daysOffset: offset);
  //     case ShowType.week: return reqWeek(weekOffset: offset);
  //     case ShowType.month: return reqMonth(monthOffset: offset);
  //   }
  // }

  // Future<Response> fetchData((DateTime, DateTime) range) async {

  //   final passData = demoMode.chartDemo(timeSet: range);

  //   if (passData != null) {
  //     return Response(jsonEncode(passData), 200);
  //   } else { 
  //     return HttpAPI.instance.getData(range);
  //   }
  // }

  // (List<SensorDataPack>?, SensorHeadData?) getData(body, (DateTime, DateTime) range) {
  //   final event = jsonDecode(body);
  //   switch(showType) {
  //     case ShowType.day: 
  //       return SensorDataParser.day(event, range);
  //     case ShowType.week: 
  //       return SensorDataParser.week(event, range);
  //     case ShowType.month:
  //       return SensorDataParser.month(event, range);
  //   }

  //   // trendKey.currentState?.refresh();
  // }

  @override
  void initState() {
    super.initState();
    // onSwitchChange(ShowType.day);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // final barsSpace = 4.0 * mediaQuery.size.width / 400;
    // final barsWidth = 8.0 * mediaQuery.size.width / 400;
  
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
          child: GeneralAppBar(
          title: "水流資料",
          appBar: AppBar()
        )
      ),
      body: Column(
        children: [
          SizedBox(height: 50 + mediaQuery.viewPadding.top),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ModeSwitch(
              onChange: onSwitchChange
            )
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              scrollBehavior: const ScrollBehavior(),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ModePageView(
                  key: indexKeys[0],
                  showType: ShowType.day
                ),
                ModePageView(
                  key: indexKeys[1],
                  showType: ShowType.week
                ),
                ModePageView(
                  key: indexKeys[2],
                  showType: ShowType.month
                )
              ]
            )
          )
        ]
      )
    );
  }
}

