import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum ShowType {hour, day, week, month}


const Map<ShowType, Color> skyColors = <ShowType, Color>{
  ShowType.hour: Colors.green,
  ShowType.day: Colors.green,
  ShowType.week: Colors.green,
  ShowType.month: Colors.green
};

class ModeSwitch extends StatefulWidget {
  const ModeSwitch({
    super.key, 
    required this.onChange,
  });

  @override
  State<ModeSwitch> createState() => ModeSwitchState();

  final VoidCallback? onChange;
}

class ModeSwitchState extends State<ModeSwitch> {
  late ShowType selected;
  
  @override
  void initState() {
    super.initState();
    selected = ShowType.hour;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: CupertinoSlidingSegmentedControl<ShowType>(
        groupValue: selected,
        thumbColor: skyColors[selected]!,
        backgroundColor: theme.inputDecorationTheme.fillColor!,
        onValueChanged: (ShowType? value) {
          if (value != null) {
            setState(() {selected = value;});
            widget.onChange?.call();
          }
        },
        children: const <ShowType, Widget>{
          ShowType.hour: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '小時', style: TextStyle(color: Colors.white)
            )
          ),
          ShowType.day: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '天', style: TextStyle(color: Colors.white)
            )
          )
        },
      )
    );
  }
}