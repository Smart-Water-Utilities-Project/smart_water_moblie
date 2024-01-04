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
      (t) => timelyProvider.updateDayUsage()
    );
  }

  @override
  void dispose() {
    super.dispose();
    updateTimer?.cancel();
  }
  
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
              unit: "公升",
              value: timelyProvider.dayUsage,
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

