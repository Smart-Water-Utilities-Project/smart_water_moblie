import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:smart_water_moblie/provider/theme.dart';

class ThemeSection extends StatefulWidget {
  const ThemeSection({super.key});

  @override
  State<ThemeSection> createState() => _ThemeSectionState();
}

class _ThemeSectionState extends State<ThemeSection> {
  late final ThemeProvider provider;
  ThemeMode currentTheme = ThemeMode.dark;

  void setStateListener() => setState(() {});

  @override
  void initState() {
    fetchTheme();
    super.initState();
  }

  @override
  void dispose() {
    provider.removeListener(setStateListener);
    super.dispose();
  }

  void fetchTheme() async {
    provider = Provider.of<ThemeProvider>(context, listen: false);
    currentTheme = await provider.fetch();
    provider.addListener(setStateListener);
  }
  

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10 ,10),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primaryContainer,
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
            final width = (constraint.maxWidth - 20) / 3;
            return Row(
              children: [
                ThemeButton(
                  size: width,
                  theme: ThemeMode.system,
                ),
                const SizedBox(width: 10),
                ThemeButton(
                  size: width,
                  theme: ThemeMode.dark,
                ),
                const SizedBox(width: 10),
                ThemeButton(
                  size: width,
                  theme: ThemeMode.light
                )
              ],
            );
          }),
        ],
      ),
    );
  }
}

class ThemeButton extends StatefulWidget {
  const ThemeButton({super.key, 
    required this.size,
    required this.theme,
  });

  final double size;
  final ThemeMode theme;

  @override
  State<ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<ThemeButton> {
  Border? getBorder() {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    return (provider.theme == widget.theme) ?
      Border.all(width: 3, color: Colors.blue) : 
      Border.all(width: 3, color: Colors.transparent);  
  }

  String getThemeName(ThemeMode theme) {
    switch (theme.index) {
      case 0: return "系統";
      case 1: return "亮色";
      case 2: return "深色";
    }
    return "錯誤";
  }

  ThemeData getThemeData(ThemeMode theme, BuildContext context) {
    switch (theme.index) {
      case 0:
        final platformBright = MediaQuery.of(context).platformBrightness.index;
        return (platformBright == 0) ? ThemePack.dark : ThemePack.light;
      case 1: return ThemePack.light;
      case 2: return ThemePack.dark;
    }
    return ThemePack.dark;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = getThemeData(widget.theme, context);
    final provider = Provider.of<ThemeProvider>(context, listen: false);

    return Theme(
      data: themeData,
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            width: widget.size, height: widget.size,
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              border: getBorder(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ThemeIcon(
              title: getThemeName(widget.theme)
            ),
          ),
          onTap: () async {
            await provider.toggle(widget.theme);
          }
        )
      )
    );
  }
}

class ThemeIcon extends StatelessWidget {
  const ThemeIcon({super.key, 
    required this.title
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: themeData.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Aa", style: TextStyle(
                    fontSize: maxHeight / 3.0415,
                    color: themeData.textTheme.titleLarge!.color,
                  )),
                  const Spacer(),
                  Container(
                    height: maxHeight / 3.0415, width: maxHeight / 3.0415,
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10)
                    )
                  )
                ],
              ),
              Container(
                height: maxHeight / 24.332,
                margin: EdgeInsets.only(bottom: maxHeight / 24.332),
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              Container(
                height: maxHeight / 24.332,
                margin: EdgeInsets.only(bottom: maxHeight / 24.332),
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              Container(
                height: maxHeight / 24.332,
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              Expanded(
                child: Center(
                  child: Text(title, style: TextStyle(
                    fontSize: maxHeight / 4.8664,
                    color: themeData.textTheme.labelLarge!.color,
                  ))
                )
              )
            ],
          )
        );
      }
    );
  }
}