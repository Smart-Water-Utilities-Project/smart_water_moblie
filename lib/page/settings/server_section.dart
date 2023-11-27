import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/api.dart';
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
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: themeData.colorScheme.primaryContainer
      ),
      child: ListenableBuilder(
        listenable: WebSocketAPI.instance.state,
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
            SizedBox(height: 4),
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
  Widget buildSuccess(BoxConstraints constraints) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Icon(Icons.check_circle_rounded, size: constraints.maxWidth/4.9),
      const SizedBox(width: 5),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("伺服器: ${WebSocketAPI.instance.addr}"),
          Text("本機ID: ${WebSocketAPI.instance.id}")
        ],
      )
    ]
  );

  Widget buildNever(BoxConstraints constraints) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Icon(Icons.close, size: constraints.maxWidth/4.9),
      const SizedBox(width: 5),
      const Text("尚未連接至伺服器")
    ]
  );

  @override
  Widget build(BuildContext context) {
    final websocketState = WebSocketAPI.instance.state;
    return ListenableBuilder(
      listenable: websocketState,
      builder: (context, child) => LayoutBuilder(
        builder: (context, constraints) => AnimatedContainer(
          width: double.infinity,
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          decoration: BoxDecoration(
            color: (websocketState.value == ConnectionStatus.successful) ?
              Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(15)
          ),
          child: (websocketState.value == ConnectionStatus.successful) ? 
            buildSuccess(constraints) : buildNever(constraints)
        )
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
  Widget connectBtn() {
    final themeData = Theme.of(context);
    return TextButton(
      onPressed: () {
        WebSocketAPI.instance.resetConnection();
        
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

  Widget disconnectBtn() {
    final themeData = Theme.of(context);
    return TextButton(
      onPressed: () async {
        await WebSocketAPI.instance.disconnect();
      },
      child: Text("中斷連線", 
        style: themeData.textTheme.labelMedium,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final websocketState = WebSocketAPI.instance.state;
    return ListenableBuilder(
      listenable: websocketState,
      builder: (context, child) {
        if (websocketState.value == ConnectionStatus.successful) {
          return disconnectBtn();
        }
        return connectBtn();
      }
    );
  }
}