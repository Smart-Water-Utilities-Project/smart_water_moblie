import 'package:flutter/material.dart';
import 'package:smart_water_moblie/data_parser.dart';
import 'package:smart_water_moblie/page/waterflow/mode_select.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WaterflowChart extends StatefulWidget {
  const WaterflowChart({
    super.key,
    required this.data,
    required this.maxY
  });

  final int maxY;
  final List<SensorDataPack> data;

  @override
  State<WaterflowChart> createState() => _WaterflowChartState();
}

class _WaterflowChartState extends State<WaterflowChart> {

  
  late TrackballBehavior? trackballBehavior;
  @override
  void initState() {
    super.initState();
  
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 500,
      child: _buildDefaultCategoryAxisChart(),
    );
  }

  SfCartesianChart _buildDefaultCategoryAxisChart() {
    final themeData = Theme.of(context);

    return SfCartesianChart(
      title: ChartTitle(text: ''),
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      series: _getDefaultCategory(),
      primaryXAxis: CategoryAxis(majorGridLines: const MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(minimum: 0, isVisible: false, labelFormat: '{value}公升', maximum: 5),
      trackballBehavior: TrackballBehavior(
        enable: true,
        tooltipAlignment: ChartAlignment.near,
        activationMode: ActivationMode.singleTap,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
        markerSettings: const TrackballMarkerSettings(height: 0, width: 0),
        builder: (context, trackballDetails) {
          final index = trackballDetails.groupingModeInfo!.currentPointIndices.first;
          final xValue = trackballDetails.groupingModeInfo!.points[0].x as String;
          final yValue = trackballDetails.groupingModeInfo!.points[0].y as double;

          final dataPack = widget.data[index];
          final dateString = SensorDataParser.displayTimeRange(dataPack.startTs, dataPack.endTs, ShowType.day);
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
                  TextSpan(
                    text: xValue,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  const TextSpan(text: "\n"),
                  TextSpan(
                    text: yValue.toStringAsFixed(2),
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
      )
    );
  }

  List<ColumnSeries<SensorDataPack, String>> _getDefaultCategory() {
    return <ColumnSeries<SensorDataPack, String>>[
      ColumnSeries<SensorDataPack, String>(
        dataSource: widget.data,
        xValueMapper: (SensorDataPack data, _) => SensorDataParser.displayLabel(widget.data[data.xIndex-1], ShowType.day) ,
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

