import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/websocket.dart';
import 'package:smart_water_moblie/page/settings/connect_dialog.dart';

class ServerSection extends StatefulWidget {
  const ServerSection({super.key});

  @override
  State<ServerSection> createState() => _ServerSectionState();
}

class _ServerSectionState extends State<ServerSection> {

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10 ,10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: themeData.colorScheme.primaryContainer
      ),
      child: ListenableBuilder(
        listenable: wsAPI,
        builder: (context, child) => const Column(
          children: [
            Row(
              children: [
                Icon(Icons.rss_feed, size: 35),
                SizedBox(width: 5),
                Text("主機連線")
              ]
            ),
            SizedBox(height: 5),
            DetailBox(),
            SizedBox(height: 10),
            ActionButton()
          ]
        )
      )
    );
  }
}

class DetailBox extends StatefulWidget {
  const DetailBox({super.key});

  @override
  State<DetailBox> createState() => _DetailBoxState();
}

class _DetailBoxState extends State<DetailBox> {
  void setStateFunction() => setState(() {});

  @override
  void initState() {
    wsAPI.addListener(setStateFunction);
    super.initState();
  }
  
  @override
  void dispose() {
    wsAPI.removeListener(setStateFunction);
    super.dispose();
  }

  Widget buildSuccess(BoxConstraints constraints) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Icon(Icons.check_circle_rounded, size: constraints.maxWidth/4.9),
      const SizedBox(width: 5),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("本機ID: ${wsAPI.clientID}"),
          Text("伺服器: ${wsAPI.serverAddress}"),
        ],
      )
    ]
  );

  Widget buildNever(BoxConstraints constraints) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Icon(Icons.close, size: constraints.maxWidth/4.9),
      const SizedBox(width: 5),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("本機ID: ${wsAPI.clientID}"),
          const Text("尚未連接至伺服器"),
        ],
      )
    ]
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        decoration: BoxDecoration(
          color: (wsAPI.state == ConnectionStatus.successful) ?
            Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(15)
        ),
        child: (wsAPI.state == ConnectionStatus.successful) ? 
          buildSuccess(constraints) : buildNever(constraints)
      )
    );
  }
}

class ActionButton extends StatefulWidget  {
  const ActionButton({super.key});

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> with TickerProviderStateMixin {

  void setStateFunction() => setState(() {});

  @override
  void initState() {
    wsAPI.addListener(setStateFunction);
    super.initState();
  }
  
  @override
  void dispose() {
    wsAPI.removeListener(setStateFunction);
    super.dispose();
  }

  Widget buildConnect() {
    final themeData = Theme.of(context);
    return TextButton(
      onPressed: () {
        final animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200)
        );

        final dialog = DataViewDialog(
          context: context,
          animation: animationController
        );
        
        dialog.show();
      },
      child: Text(
        "建立連線", 
        style: themeData.textTheme.labelMedium,
      )
    );
  }

  Widget buildDisconnect() {
    final themeData = Theme.of(context);
    return TextButton(
      onPressed: () async {
        await wsAPI.disconnect();
      },
      child: Text("中斷連線", 
        style: themeData.textTheme.labelMedium,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (wsAPI.state == ConnectionStatus.successful) {
      return buildDisconnect();
    }
    return buildConnect();
  }
}