import 'package:flutter/material.dart';
import 'package:smart_water_moblie/core/data_parser.dart';

class TrendIndicator extends StatefulWidget {
  const TrendIndicator({
    super.key,
    required this.sensorData,
    required this.headingData
  });

  final SensorHeadData headingData;
  final List<SensorDataPack> sensorData;

  @override
  State<TrendIndicator> createState() => TrendIndicatorState();
}

class TrendIndicatorState extends State<TrendIndicator> {
  String? trend;
  late Future<String> trendData;

  void refresh() async {
    setState(() => trend = null);

    final waterflows = widget.sensorData.map((e) => e.waterflow).toList();
    final halfRange = (widget.sensorData.length/2).ceil();

    if (widget.sensorData.isEmpty) {
      trend ="無法使用";
      return;
    }

    final frontList = waterflows.sublist(0, (waterflows.length % 2 == 0) ? halfRange-1 : halfRange);
    final backList = waterflows.sublist((waterflows.length % 2 == 0) ? halfRange : halfRange -1);
    final frontAverage = frontList.reduce((a, b) => a + b) / ((waterflows.length % 2 == 0) ? halfRange : halfRange -1);
    final backAverage = backList.reduce((a, b) => a + b) / ((waterflows.length % 2 == 0) ? halfRange : halfRange -1);    
    final slope = backAverage - frontAverage;

    if (slope == 0) { trend = "無法使用";}
    else if (slope > 0) { trend = "增加";} 
    else { trend = "減少"; }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          width: 1,
          color: themeData.colorScheme.primary
        )
      ),
      child: Row(
        children: [
          Text(
            "趨勢",
            style: themeData.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.normal,
              color: themeData.colorScheme.primary
            )
          ),
          const Spacer(),
          (trend == null) ? const Padding(
            padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: SizedBox(
              height: 22, width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              )
            )
          ) : Text(
            trend!,
            style: themeData.textTheme.titleSmall?.copyWith(
              color: themeData.colorScheme.primary
            )
          )
        ]
      )
    );
  }
}