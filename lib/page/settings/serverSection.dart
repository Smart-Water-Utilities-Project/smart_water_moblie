import 'package:flutter/material.dart';

class ServerSection extends StatefulWidget {
  const ServerSection({super.key});

  @override
  State<ServerSection> createState() => _ServerSectionState();
}

class _ServerSectionState extends State<ServerSection> {
  String? errorLore;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10 ,10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: themeData.colorScheme.primaryContainer
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.rss_feed, size: 35),
              SizedBox(width: 5),
              Text("主機連線")
            ],
          ),
          const SizedBox(height: 5),
          LayoutBuilder(builder: (context, constraint) {
            return SizedBox(
              width: constraint.maxWidth, 
              child: TextField(
                maxLines: 1,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: "IP位置",
                  suffix: TextButton(
                    child: const Text("連線", style: TextStyle(fontSize: 17)),
                    onPressed: () {
                      errorLore = (errorLore==null) ? "連線發生錯誤" : null;
                      setState(() {});
                    }
                  ),
                )
              )
            );
          }),
          ErrorBox(errorLore: errorLore),
          ConnectedIcon()
        ]
      )
    );
  }
}

class ErrorBox extends StatefulWidget {
  const ErrorBox({super.key,
    required this.errorLore
  });

  final String? errorLore;

  @override
  State<ErrorBox> createState() => _ErrorBoxState();
}

class _ErrorBoxState extends State<ErrorBox> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constrained) {
        return AnimatedContainer(
          curve: Curves.easeInOutSine,
          width: constrained.maxWidth,
          constraints: (widget.errorLore==null) ? 
            const BoxConstraints(maxHeight: 0) : 
            const BoxConstraints(maxHeight: 80),
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.fromLTRB(10, 5, 10 ,5),
          margin: const EdgeInsets.fromLTRB(0, 10, 0 ,0),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(15)
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.error, size: 30),
                    ),
                    const SizedBox(width: 5),
                    Text(widget.errorLore??''),
                  ]
                ),
                Text("如果真的找不到問題那就不要用", style: themeData.textTheme.labelMedium)
              ],
            )
          )
        );
      }
    );
  }
}

class ConnectedIcon extends StatelessWidget {
  const ConnectedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      height: 100,
      width: double.infinity,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                const WidgetSpan(
                  child: Icon(Icons.check_circle, size: 30),
                ),
                TextSpan(
                  text: " 連線成功",
                  style: themeData.textTheme.bodyMedium
                )
              ],
            ),
          ),
          Text("裝置: asdasdasasdsad")
        ]
      )
    );
  }
}