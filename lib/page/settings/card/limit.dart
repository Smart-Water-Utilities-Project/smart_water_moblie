import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:smart_water_moblie/core/firebase_msg.dart';
import 'package:smart_water_moblie/core/smart_water_api.dart';
import 'package:smart_water_moblie/main.dart';
import 'package:smart_water_moblie/page/settings/basic.dart';

enum TargetType {
  day,
  month
}

class LimitSection extends StatefulWidget {
  const LimitSection({super.key});

  @override
  State<LimitSection> createState() => _LimitSectionState();
}

class _LimitSectionState extends State<LimitSection> {
  bool enableNotifty = false;
  String? errorMsg = "等待伺服器連線...";
  double dailyValue = 0, monthlyValue = 0;
  final pageController = PageController(initialPage: 0); 
  
  void updateFromServer() async {
    final response = await SmartWaterAPI.instance.getLimit();
    if(!mounted) return;
    if (response.errorMsg != null) {
      dailyValue = 0;
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
    dailyValue = response.value!.$1 / 100;
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
          SectionHeading(
            errorMsg: errorMsg,
            title: "用水目標設定",
            icon: Icons.ads_click,
          ),
          SizedBox(
            width: double.infinity,
            child: ModeSlide(
              backgroundColor: Colors.grey.shade800,
              onChange: (value) {
                pageController.animateToPage(
                  value.index, 
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut
                );
              }
            )
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: mediaQuery.size.width / 3 + 49
            ),
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TargetIndicator(
                  errorMsg: errorMsg,
                  sliderValue: dailyValue,
                  onChanged: (value) => setState(() => dailyValue = value),
                  onChangeEnd: (value) async {
                    await SmartWaterAPI.instance.setLimit(daily: (value*100).ceil());
                    timelyProvider.setTimely(dayLimit: (value*100).ceil());
                  }
                ),
                TargetIndicator(
                  errorMsg: errorMsg,
                  sliderValue: monthlyValue,
                  onChanged: (value) => setState(() => monthlyValue = value),
                  onChangeEnd: (value) async {
                    await SmartWaterAPI.instance.setLimit(monthly: (value*100).ceil());
                    timelyProvider.setTimely(monthLimit: (value*100).ceil());
                  }
                )
              ]
            ),
          ),
          FancySwitch(
            title: "啟用目標通知",
            isEnable: enableNotifty,
            lore: "當用水量接近設定的目標時發送通知",
            onChange: (value) {
              FireBaseAPI.instance.toggleWaterLimitNotify(value)
                .onError((error, stackTrace) => debugPrint("setLimitNotify ERROR"));
              setState(() => enableNotifty = value);
            }
          ),
          const SizedBox(height: 10)
        ]
      )
    );
  }
}

class TargetIndicator extends StatefulWidget {
  const TargetIndicator({
    super.key,
    required this.errorMsg,
    required this.sliderValue,
    this.onChanged,
    this.onChangeEnd
  });

  final double sliderValue;
  final String? errorMsg;
  final Function(double)? onChanged, onChangeEnd;

  @override
  State<TargetIndicator> createState() => _TargetIndicatorState();
}

class _TargetIndicatorState extends State<TargetIndicator> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: mediaQuery.size.width / 3,
                height: mediaQuery.size.width / 3,
                child: CircularIndicator(percent: widget.sliderValue),
              ),
              SizedBox(
                height: mediaQuery.size.width / 3,
                width: mediaQuery.size.width / 3 * 2 - 90,
                child: Center(
                  child: CostsIndicator(percent: widget.sliderValue)
                )
              )
            ]
          )
        ),
        Slider(
          value: widget.sliderValue,
          inactiveColor: Colors.grey,
          onChangeEnd: widget.onChangeEnd,
          onChanged: (widget.errorMsg != null) ? null : widget.onChanged,
        )
      ]
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
  late Animation<Color?> animation;
  late AnimationController controller;
  late MaterialColor lastColor = Colors.blue;
  
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
      ..addListener(() {});
      
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

class ModeSlide extends StatefulWidget {
  const ModeSlide({
    super.key,
    required this.onChange,
    this.backgroundColor
  });
  
  
  final Function(TargetType) onChange;
  final Color? backgroundColor;

  @override
  State<ModeSlide> createState() => _ModeSlideState();
}

class _ModeSlideState extends State<ModeSlide> {
  TargetType selected = TargetType.day;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return CupertinoSlidingSegmentedControl<TargetType>(
      groupValue: selected,
      thumbColor: themeData.colorScheme.secondary,
      backgroundColor: widget.backgroundColor??themeData.inputDecorationTheme.fillColor!,
      children: <TargetType, Widget>{
        TargetType.day: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('每天', style: themeData.textTheme.labelMedium)
        ),
        TargetType.month: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('每月', style: themeData.textTheme.labelMedium)
        )
      },
      onValueChanged: (TargetType? value) {
        value ??= TargetType.day;
        setState(() {
          selected = value!;
        });
        widget.onChange(value);
      }
    );
  }
}