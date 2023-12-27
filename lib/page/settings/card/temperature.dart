import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_water_moblie/core/firebase_msg.dart';
import 'package:smart_water_moblie/page/settings/basic.dart';

class TempertureSettings extends StatefulWidget {
  const TempertureSettings({super.key});

  @override
  State<TempertureSettings> createState() => _TempertureSettingsState();
}

class _TempertureSettingsState extends State<TempertureSettings> {
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
        color: themeData.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TemperatureHeading(),
          const SizedBox(height: 10),
          FancySwitch(
            title: "啟用結冰通知",
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
        Text("結冰警告")
      ]
    );
  }
}