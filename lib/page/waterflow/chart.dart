import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:smart_water_moblie/core/data_parser.dart';
import 'package:smart_water_moblie/page/waterflow/mode_select.dart';

class WaterflowChart extends StatefulWidget {
  const WaterflowChart({
    super.key,
    required this.data,
    required this.heading,
    required this.selectedMode
  });

  final ShowType selectedMode;
  final SensorHeadData heading;
  final List<SensorDataPack> data;

  @override
  State<WaterflowChart> createState() => _WaterflowChartState();
}

class _WaterflowChartState extends State<WaterflowChart> {
  ValueNotifier<bool> showValue = ValueNotifier(true);
  int animationDisableFlag = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          OverAllText(
            hide: showValue,
            heading: widget.heading,
            selectedMode: widget.selectedMode,
            animationDisableFlag: animationDisableFlag,
          ),
          _chartBuilder()
        ],
      ),
    );
  }

  Widget _trackballBuilder(BuildContext context, TrackballDetails details) {
    final ThemeData themeData = Theme.of(context);

    final int index = details.groupingModeInfo!.currentPointIndices.first;
    final String xValue = details.groupingModeInfo!.points[0].x as String;
    final double yValue = details.groupingModeInfo!.points[0].y as double;

    final SensorDataPack dataPack = widget.data[index];
    widget.data;
    index;
    final String dateString = SensorDataParser.displayTimeRange(dataPack, widget.selectedMode);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: themeData.inputDecorationTheme.fillColor,
      ),
      child: RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
          children: [
            const TextSpan(
              text: "總計",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.bold
              )
            ),
            TextSpan(
              text: "\n${yValue.toStringAsFixed(2)}",
              style: themeData.textTheme.labelLarge
            ),
            TextSpan(
              text: " 公升",
              style: themeData.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold
              )
            ),
            TextSpan(
              text: "\n$dateString",
              style: themeData.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold
              )
            )
          ]
        )
      )
    );
  }

  SfCartesianChart _chartBuilder() {
    return SfCartesianChart(
      series: _getCategory(),
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      margin: const EdgeInsets.symmetric(vertical: 10),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0)
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        isVisible: false,
        maximum: (widget.data.isEmpty) ? 50 : widget.heading.maxWf*1.3,
      ),
      trackballBehavior: TrackballBehavior(
        enable: true,
        builder: _trackballBuilder,
        tooltipAlignment: ChartAlignment.near,
        activationMode: ActivationMode.singleTap,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
        markerSettings: const TrackballMarkerSettings(height: 0, width: 0)
      ),
      onChartTouchInteractionUp: (event) => showValue.value=true,
      onChartTouchInteractionDown: (event) => showValue.value=false,
      
    );
  }

  List<ColumnSeries<SensorDataPack, String>> _getCategory() {
    return <ColumnSeries<SensorDataPack, String>>[
      ColumnSeries<SensorDataPack, String>(
        animationDuration: 1000,
        dataSource: widget.data,
        xValueMapper: (SensorDataPack data, _) {
          return SensorDataParser.displayLabel(data, widget.selectedMode);
        },
        yValueMapper: (SensorDataPack data, _) => data.waterflow,
        pointColorMapper: (SensorDataPack data, _) => Colors.red,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4), 
          topRight: Radius.circular(4)
        )
        // dataLabelSettings: const DataLabelSettings(isVisible: true),
      )
    ];
  }
}

class OverAllText extends StatefulWidget {
  const OverAllText({
    super.key,
    required this.hide,
    required this.heading,
    required this.selectedMode,
    required this.animationDisableFlag
  });

  final ShowType selectedMode;
  final SensorHeadData heading;
  final ValueNotifier<bool> hide;
  final int animationDisableFlag;

  @override
  State<OverAllText> createState() => _OverAllTextState();
}

class _OverAllTextState extends State<OverAllText> {

  String getTimeText() {
    final startTs = widget.heading.startTs;
    final endTs = widget.heading.endTs;
    if (startTs == null && endTs == null) {
      return "無時間資料";
    }
    switch(widget.selectedMode) {
      case ShowType.day:
        return DateFormat('yyyy年 MM/dd').format(startTs ?? endTs!);
      
      case ShowType.week:
        return "${DateFormat('yyyy年 MM/dd').format(startTs!)} - ${DateFormat('MM/dd').format(endTs!)}";

      case ShowType.month:
        final daysOfMonth = DateTime(startTs!.year, startTs.month+1, 0).day;
        return DateFormat('yyyy年 MM/1 - MM/$daysOfMonth').format(startTs);
        // ${DateFormat('dd 日').format(endTs!)
      
      default: 
        return "無時間資料";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      alignment: Alignment.centerLeft,
      height: 80, width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      child: ListenableBuilder(
        listenable: widget.hide,
        builder: (context, child) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOutSine,
        switchOutCurve: Curves.easeOutSine,
          child: widget.hide.value ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 5,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: themeData.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "統計用量",
                      style: themeData.textTheme.labelSmall?.copyWith(
                        height: 0,
                        color: Colors.grey,
                      )
                    ),
                    TextSpan(text: "\n${widget.heading.sumWf.toStringAsFixed(2)} 公升",
                      style: themeData.textTheme.titleMedium?.copyWith(
                        height: 0
                      )
                    ),
                    TextSpan(text: "\n${getTimeText()}",
                      style: themeData.textTheme.titleSmall?.copyWith(
                        height: 0,
                        color: Colors.grey
                      )
                    )
                  ]
                )
              )
            ]
          ): const SizedBox()
        )
      )
    );
  }
}