import 'dart:async';
import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/api.dart';
import 'package:smart_water_moblie/core/counter.dart';
import 'package:smart_water_moblie/page/summary/title_bar.dart';
import 'package:smart_water_moblie/page/summary/card/flow.dart';
import 'package:smart_water_moblie/page/summary/card/usage.dart';
import 'package:smart_water_moblie/page/summary/card/target.dart';
import 'package:smart_water_moblie/page/summary/card/volume.dart';
import 'package:smart_water_moblie/page/summary/connect_box.dart';
import 'package:smart_water_moblie/page/summary/card/temperature.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage>{
  late StreamSubscription subscribe;
  

  void onData(Map<String, dynamic> value) {
    Controller.temp.value = value["wt"]??0;
    Controller.flow.value = value["wf"]??0;
    Controller.level.value = value["wl"]??0;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    subscribe = WebSocketAPI.instance.timelyDataRecieveStream.listen(onData);
  }

  @override
  void dispose() {
    super.dispose();
    subscribe.cancel();
  }

  

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    
    List<Widget> cardList = [
      LayoutBuilder(
        builder: (context, constant) {
          final width = (constant.maxWidth-10) / 2;
          return Row(
            children: [
              FlowCard(size: width),
              const SizedBox(width: 10),
              TemperatureCard(size: width)
            ]
          );
        }
      ),
      const UsageCard(),
      const TargetCard(),
      const VolumeCard(),
      // const InfoCard(
      //   title: '全部資料',
      //   color: Colors.yellow,
      //   icon: SizedBox(
      //     width: 30,
      //     height: 50,
      //     child: Icon(
      //       size: 30,
      //       Icons.water_damage,
      //       color: Colors.yellow,
      //     )
      //   ),
      //   widget: SizedBox()
      // )
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
              const SizedBox(height: 10),
              const TitleBar(),
              const ConnectIndicator(),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) => cardList[index],
                  itemCount: cardList.length,
                  separatorBuilder: (context, index) => 
                    const SizedBox(height: 10)
                )
              )
            ]
          )
        )
      )
    );
  }
}
