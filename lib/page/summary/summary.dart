import 'package:flutter/material.dart';

import 'package:animated_flip_counter/animated_flip_counter.dart';

import 'package:smart_water_moblie/page/settings/settings.dart';
import 'package:smart_water_moblie/page/summary/info_card.dart';
import 'package:smart_water_moblie/page/waterflow/waterflow.dart';

class CounterModel with ChangeNotifier {
  double value = 0;
  double get count => value;

  void set(double val) {
    value = val;
    notifyListeners();
  }
}

CounterModel sumController = CounterModel();
CounterModel flowController = CounterModel();
CounterModel tempController = CounterModel();


class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    List<Widget> cardList = [
      ListenableBuilder(
        listenable: flowController,
        builder: (context, child) => InfoCard(
          title: '流量',
          color: Colors.cyan.shade700,
          icon: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              Icons.water,
              size: 30,
              color: Colors.cyan.shade700
            )
          ),
          textSpan: [
            AnimatedFlipCounter(
              value: flowController.value,
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
          ],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (contxt) => WaterflowPage())
          )
        ),
      ),

      ListenableBuilder(
        listenable: tempController,
        builder: (context, child) => InfoCard(
          title: '水溫',
          color: Colors.orange.shade700,
          icon: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              size: 30,
              Icons.thermostat,
              color: Colors.orange.shade700,
            )
          ),
          textSpan: [
            AnimatedFlipCounter(
              fractionDigits: 1,
              value: tempController.value,
              curve: Curves.easeInOutSine,
              duration: const Duration(milliseconds: 600),
              textStyle: themeData.textTheme.titleLarge
            ),
            const Text(
              " 攝氏度",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey
              )
            )
          ]
        )
      ),
      
      ListenableBuilder(
        listenable: sumController,
        builder: (context, child) => InfoCard(
          title: '本月累計用水',
          color: Colors.green.shade700,
          icon: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              size: 25,
              Icons.calendar_today,
              color: Colors.green.shade700,
            )
          ),
          textSpan: [
            AnimatedFlipCounter(
              fractionDigits: 1,
              value: sumController.value,
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
        )
      ),

      ListenableBuilder(
        listenable: flowController,
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
          textSpan: [
            AnimatedFlipCounter(
              fractionDigits: 1,
              value: sumController.value,
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
        )
      ),

      const InfoCard(
        title: '全部資料',
        color: Colors.yellow,
        icon: SizedBox(
          width: 30,
          height: 50,
          child: Icon(
            size: 30,
            Icons.water_damage,
            color: Colors.yellow,
          )
        ),
        textSpan: []
      )
    ];

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
                    Text('即時資訊', style: themeData.textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings, size: 35),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage()
                          ),
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
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 10);
                  }
                )
              )
            ]
          )
        )
      )
    );
  }
}
