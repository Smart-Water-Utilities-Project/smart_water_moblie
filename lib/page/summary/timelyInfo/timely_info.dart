import 'package:flutter/material.dart';

import 'package:smart_water_moblie/page/summary/timelyInfo/card/flow.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/limit.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/temperature.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/usage.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/target.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/connect_box.dart';

class TimelyInfo extends StatelessWidget {
  const TimelyInfo({super.key});

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
            return Row(
              children: [
                FlowCard(size: width),
                const SizedBox(width: 10),
                TemperatureCard(size: width)
              ]
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