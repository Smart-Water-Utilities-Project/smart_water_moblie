import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_water_moblie/main.dart';

import 'package:smart_water_moblie/page/summary/timelyInfo/card/flow.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/limit.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/usage.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/target.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/connect_box.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/temperature.dart';

class TimelyInfo extends StatefulWidget {
  const TimelyInfo({super.key});

  @override
  State<TimelyInfo> createState() => _TimelyInfoState();
}

class _TimelyInfoState extends State<TimelyInfo> {
  Timer? timer;

  // void updateUsage () async => await timelyProvider.updateDayUsage();

  /*@override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) => updateUsage()
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }*/

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("即時資訊", style: themeData.textTheme.titleMedium),
        const ConnectIndicator(),
        LayoutBuilder(
          builder: (context, constant) {
            final width = (constant.maxWidth-10) / 2;
            return ListenableBuilder(
              listenable: timelyProvider,
                builder: (context, child) => Row(
                children: [
                  FlowCard(size: width),
                  const SizedBox(width: 10),
                  TemperatureCard(size: width)
                ]
              )
            );
          }
        ),
        const SizedBox(height: 10),
        const UsageCard(),
        const SizedBox(height: 10),
        const LimitCard(),
        const SizedBox(height: 10),
        const TargetCard(),
      ]
    );
  }
}