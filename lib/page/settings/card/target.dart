import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/firebase_msg.dart';
import 'package:smart_water_moblie/core/smart_water_api.dart';
import 'package:smart_water_moblie/page/settings/basic.dart';

class TargetSettings extends StatefulWidget {
  const TargetSettings({super.key});

  @override
  State<TargetSettings> createState() => _TargetSettingsState();
}

class _TargetSettingsState extends State<TargetSettings> {
  String? errorMsg = "等待伺服器連線...";
  double sliderValue = 0;
  bool enableNotifty = false;
  
  void updateFromServer() async {
    final response = await SmartWaterAPI.instance.getTarget();
    if(!mounted) return;
    if (response.errorMsg != null) {
      sliderValue = 0;
      errorMsg = response.errorMsg;
      setState(() => errorMsg=response.errorMsg);
      return;
    }

    errorMsg = null;
    response.value = (
      (response.value!.$1 < 0) ? 0 : response.value!.$1,
      (response.value!.$2 < 0) ? 0 : response.value!.$2
    );

    // print(response.value);
    sliderValue = response.value!.$1 / 100;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateFromServer();
    SmartWaterAPI.instance.state.addListener(updateFromServer);
  }

  @override
  void dispose() {
    super.dispose();
    SmartWaterAPI.instance.state.removeListener(updateFromServer);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TargetHeading(
            errorMsg: errorMsg
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: mediaQuery.size.width / 3,
                  height: mediaQuery.size.width / 3,
                  child: CircularIndicator(percent: sliderValue),
                ),
                const Spacer(),
                SizedBox(
                  height: mediaQuery.size.width / 3,
                  child: CostsIndicator(percent: sliderValue)
                )
              ]
            )
          ),
          Slider(
            value: sliderValue,
            inactiveColor: Colors.grey,
            onChanged: (errorMsg != null) ? null : (value) {
              setState(() => sliderValue = value);
            },
            onChangeEnd: (value) async {
              SmartWaterAPI.instance.setTarget(
                daily: (value*100).ceil()
              );
            },
          ),
          FancySwitch(
            title: "啟用目標通知",
            isEnable: enableNotifty,
            lore: "當用水量接近設定的目標時發送通知",
            onChange: (value) {
              FireBaseAPI.instance.toggleWaterLimitNotify(value)
                .onError((error, stackTrace) => print("setLimitNotify ERROR"));
              setState(() => enableNotifty = value);
            }
          ),
          const SizedBox(height: 10)
        ]
      )
    );
  }
}

class CostsIndicator extends StatelessWidget {
  const CostsIndicator({
    super.key,
    required this.percent
  });

  final double percent;

  int getCosts() {
    final usageL = (percent*100).ceil(); // Water usage in L

    if (usageL <= 10.0) return (usageL*7.35 - 0).round();
    if (usageL <= 30.0) return (usageL*9.45 - 21).round();
    if (usageL <= 50) return (usageL*11.55 - 84).round();

    return (usageL*12.075 - 110.25).round();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "預計水費", style: themeData.textTheme.titleSmall),
              const TextSpan(text: " "),
              TextSpan(text: "(每月)", style: themeData.textTheme.bodySmall?.copyWith(
                fontSize: 14,
                color: Colors.grey
              ))
            ]
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Text("NT${getCosts()}", style: themeData.textTheme.labelLarge?.copyWith(
            fontSize: 40
          ))
        )
      ]
    );
  }
}

class CircularIndicator extends StatefulWidget {
  const CircularIndicator({
    super.key,
    required this.percent,
  });

  final double percent;

  @override
  State<CircularIndicator> createState() => _CircularIndicatorState();
}

class _CircularIndicatorState extends State<CircularIndicator> with SingleTickerProviderStateMixin {
  late MaterialColor lastColor = Colors.blue;
  late Animation<Color?> animation;
  late AnimationController controller;
  
  void setStateSafe() => {if (mounted) {setState(() {})}};

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    animation =
      ColorTween(begin: Colors.blue, end: Colors.blue).animate(controller)
        ..addListener(setStateSafe);
  }

  @override
  void dispose() {
    super.dispose();
    animation.removeListener(setStateSafe);
  }
  
  void colorAnimate(MaterialColor end) {
    if (lastColor == end) return;
    controller.value = (0);
    animation = ColorTween(begin: lastColor, end: end).animate(controller)
      ..addListener(() {
        
      });
      
    controller.forward();
  }

  MaterialColor getColor() {
    final usageL = (widget.percent*100).ceil(); // Water usage in L
    if (usageL <= 10.0) {
      colorAnimate(Colors.blue);
      return Colors.blue;
    }
    if (usageL <= 30.0) {
      colorAnimate(Colors.yellow);
      return Colors.yellow;
    }
    if (usageL <= 50) {
      colorAnimate(Colors.orange);
      return Colors.orange;
    }

    colorAnimate(Colors.red);
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    lastColor = getColor();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CircularProgressIndicator(
              strokeAlign: 1,
              strokeWidth: 10,
              valueColor: animation,
              value: widget.percent,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.grey,
            )
          )
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(((widget.percent*100).ceil()).toStringAsFixed(0),
              style: themeData.textTheme.titleLarge),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
              child: Text("度/月", style: themeData.textTheme.labelMedium?.copyWith(
                color: Colors.grey
              )),
            )
          ]
        )
      ]
    );
  }
}

class TargetHeading extends StatelessWidget {
  const TargetHeading({
    super.key,
    required this.errorMsg
  });

  final String? errorMsg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.ads_click, size: 35),
        const SizedBox(width: 5),
        const Text("用水目標設定"),
        const Spacer(),
        WarnningButton(errorMsg: errorMsg)
      ]
    );
  }
}