import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_water_moblie/pages/summary.dart';
import 'package:smart_water_moblie/provider/theme.dart';

ThemeProvider themeProvider = ThemeProvider();

void main() {
  runApp(const MyApp());

  startDemoMode();
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
          title: 'Flutter Demo',
          home: const SummaryPage(),
          theme: ThemePack.dark,
          darkTheme: ThemePack.dark,
          themeMode: themeProvider.theme,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(textScaleFactor: 1),
              child: child!,
            );
          }
        );
      }
    );
  }
}