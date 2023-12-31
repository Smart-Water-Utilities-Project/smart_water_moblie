import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

import 'package:smart_water_moblie/core/counter.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/basic.dart';

class TargetCard extends StatefulWidget {
  const TargetCard({super.key});

  @override
  State<TargetCard> createState() => _TargetCardState();
}

class _TargetCardState extends State<TargetCard> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return ListenableBuilder(
      listenable: Controller.level,
      builder: (context, child) => InfoCard(
        title: '水塔儲水量',
        color: Colors.yellow,
        icon: const SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            size: 30,
            Icons.water_damage,
            color: Colors.yellow,
          )
        ),
        widget: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedFlipCounter(
                  fractionDigits: 1,
                  value: Controller.level.value,
                  curve: Curves.easeInOutSine,
                  duration: const Duration(milliseconds: 600),
                  textStyle: themeData.textTheme.titleLarge
                ),
                const Text(
                  " 公升",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey
                  )
                )
              ]
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: mediaQuery.size.width-185),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: WaterBottle(
                    listenable: Controller.level
                  )
                )
              ]
            )
          ]
        )
      )
    );
  }
}

class WaterBottle extends StatefulWidget {
  const WaterBottle({
    super.key,
    required this.listenable
  });

  final CounterModel listenable;
  @override
  State<WaterBottle> createState() => _WaterBottleState();
}

class _WaterBottleState extends State<WaterBottle> {

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return ListenableBuilder(
      listenable: widget.listenable,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constant) {
            final percent = widget.listenable.value / 1000;

            return Container(
              height: constant.maxHeight,
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
                  height: (constant.maxHeight-10) * percent,
                  alignment: Alignment.topCenter,
                  color: Colors.blue,
                  curve: Curves.easeInOutSine,
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    "${(percent*100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  )
                )
              )
            );
          }
        );
      } 
    );
  }
}