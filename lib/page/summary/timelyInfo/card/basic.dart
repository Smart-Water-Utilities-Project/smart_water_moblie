import 'package:flutter/material.dart';

// Card basics
class InfoCard extends StatefulWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.widget,
    required this.color,
    this.button,
    this.onTap,
    this.iconPadding = true
  });

  final Widget icon;
  final String title;
  final Color color;
  final Widget widget;
  final Widget? button;
  final Function()? onTap;
  final bool iconPadding;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    
    if (widget.iconPadding) {
      return Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(15),
        color: themeData.inputDecorationTheme.fillColor,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10   
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.icon,
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadingBar(
                      title: widget.title,
                      color: widget.color,
                      button: widget.button
                    ),
                    const SizedBox(height: 5),
                    widget.widget
                  ]
                )
              ]
            )
          )
        )
      );
    }

    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(15),
      color: themeData.inputDecorationTheme.fillColor,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10   
          ),
          child: Column(
            children: [
              HeadingBar(
                icon: widget.icon,
                title: widget.title,
                color: widget.color,
                button: widget.button
              ),
              const SizedBox(height: 5),
              widget.widget
            ]
          )
        )
      )
    );
  }
}

class HeadingBar extends StatelessWidget {
  const HeadingBar({
    super.key,
    this.icon,
    this.button,
    required this.title,
    required this.color
  });

  final Widget? icon;
  final Widget? button;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Row(
          children: [
            icon ?? const SizedBox(width: 0),
            SizedBox(width: (icon==null) ? 0 : 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: color
              )
            ),
          ]
        ),
        SizedBox(
          width: mediaQuery.size.width - 85,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [button ?? const SizedBox()]
          )
        )
      ]
    );
  }
}
