import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_water_moblie/main.dart';

import 'package:smart_water_moblie/page/summary/timelyInfo/card/basic.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/indicator.dart';
import 'package:smart_water_moblie/page/settings/card/temperature.dart';
import 'package:smart_water_moblie/page/settings/basic.dart';

class TemperatureCard extends StatefulWidget {
  const TemperatureCard({
    super.key,
    required this.size
  });

  final double size;
  @override
  State<TemperatureCard> createState() => _TemperatureCardState();
}

class _TemperatureCardState extends State<TemperatureCard> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: InfoCard(
        title: '水溫',
        iconPadding: false,
        color: Colors.orange,
        icon: const SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            Icons.water,
            size: 30,
            color: Colors.orange
          )
        ),
        widget: Expanded(
          child: ColumnIndicator(
            unit: "攝氏度",
            value: timelyProvider.temp,
          )
        ),
        // onTap: () => launchDialog(
        //   context, 200, const TempertureSettings()
        // ),
        // button: const Icon(Icons.more_horiz,
        //   size: 27, color: Colors.orange
        // )
      )
    );

  }
}

class CurrentFlow extends StatefulWidget {
  const CurrentFlow({
    super.key,
    required this.bottleMaxVolume
  });

  final double bottleMaxVolume;
  @override
  State<CurrentFlow> createState() => CurrentFlowState();
}


class CurrentFlowState extends State<CurrentFlow> {
  Timer? updateTimer;
  double levelPercent = 0, currentFlow = 0;
  final pageController = PageController(initialPage: 1);

  void flowListener() {
    // Convert value from L/Hr to ml/sec 
    currentFlow = timelyProvider.flow*1000/3600;
  }

  void onUpdate(Timer timer) {
    if (!mounted) timer.cancel();
    addVolume(currentFlow/widget.bottleMaxVolume*0.75);
  }

  @override
  void initState() {
    super.initState();
    // propertyProvider.addListener(flowListener); ERROE HERE
    updateTimer = Timer.periodic(const Duration(milliseconds: 750), onUpdate);
  }

  @override
  void dispose() {
    super.dispose();
    // propertyProvider.removeListener(flowListener); ERROR HERE
  }

  void addVolume(double value) async {
    final scrollIndex = (levelPercent+value).floor() + 1;
    final switchPage = levelPercent-levelPercent.floor() + value >= 1;
    
    if(!mounted) return; 
    setState(() => levelPercent += value);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted && !switchPage) return;
    pageController.animateToPage(
      scrollIndex,
      curve: Curves.easeInOutSine,
      duration: const Duration(milliseconds: 250)
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constant) {
        return Container(
          height: constant.maxWidth / 2,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: themeData.inputDecorationTheme.fillColor
          ),
          child: WaterBottle(
            controller: pageController,
            levelPercent: levelPercent,
            width: constant.maxWidth / 2.5,
            height: 100,
            duration: const Duration(milliseconds: 750),
          )
        );
      }
    );
  }
}



class WaterBottle extends StatefulWidget {
  const WaterBottle({
    super.key,
    required this.levelPercent,
    required this.duration,
    required this.height,
    required this.width,
    required this.controller
  });

  final Duration duration;
  final double width, height, levelPercent;
  final PageController controller;
  @override
  State<WaterBottle> createState() => _WaterBottleState();
}

class _WaterBottleState extends State<WaterBottle> {

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: PageView.builder(
        controller: widget.controller,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final level = (index<widget.levelPercent.floor()+1) ? 
            1.0 : widget.levelPercent - widget.levelPercent.floor();
          return Container(
            height: widget.height,
            margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
              ),
              border: Border(
                right: BorderSide(
                  color: Colors.grey.shade800, width: 3.0,
                ),
                left: BorderSide(
                  color: Colors.grey.shade800, width: 3.0,
                ),
                bottom: BorderSide(
                  color: Colors.grey.shade800, width: 3.0,
                )
              )
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(7),
                bottomRight: Radius.circular(7)
              ),
              child: AnimatedContainer(
                width: mediaQuery.size.width,
                height: (widget.height - 13) * level,
                alignment: Alignment.topCenter,
                color: Colors.blue,
                curve: Curves.easeInOutSine,
                duration: widget.duration,
                child: Text(
                  "${(level*100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  )
                )
              )
            )
          );
        }
      )
    );
  }
}