import 'dart:async';
import 'package:flutter/material.dart';

import 'package:animated_flip_counter/animated_flip_counter.dart';

import 'package:smart_water_moblie/main.dart';

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
    /*Controller.flow.addListener(flowListener);*/ // ERROR HERE 
    updateTimer = Timer.periodic(const Duration(milliseconds: 750), onUpdate);
  }

  @override
  void dispose() {
    super.dispose();
    /*Controller.flow.removeListener(flowListener);*/ // ERROR HERE 
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
          child: Stack(
            children: [
              const Row(
                children: [
                  SizedBox(width: 5),
                  Icon(Icons.water, size: 35),
                  SizedBox(width: 5),
                  Text("目前流量")
                ]
              ),
              Row(
                children: [
                  const Expanded(
                    child: FlowIndicator()
                  ),
                  WaterBottle(
                    controller: pageController,
                    levelPercent: levelPercent,
                    width: constant.maxWidth / 2.5,
                    height: constant.maxWidth / 2 - 20,
                    duration: const Duration(milliseconds: 750),
                  )
                ]
              )
            ]
          )
        );
      }
    );
  }
}

class FlowIndicator extends StatelessWidget {
  const FlowIndicator({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedFlipCounter(
          value: timelyProvider.flow,
          curve: Curves.easeInOutSine,
          duration: const Duration(milliseconds: 600),
          textStyle: themeData.textTheme.titleLarge
        ),
        const Text(
          " 公升/小時",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey
          )
        )
      ]
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
      width: widget.width,
      child: PageView.builder(
        controller: widget.controller,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final level = (index<widget.levelPercent.floor()+1) ? 1.0 : widget.levelPercent - widget.levelPercent.floor();
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
                height: widget.height * level,
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