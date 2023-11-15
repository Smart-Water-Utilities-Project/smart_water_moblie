import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_water_moblie/core/demomode.dart';
import 'package:smart_water_moblie/core/websocket.dart';
import 'package:smart_water_moblie/provider/theme.dart';
import 'package:smart_water_moblie/page/summary/summary.dart';

ThemeProvider themeProvider = ThemeProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeProvider.fetch();
  wsAPI.connect("192.168.1.110:5678");
  DemoMode();
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
          home: const SummaryPage(),
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
