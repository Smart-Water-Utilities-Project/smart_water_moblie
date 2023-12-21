import 'package:flutter/material.dart';

void launchDialog(BuildContext context, double height, Widget child) {
  final themeData = Theme.of(context);
  final mediaQuery = MediaQuery.of(context);

  showModalBottomSheet(
    context: context,
    clipBehavior: Clip.hardEdge,
    constraints: BoxConstraints(
      maxWidth: mediaQuery.size.width - 30,
      maxHeight: height
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15)
      ),
    ),
    backgroundColor: Colors.transparent,
    builder: (context) => FractionallySizedBox(
      child: child,
    )
  );
}

class DialogHeading extends StatelessWidget {
  const DialogHeading({
    super.key,
    required this.title,
    required this.icon
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 35),
        const SizedBox(width: 5),
        Text(title)
      ]
    );
  }
}

class FancySwitch extends StatefulWidget {
  const FancySwitch({
    super.key,
    required this.title,
    required this.isEnable,
    this.onChange,
    this.lore
  });
  
  final String title;
  final bool isEnable;
  final String? lore;
  final Function(bool)? onChange;
  @override
  State<FancySwitch> createState() => _FancySwitchState();
}

class _FancySwitchState extends State<FancySwitch> {
  
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(15),
      color: themeData.inputDecorationTheme.fillColor,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title),
                  const SizedBox(height: 5),
                  Flexible(
                    child: Text(
                      widget.lore??'',
                      style: themeData.textTheme.labelSmall?.copyWith(
                        color: Colors.grey
                      )
                    )
                  )
                ]
              ),
              const Spacer(),
              Switch(
                value: widget.isEnable,
                onChanged: widget.onChange
              )
            ]
          )
        ),
        onTap: () => widget.onChange?.call(!widget.isEnable)
      )
    );
  }
}

class NavigationPill extends StatelessWidget {
  const NavigationPill({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 40, height: 8,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: themeData.colorScheme.primary,
            borderRadius: BorderRadius.circular(20)
          ),
        )
      )
    );
  }
}