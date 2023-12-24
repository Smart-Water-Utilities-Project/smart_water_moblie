import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/api.dart';
import 'package:smart_water_moblie/core/counter.dart';
import 'package:smart_water_moblie/page/summary/article_cover.dart';
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
      const SizedBox(height: 80),
      Text("即時資訊", style: themeData.textTheme.titleMedium),
      const ConnectIndicator(),
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
      const SizedBox(height: 10),
      const UsageCard(),
      const SizedBox(height: 10),
      const TargetCard(),
      const SizedBox(height: 10),
      const VolumeCard(),
      const SizedBox(height: 20),
      Text("相關文章", style: themeData.textTheme.titleMedium),
      const SizedBox(height: 10),
      ArticleCover(
        title: "測試",
        lore: "震驚一萬年",
      ),
      const SizedBox(height: 10),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        excludeHeaderSemantics: true,
        surfaceTintColor: themeData.colorScheme.background,
        backgroundColor: themeData.colorScheme.background.withOpacity(0.75),
        title: const TitleBar(),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(color: Colors.transparent)
          )
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => cardList[index],
                  itemCount: cardList.length,
                  separatorBuilder: (context, index) => 
                    const SizedBox(height: 00)
                )
              )
            ]
          )
        )
      )
    );
  }
}
