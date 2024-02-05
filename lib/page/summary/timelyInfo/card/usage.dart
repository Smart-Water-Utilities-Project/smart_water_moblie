import 'dart:async';

import 'package:flutter/material.dart';

import 'package:smart_water_moblie/main.dart';
import 'package:smart_water_moblie/page/volume/volume.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/basic.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/indicator.dart';

class UsageCard extends StatefulWidget {
  const UsageCard({super.key});

  @override
  State<UsageCard> createState() => _UsageCardState();
}

class _UsageCardState extends State<UsageCard> {
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    updateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (t) => timelyProvider.updateTimelyUsage()
    );
  }

  @override
  void dispose() {
    super.dispose();
    updateTimer?.cancel();
  }
  
  double getPrettyValue(double val) => (val >= 1000) ? val / 1000 : val;
  String getPrettyUnit(double val) => (val >= 1000) ? "度" : "公升";

  @override
  Widget build(BuildContext context) {
    // final themeData = Theme.of(context);
    
    return ListenableBuilder(
      listenable: timelyProvider,
      builder: (context, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoCard(
            title: '用水量',
            color: Colors.green.shade700,
            icon: SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                size: 25,
                Icons.calendar_today,
                color: Colors.green.shade700,
              )
            ),
            widget: RowIndicator(
              unit: "${getPrettyUnit(timelyProvider.dayUsage)} (日)",
              value: getPrettyValue(timelyProvider.dayUsage),
              fractionDigits: 1,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (contxt) => 
                const WaterValuePage()
              )
            ),
            button: Icon(Icons.arrow_forward_ios,
              size: 25, color: Colors.green.shade700
            )
          )
        ]
      )
    );
  }
}

