import 'package:flutter/material.dart';
import 'package:smart_water_moblie/appbar.dart';

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
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final barsSpace = 4.0 * mediaQuery.size.width / 400;
    final barsWidth = 8.0 * mediaQuery.size.width / 400;

    final widgetList = [
      SizedBox(height: 0),
      ModeSwitch(),
      WaterflowChart(),
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
          itemCount: widgetList.length,
          itemBuilder:(context, index) => widgetList[index],
          separatorBuilder:(context, index) => const SizedBox(height: 10),
        )
      )
    );
  }
}

