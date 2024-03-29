import 'dart:async';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';

import 'package:smart_water_moblie/main.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/basic.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/indicator.dart';

class LimitCard extends StatefulWidget {
  const LimitCard({super.key});

  @override
  State<LimitCard> createState() => _LimitCardState();
}

class _LimitCardState extends State<LimitCard> {
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double getPrettyValue(double val) => (val >= 1000) ? val / 1000 : val;
  String getPrettyUnit(double val) => (val >= 1000) ? "度" : "公升";

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return ListenableBuilder(
      listenable: timelyProvider,
      builder: (context, child) => InfoCard(
        title: '用水量目標',
        color: Colors.red.shade400,
        icon: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            size: 30,
            Icons.ads_click,
            color: Colors.red.shade400,
          )
        ),
        widget: SizedBox(
          width: mediaQuery.size.width - 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RowIndicator(
                unit: " ${getPrettyUnit(timelyProvider.monthUsage)} (月)",
                fractionDigits: 1,
                value: getPrettyValue(timelyProvider.monthUsage)
              ),
              const Spacer(),
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: AnimatedFlipCounter(
                  value: (timelyProvider.monthLimit == 0) ? 0 :
                    timelyProvider.monthUsage / timelyProvider.monthLimit / 10,
                  suffix: "%",
                  fractionDigits: 1,
                  curve: Curves.easeInOutSine,
                  duration: const Duration(milliseconds: 600),
                  textStyle: themeData.textTheme.titleMedium?.copyWith(
                    overflow: TextOverflow.ellipsis
                  )
                )
              )
            ]
          )
        ),
        // button: const Icon(Icons.more_vert,
        //   size: 27, color: Colors.red
        // ),
        // onTap: () => launchDialog(
        //   context, 500, const TargetSettings()
        // ),
      )
    );
  }
}


