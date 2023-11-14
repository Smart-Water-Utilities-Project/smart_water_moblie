import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum ShowType {day, week, month}

class ModeSwitch extends StatefulWidget {
  const ModeSwitch({
    super.key, 
    this.onChange,
  });

  @override
  State<ModeSwitch> createState() => ModeSwitchState();

  final Function(ShowType?)? onChange;
}

class ModeSwitchState extends State<ModeSwitch> {
  late ShowType selected;
  
  @override
  void initState() {
    super.initState();
    selected = ShowType.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const labelStyle = TextStyle(
      fontSize: 18,
      color: Colors.white,
      fontWeight: FontWeight.normal
    );

    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<ShowType>(
        groupValue: selected,
        thumbColor: theme.colorScheme.secondary,
        backgroundColor: theme.inputDecorationTheme.fillColor!,
        children: const <ShowType, Widget>{
          ShowType.day: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('今天', style: labelStyle)
          ),
          ShowType.week: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('本周', style: labelStyle)
          ),
          ShowType.month: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('本月', style: labelStyle)
          )
        },
        onValueChanged: (ShowType? value) {
          if (value != null) {
            setState(() {selected = value;});
            widget.onChange?.call(value);
          }
        }
      ),
    );
  }
}