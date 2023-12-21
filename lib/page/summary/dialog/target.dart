
import 'package:flutter/material.dart';
import 'package:smart_water_moblie/page/summary/dialog/basic.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

class TargetDialog extends StatefulWidget {
  const TargetDialog({super.key});

  @override
  State<TargetDialog> createState() => _TargetDialogState();
}

class _TargetDialogState extends State<TargetDialog> {
  double sliderValue = 0;
  
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 10
      ),
      decoration: BoxDecoration(
        color: themeData.inputDecorationTheme.fillColor
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const NavigationPill(),
          const DialogHeading(
            icon: Icons.ads_click,
            title: "用水目標設定"
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: mediaQuery.size.width / 1.7,
              maxHeight: 300
            ),
            child: CircularIndicator(
              percent: sliderValue,
              text: "${(sliderValue*10000).toStringAsFixed(0)}公升"
            )
          ),
          Slider(
            value: sliderValue,
            onChanged: (value) {
              setState(() => sliderValue = value);
            }
          ),
          Text("data\ndata\ndata\ndata\n")
        ]
      )
    );
  }
}

class CircularIndicator extends StatefulWidget {
  const CircularIndicator({
    super.key,
    required this.percent,
    required this.text
  });

  final double percent;
  final String text;

  @override
  State<CircularIndicator> createState() => _CircularIndicatorState();
}

class _CircularIndicatorState extends State<CircularIndicator> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          showLabels: false,
          showTicks: false,
          startAngle: 180,
          endAngle: 0,
          radiusFactor: 0.7,
          canScaleToFit: false,
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              positionFactor: 0,
              angle: 90,
              widget: Text(
              widget.text,
              style: themeData.textTheme.labelLarge,
              ))
            ],
          axisLineStyle: const AxisLineStyle(
            thickness: 0.1,
            color: Color.fromARGB(30, 0, 169, 181),
            thicknessUnit: GaugeSizeUnit.factor,
            cornerStyle: CornerStyle.startCurve,
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: widget.percent*100,
              width: 0.1,
              sizeUnit: GaugeSizeUnit.factor,
              cornerStyle: CornerStyle.bothCurve)
          ]),
    ]);
  }
}