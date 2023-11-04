import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  List<Widget> listView = [
    const ThemeSection()
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

class ThemeSection extends StatefulWidget {
  const ThemeSection({super.key});

  @override
  State<ThemeSection> createState() => _ThemeSectionState();
}

class _ThemeSectionState extends State<ThemeSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10 ,10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.display_settings, size: 35),
              SizedBox(width: 5),
              Text("佈景主題")
            ],
          ),
          const SizedBox(height: 5),
          LayoutBuilder(builder: (context, constraint) {
            final width = (constraint.maxWidth - 10) / 2;
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  height: width, width: width,
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 3,
                      color: Colors.blue
                    )
                  ),
                  height: width, width: width,
                )
              ],
            );
          }),
        ],
      ),
    );
  }
}