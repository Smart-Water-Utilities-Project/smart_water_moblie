import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum ShowType {
  day,
  week,
  month
}

class ModeSwitch extends StatefulWidget {
  const ModeSwitch({
    super.key, 
    required this.onChange,
  });

  @override
  State<ModeSwitch> createState() => ModeSwitchState();

  final Function(ShowType) onChange;
}

class ModeSwitchState extends State<ModeSwitch> {
  ShowType selected = ShowType.day;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    const TextStyle labelStyle = TextStyle(
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
          value ??= ShowType.day;
          setState(() {
            selected = value!;
          });
          widget.onChange(value);
        }
      ),
    );
  }
}
