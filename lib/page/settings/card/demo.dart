import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_water_moblie/core/demostrate.dart';
import 'package:smart_water_moblie/core/firebase_msg.dart';
import 'package:smart_water_moblie/page/settings/basic.dart';

class DemoSection extends StatefulWidget {
  const DemoSection({super.key});

  @override
  State<DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<DemoSection> {
  bool serverTestNotify = false;

  @override
  void initState() {
    super.initState();
  }

  void loadValue() async {
    final instance = await SharedPreferences.getInstance();
    serverTestNotify = instance.getBool("isDevNotifyEnable")??false;

    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10 ,10),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.remove_red_eye_sharp, size: 35),
              SizedBox(width: 5),
              Text("展示模式")
            ],
          ),
          const SizedBox(height: 5),
          Column(
            children: [
              FancySwitch(
                title: "即時資訊",
                isEnable: demoMode.timely,
                lore: "此功能可以在用程式首頁面產生隨機資料",
                onChange: (value) async {
                  await demoMode.setTimely(value);
                  setState(() {});
                }
              ),
              FancySwitch(
                title: "圖表資訊",
                isEnable: demoMode.waterflow,
                lore: "此功能可以在用水資訊頁面產生隨機資料",
                onChange: (value) async {
                  await demoMode.setWaterflow(value);
                  setState(() {});
                }
              ),
              FancySwitch(
                title: "測試通知",
                isEnable: serverTestNotify,
                onChange: (value) async {
                  FireBaseAPI.instance.toggleDevTestNotify(value);
                  setState(() => serverTestNotify = value);
                },
                lore: "啟用此功能可以接收伺服器的測試通知",
              )
            ]
          )
        ],
      ),
    );
  }
}