import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_water_moblie/core/firebase_msg.dart';
import 'package:smart_water_moblie/page/summary/dialog/basic.dart';

class TempertureDialog extends StatefulWidget {
  const TempertureDialog({super.key});

  @override
  State<TempertureDialog> createState() => _TempertureDialogState();
}

class _TempertureDialogState extends State<TempertureDialog> {
  bool temperatureCaution = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then(
      (instatnce) {
        temperatureCaution = instatnce.getBool("isIcedEnable")??false;
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const NavigationPill(),
          const TemperatureHeading(),
          const SizedBox(height: 10),
          FancySwitch(
            title: "啟用漏水通知",
            isEnable: temperatureCaution,
            lore: "當偵測到溫度接近水的冰點時發送警告訊息",
            onChange: (value) async {
              final instance = await SharedPreferences.getInstance();
              instance.setBool("isIcedEnable", value);
              FireBaseAPI.instance.toggleWaterLeakNotify(value);
              setState(() => temperatureCaution = value);
            },
          )
        ]
      )
    );
  }
}

class TemperatureHeading extends StatelessWidget {
  const TemperatureHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(CupertinoIcons.thermometer, size: 35),
        SizedBox(width: 5),
        Text("溫度警告")
      ]
    );
  }
}