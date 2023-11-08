import 'package:flutter/material.dart';

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

    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0),
      body: Column(
        children: [
          ModeSwitch(),
          WaterflowChart()
        ],
      )
    );
  }
}

