import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smart_water_moblie/page/volume/page_view.dart';
import 'package:smart_water_moblie/page/volume/mode_select.dart';

class WaterValuePage extends StatefulWidget {
  const WaterValuePage({super.key});

  @override
  State<WaterValuePage> createState() => _WaterValuePageState();
}

class _WaterValuePageState extends State<WaterValuePage> {

  PageController pageController = PageController();
  List<GlobalKey<ModePageViewState>> indexKeys = [
    GlobalKey<ModePageViewState>(),
    GlobalKey<ModePageViewState>(),
    GlobalKey<ModePageViewState>()
  ]; // Use to reset child pageview to index 0
  
  void onSwitchChange(ShowType event) {
    pageController.animateToPage(
      event.index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutSine
    );
    setState(() {});
  }

  void onDoubleClick(ShowType event) {
    indexKeys[event.index].currentState?.resetPage();
  }
  @override
  void initState() {
    super.initState();
    // onSwitchChange(ShowType.day);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final themeData = Theme.of(context);
    // final barsSpace = 4.0 * mediaQuery.size.width / 400;
    // final barsWidth = 8.0 * mediaQuery.size.width / 400;
  
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        excludeHeaderSemantics: true,
        surfaceTintColor: themeData.colorScheme.background,
        backgroundColor: themeData.colorScheme.background.withOpacity(0.75),
        title: Text("用水量資料",
          style: themeData.textTheme.labelMedium?.copyWith(
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
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 65 + mediaQuery.viewPadding.top),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ModeSwitch(
                  onChange: onSwitchChange
                )
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  scrollBehavior: const ScrollBehavior(),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ModePageView(
                      key: indexKeys[0],
                      showType: ShowType.day
                    ),
                    ModePageView(
                      key: indexKeys[1],
                      showType: ShowType.week
                    ),
                    ModePageView(
                      key: indexKeys[2],
                      showType: ShowType.month
                    )
                  ]
                )
              )
            ]
          ),
          // const BottomDetailSheet()
        ]
      )
    );
  }
}

