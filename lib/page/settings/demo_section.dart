import 'package:flutter/material.dart';
import 'package:smart_water_moblie/core/demostrate.dart';

class DemoSection extends StatefulWidget {
  const DemoSection({super.key});

  @override
  State<DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<DemoSection> {
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
              Icon(Icons.remove_red_eye_sharp, size: 35),
              SizedBox(width: 5),
              Text("展示模式")
            ],
          ),
          const SizedBox(height: 5),
          Column(
            children: [
              OptionSwitch(
                title: "即時資訊",
                value: demoMode.timely,
                onChange: (value) async => await demoMode.setTimely(value)
              ),
              OptionSwitch(
                title: "圖表資訊",
                value: demoMode.waterflow,
                onChange: (value) async => await demoMode.setWaterflow(value)
              )
            ]
          )
        ],
      ),
    );
  }
}

class OptionSwitch extends StatefulWidget {
  const OptionSwitch({
    super.key,
    required this.title,
    required this.onChange,
    required this.value
  });

  final bool value;
  final String title;
  final Function(bool) onChange;
  @override
  State<OptionSwitch> createState() => OptionSwitchState();
}

class OptionSwitchState extends State<OptionSwitch> {
  late bool value = widget.value;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return SizedBox(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            widget.title,
            style: themeData.textTheme.bodyMedium
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: (bool val) async {
              setState(() => value = val);
              widget.onChange(val);
            }
          )
        ]
      )
    );
  }
}