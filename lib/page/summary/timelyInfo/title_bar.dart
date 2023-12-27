import 'package:flutter/material.dart';
import 'package:smart_water_moblie/page/settings/settings.dart';

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