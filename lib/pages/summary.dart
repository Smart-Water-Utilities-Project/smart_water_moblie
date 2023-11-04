import 'package:flutter/material.dart';
import 'package:animated_digit/animated_digit.dart';

import 'package:smart_water_moblie/pages/settings.dart';
import 'package:smart_water_moblie/info_card/info_card.dart';

import 'dart:async';
import 'dart:math';

final sumController = AnimatedDigitController(0);
final flowController = AnimatedDigitController(0);
final tempController = AnimatedDigitController(0);

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {

  List<Widget> cardList = [
    InfoCard(
      title: '流量',
      color: Colors.cyan.shade700,
      icon: SizedBox(
        width: 30, height: 30,
        child: Icon(
          size: 30,
          Icons.water,
          color: Colors.cyan.shade700
        )
      ),
      textSpan: [
        AnimatedDigitWidget(
          controller: flowController,
          textStyle: const TextStyle(
            fontSize: 40,
            color: Colors.white,
          )
        ),
        const Text(" 公升/小時", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
      ]
    ),
    InfoCard(
      title: '水溫',
      color: Colors.orange.shade700,
      icon: SizedBox(
        width: 30, height: 30,
        child: Icon(
          size: 30,
          Icons.thermostat,
          color: Colors.orange.shade700,
        )
      ),
      textSpan: [
        AnimatedDigitWidget(
          controller: tempController,
          textStyle: const TextStyle(
            fontSize: 40,
            color: Colors.white,
          ),
        ),
        const Text(" 攝氏度", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
      ]
    ),
    InfoCard(
      title: '本月累計用水',
      color: Colors.green.shade700,
      icon: SizedBox(
        width: 30, height: 30,
        child: Icon(
          size: 25,
          Icons.calendar_today,
          color: Colors.green.shade700,
        )
      ),
      textSpan: [
        AnimatedDigitWidget(
          controller: sumController,
          textStyle: const TextStyle(
            fontSize: 40,
            color: Colors.white,
          ),
        ),
        const Text(" 公升", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
      ]
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('即時資訊', style: TextStyle(fontSize: 40)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings, size: 35),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsPage()),
                        );
                      } 
                    )
                  ],
                )
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: cardList.length,
                  itemBuilder: (BuildContext context, int index) => cardList[index],
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10)
                )
              )
            ]
          )
        )
      )
    );
  }
}

void startDemoMode() {
  const oneSec = Duration(milliseconds: 1000);
  Timer.periodic(oneSec, (Timer t) {
    sumController.value  += 1;
    tempController.value = Random().nextInt(30);
    flowController.value = Random().nextInt(1000);
  });
}