import 'package:flutter/material.dart';

import 'package:smart_water_moblie/page/settings/theme_section.dart';
import 'package:smart_water_moblie/page/settings/server_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    List<Widget> listView = const [
      ServerSection(),
      ThemeSection(),
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('設定', style: TextStyle(fontSize: 40))
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: listView.length,
                  itemBuilder: (BuildContext context, int index) => listView[index],
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

