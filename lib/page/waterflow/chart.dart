import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const weekTitles = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
const hourTitles = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

final ValueNotifier<bool> hideDetails = ValueNotifier(true);

class WaterflowChart extends StatefulWidget {
  const WaterflowChart({super.key});

  @override
  State<WaterflowChart> createState() => _WaterflowChartState();
}

class _WaterflowChartState extends State<WaterflowChart> {
  

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ListenableBuilder(
            listenable: hideDetails,
            builder: (context, child) {
              return Container(
                alignment: Alignment.centerLeft,
                height: 80, width: double.infinity,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeInOutSine,
                  switchOutCurve: Curves.easeOutSine,
                  child: hideDetails.value ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: "  統計用量",
                              style: themeData.textTheme.titleSmall?.copyWith(color: Colors.grey)
                            ),
                            TextSpan(text: "\n 23574 公升",
                              style: themeData.textTheme.titleMedium
                            )
                          ]
                        )
                      )
                    ]
                  ): const SizedBox()
                )
              );
            }
          ),
          const WaterflowBars(),
        ]
      ),
    );
  }
}

class WaterflowBars extends StatefulWidget {
  const WaterflowBars({super.key});
  final Color leftBarColor = Colors.red;
  final Color rightBarColor = Colors.red;
  final Color avgColor =Colors.red;
  @override
  State<StatefulWidget> createState() => WaterflowBarsState();
}

class WaterflowBarsState extends State<WaterflowBars> {
  final double width = 20;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;
  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 5);
    final barGroup2 = makeGroupData(1, 16);
    final barGroup3 = makeGroupData(2, 18);
    final barGroup4 = makeGroupData(3, 20);
    final barGroup5 = makeGroupData(4, 17);
    final barGroup6 = makeGroupData(5, 19);
    final barGroup7 = makeGroupData(6, 10);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    bool getHideDetail(event) {
      switch(event.runtimeType) {
        case FlTapDownEvent: return false;
        case FlPanDownEvent: return false;
        case FlLongPressStart: return false;

        case FlTapUpEvent: return true;
        case FlPanEndEvent: return true;
        case FlLongPressEnd: return true;
        case FlTapCancelEvent: return true;
        case FlPanCancelEvent: return true;
      }
      return false;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: BarChart(
        BarChartData(
          maxY: 26,
          groupsSpace: 0,
          barTouchData: BarTouchData(
            touchCallback: (event, response) {
              hideDetails.value = getHideDetail(event);
            },
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 10,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 3
              ),
              fitInsideVertically: true,
              fitInsideHorizontally: true,
              tooltipMargin: mediaQuery.size.height,
              maxContentWidth: mediaQuery.size.width,
              tooltipBgColor: themeData.inputDecorationTheme.fillColor,
              getTooltipItem: (a, b, c, d) {
                return BarTooltipItem(
                  '', themeData.textTheme.labelMedium!,
                  textAlign: TextAlign.start,
                  children: [
                    const TextSpan(
                      text: "周一",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const TextSpan(text: "\n"),
                    TextSpan(
                      text: "2304",
                      style: themeData.textTheme.labelLarge
                    ),
                    TextSpan(
                      text: " 公升/小時",
                      style: themeData.textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    TextSpan(
                      text: "\n2023年9月31日",
                      style: themeData.textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      )
                    )
                  ],
                );
              },
            )
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: bottomTitles,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                interval: 1,
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: leftTitles,
              )
            )
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: showingBarGroups,
        )
      )
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '1K';
    } else if (value == 10) {
      text = '5K';
    } else if (value == 19) {
      text = '10K';
    } else {
      return Container();
    }
    return SideTitleWidget(
      space: 0,
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {

    final Widget text = Text(
      weekTitles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1) {
    return BarChartGroupData(
      barsSpace: 2,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          width: 30,
          color: widget.leftBarColor,
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(5)
        )
      ],
    );
  } 
}

