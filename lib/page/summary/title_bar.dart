import 'package:flutter/material.dart';
import 'package:smart_water_moblie/page/settings/settings.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    
    return Row(
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
    );
  }
}