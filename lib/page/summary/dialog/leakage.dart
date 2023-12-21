import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_water_moblie/core/api.dart';
import 'package:smart_water_moblie/core/firebase_msg.dart';
import 'package:smart_water_moblie/page/summary/dialog/basic.dart';

class WaterLeakage extends StatefulWidget {
  const WaterLeakage({
    super.key,
  });

  @override
  State<WaterLeakage> createState() => WaterLeakageState();
}

class WaterLeakageState extends State<WaterLeakage> {
  bool isNotifyEnable = false;
  bool? isVavleOpen; 

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then(
      (instatnce) async {
        isVavleOpen = await HttpAPI.getVavleState();
        isNotifyEnable = instatnce.getBool("isLeakNotifyEnable")??false;
        if(mounted) {setState(() {});}
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 10
      ),
      decoration: BoxDecoration(
        color: themeData.inputDecorationTheme.fillColor
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NavigationPill(),
          const LeakageHeading(),
          const SizedBox(height: 10),
          FancySwitch(
            title: "啟用結冰通知",
            isEnable: isNotifyEnable,
            lore: "在伺服器偵測到漏水疑慮時發送通知提醒",
            onChange: (value) async {
              setState(() => isNotifyEnable = value);
              final instance = await SharedPreferences.getInstance();
              instance.setBool("isLeakNotifyEnable", value);
              FireBaseAPI.instance.toggleWaterLeakNotify(value);
            },
          ),
          const SizedBox(height: 10),
          FancySwitch(
            title: "開關水閥",
            isEnable: isVavleOpen??false,
            lore: (isVavleOpen==null) ? "與伺服器索取資料時發生錯誤" : "即時控制水塔總水閥的開關",
            onChange: (isVavleOpen == null) ? null : (value) async {
              final resp = await HttpAPI.setVavleState(value);
              if (!mounted) return;
              setState(() => isVavleOpen = resp);
            }
          )
        ]
      )
    );
  }
}

class LeakageHeading extends StatelessWidget {
  const LeakageHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.water_drop, size: 35),
        SizedBox(width: 5),
        Text("漏水監測")
      ]
    );
  }
}