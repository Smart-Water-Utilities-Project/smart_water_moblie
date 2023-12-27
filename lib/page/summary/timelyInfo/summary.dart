import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/smart_water_api.dart';
import 'package:smart_water_moblie/core/counter.dart';
import 'package:smart_water_moblie/page/summary/article/article.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/timely_info.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/title_bar.dart';


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
    subscribe = SmartWaterAPI.instance.timelyDataRecieveStream.listen(onData);
  }

  @override
  void dispose() {
    super.dispose();
    subscribe.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
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
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(height: 55 + mediaQuery.viewPadding.top),
                    const TimelyInfo(),
                    const SizedBox(height: 10),
                    const Article()
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }
}
