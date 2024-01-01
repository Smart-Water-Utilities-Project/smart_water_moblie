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
                unit: " 公升",
                fractionDigits: 1,
                value: timelyProvider.level
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Text("0.1%", style: themeData.textTheme.titleMedium),
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


