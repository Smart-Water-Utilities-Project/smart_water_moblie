import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smart_water_moblie/page/settings/card/acknowledgments.dart';

import 'package:smart_water_moblie/page/settings/card/demo.dart';
import 'package:smart_water_moblie/page/settings/card/leakage.dart';
import 'package:smart_water_moblie/page/settings/card/limit.dart';
import 'package:smart_water_moblie/page/settings/card/temperature.dart';
import 'package:smart_water_moblie/page/settings/card/theme.dart';
import 'package:smart_water_moblie/page/settings/card/server.dart';
import 'package:smart_water_moblie/page/settings/card/target.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
  
    List<Widget> listView = const [
      ServerSection(),
      LeakageSection(),
      LimitSection(),
      TargetSection(),
      TempertureSection(),
      ThemeSection(),
      DemoSection(),
      Acknowledgements(),
      SizedBox()
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: themeData.colorScheme.background,
        backgroundColor: themeData.colorScheme.background.withOpacity(0.75),
        title: Text("設定",
          style: themeData.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold
          )
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(color: Colors.transparent)
          )
        )
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  itemCount: listView.length,
                  itemBuilder: (BuildContext context, int index) => listView[index],
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
