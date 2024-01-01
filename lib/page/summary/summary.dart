import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_water_moblie/main.dart';

import 'package:smart_water_moblie/provider/timely.dart';
import 'package:smart_water_moblie/core/smart_water_api.dart';
import 'package:smart_water_moblie/page/summary/article/article.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/timely_info.dart';
import 'package:smart_water_moblie/page/settings/settings.dart';


class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage>{
  late StreamSubscription subscribe;
  

  void onData(Map<String, dynamic> value) {
    timelyProvider.setTimely(
      temp: value["wt"]??0,
      flow: value["wf"]??0,
      level: value["wl"]??0
    );
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
                    const Article(),
                    const SizedBox(height: 10)
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

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final imgHeight = AppBar().preferredSize.height - 15;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: imgHeight,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset("assets/app_icon.png"),
        ),
        const SizedBox(width: 10),
        Text('智慧用水', style: themeData.textTheme.titleLarge),
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
    );
  }
}