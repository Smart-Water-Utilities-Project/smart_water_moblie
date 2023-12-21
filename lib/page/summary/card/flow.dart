import 'package:flutter/material.dart';
import 'package:smart_water_moblie/core/counter.dart';

import 'package:smart_water_moblie/page/summary/card/basic.dart';
import 'package:smart_water_moblie/page/summary/card/indicator.dart';
import 'package:smart_water_moblie/page/summary/dialog/leakage.dart';
import 'package:smart_water_moblie/page/summary/dialog/basic.dart';

class FlowCard extends StatefulWidget {
  const FlowCard({
    super.key,
    required this.size
  });

  final double size;

  @override
  State<FlowCard> createState() => _FlowCardState();
}

class _FlowCardState extends State<FlowCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: InfoCard(
        title: '水流量',
        iconPadding: false,
        color: Colors.cyan.shade700,
        button: Icon(Icons.settings,
          size: 27, color: Colors.cyan.shade700
        ),
        icon: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            Icons.water,
            size: 30,
            color: Colors.cyan.shade700
          )
        ),
        widget: Expanded(
          child: ColumnIndicator(
            unit: "公升/小時",
            listenable: Controller.flow,
          )
        ),
        onTap: () => launchDialog(
          context, 300, const WaterLeakage()
        ),
      )
    );
  }
}