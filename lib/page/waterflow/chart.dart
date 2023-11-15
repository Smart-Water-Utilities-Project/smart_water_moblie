import 'package:flutter/material.dart';
import 'package:smart_water_moblie/core/data_parser.dart';
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

  Widget _trackballBuilder(BuildContext context, TrackballDetails details) {
    final ThemeData themeData = Theme.of(context);

    final int index = details.groupingModeInfo!.currentPointIndices.first;
    final String xValue = details.groupingModeInfo!.points[0].x as String;
    final double yValue = details.groupingModeInfo!.points[0].y as double;

    final SensorDataPack dataPack = widget.data[index];
    final String dateString = SensorDataParser.displayTimeRange(dataPack, ShowType.day);
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

  SfCartesianChart _buildDefaultCategoryAxisChart() {
    return SfCartesianChart(
      title: ChartTitle(text: ''),
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      series: _getDefaultCategory(),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0)
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        isVisible: false,
        labelFormat: '{value}公升',
        maximum: 30
      ),
      trackballBehavior: TrackballBehavior(
        enable: true,
        tooltipAlignment: ChartAlignment.near,
        activationMode: ActivationMode.singleTap,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
        markerSettings: const TrackballMarkerSettings(height: 0, width: 0),
        builder: _trackballBuilder
      )
    );
  }

  List<ColumnSeries<SensorDataPack, String>> _getDefaultCategory() {
    return <ColumnSeries<SensorDataPack, String>>[
      ColumnSeries<SensorDataPack, String>(
        dataSource: widget.data,
        xValueMapper: (SensorDataPack data, _) {
          return SensorDataParser.displayLabel(widget.data[data.xIndex], ShowType.day);
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
