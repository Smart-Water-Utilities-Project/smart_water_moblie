import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_water_moblie/core/smart_water_api.dart';
import 'package:smart_water_moblie/core/firebase_msg.dart';
import 'package:smart_water_moblie/page/settings/basic.dart';
import 'package:toastification/toastification.dart';

class LeakageSection extends StatefulWidget {
  const LeakageSection({
    super.key,
  });

  @override
  State<LeakageSection> createState() => LeakageSectionState();
}

class LeakageSectionState extends State<LeakageSection> with AutomaticKeepAliveClientMixin {
  String? errorMsg;
  bool? isVavleOpen;
  bool isNotifyEnable = false;
  ToastificationItem toast = ToastificationItem(
    builder: (_, __) => const SizedBox(),
    alignment: Alignment.bottomCenter
  );

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((instatnce) async {
      isNotifyEnable = instatnce.getBool("isLeakNotifyEnable")??false;
      if(mounted) {setState(() {});}
    });
    updateFromServer();
    SmartWaterAPI.instance.state.addListener(updateFromServer);
  }

  @override
  void dispose() {
    super.dispose();
    SmartWaterAPI.instance.state.removeListener(updateFromServer);
  }

  void updateFromServer() async {
    final response = await SmartWaterAPI.instance.getVavleState();
    if (response.errorMsg != null) {
      isVavleOpen = null;
      setState(() => errorMsg = response.errorMsg);
      return;
    }
    
    errorMsg = null;
    isVavleOpen = response.value!;
    if(mounted) {setState(() {});}
  }

  void processResp(HttpAPIResponse<bool?> resp) {
    if (resp.errorMsg != null) {
      setState(() => isVavleOpen = null);
      toastification.dismiss(toast);
      toast = toastification.show(
        context: context,
        pauseOnHover: true,
        showProgressBar: false,
        title: "${resp.errorMsg}",
        type: ToastificationType.error,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 5),
      );
      return;
    }

    if (!mounted) return;
    setState(() => isVavleOpen = resp.value);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10
      ),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionHeading(
            title: "漏水監測",
            icon: Icons.water_drop,
            errorMsg: errorMsg
          ),
          FancySwitch(
            title: "啟用漏水通知",
            isEnable: isNotifyEnable,
            lore: "當偵測到水流速連續15分鐘沒有歸零時發送通知",
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
              final response = await SmartWaterAPI.instance.setVavleState(value);
              processResp(response);
            }
          ),
          const SizedBox(height: 10)
        ]
      )
    );
  }

  @override
    bool get wantKeepAlive => true;
     
}