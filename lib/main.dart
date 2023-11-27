import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_water_moblie/core/demostrate.dart';
import 'package:smart_water_moblie/core/notification.dart';
import 'package:smart_water_moblie/core/api.dart';
import 'package:smart_water_moblie/provider/theme.dart';
import 'package:smart_water_moblie/page/summary/summary.dart';


GlobalKey appkey = GlobalKey();
ThemeProvider themeProvider = ThemeProvider();

void main() async {
  await themeProvider.fetch();
  await demoMode.initialize();
  await NotificationAPI.instance.initizlize();
  
  WebSocketAPI.instance.reteyConnect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider(
      create: (context) => themeProvider,
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          title: '智慧用水',
          home: SummaryPage(key: appkey),
          theme: ThemePack.light,
          darkTheme: ThemePack.dark,
          themeMode: themeProvider.theme,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData,
              child: child!,
            );
          }
        );
      }
    );
  }
}
