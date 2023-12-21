import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/api.dart';
import 'package:smart_water_moblie/page/settings/connect_dialog.dart';
class ConnectIndicator extends StatefulWidget {
  const ConnectIndicator({super.key});

  @override
  State<ConnectIndicator> createState() => _ConnectIndicatorState();
}

class _ConnectIndicatorState extends State<ConnectIndicator> with TickerProviderStateMixin{
  bool isHide = false;
  
  void popDialog() {
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
  }
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WebSocketAPI.instance.state,
      builder: (context, child) => ListenableBuilder(
        listenable: WebSocketAPI.instance.retryCount,
        builder: (context, child) {
          ConnectionStatus status = WebSocketAPI.instance.state.value;
          if (status == ConnectionStatus.successful) {
            Future.delayed(const Duration(seconds: 3))
            .then((value) {
              isHide = true;
              if (mounted) setState(() {});
            });
          } else { isHide = false; }
          return ConnectingBox(
            hide: isHide,
            state: status,
            popDialog: popDialog,
          );
        }
      )
    );
  }
}

class ConnectingBox extends StatelessWidget {
  const ConnectingBox({
    super.key,
    required this.state,
    required this.hide,
    required this.popDialog
  });
  final bool hide;
  final void Function()? popDialog;
  final ConnectionStatus state;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final connectingList = [
      const SizedBox(
        height: 20, width: 20,
        child: CircularProgressIndicator(),
      ),
      const SizedBox(width: 7),
      Text(
        "正在連線至伺服器",
        style: themeData.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold
        )
      ),
      const Spacer(),
      Container(
        alignment: Alignment.bottomCenter,
        child: Text(
          WebSocketAPI.instance.retryCount.value.toString(),
          style: themeData.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold
          )
        )
      )
    ];

    final failedList = [
      const SizedBox(
        height: 20, width: 20,
        child: Icon(Icons.error)
      ),
      const SizedBox(width: 7),
      Text(
        "伺服器連線失敗",
        style: themeData.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold
        )
      ),
      const Spacer(),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.red.shade300)
          ),
          child: Text(
            "重試",
            style:  themeData.textTheme.labelMedium,
          ),
          onPressed: () async {
            await WebSocketAPI.instance.reteyConnect(url: "192.168.1.110:5678");
          }
        )
      )
    ];

    final successList = [
      const SizedBox(
        height: 20, width: 20,
        child: Icon(Icons.check_circle)
      ),
      const SizedBox(width: 7),
      Text(
        "伺服器連線成功",
        style: themeData.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold
        )
      )
    ];

    final neverList = [
      const SizedBox(
        height: 20, width: 20,
        child: Icon(Icons.device_unknown)
      ),
      const SizedBox(width: 7),
      Text(
        "尚未設定伺服器連線",
        style: themeData.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold
        )
      ),
      const Spacer(),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
        child: TextButton(
          onPressed: popDialog,
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.grey.shade700)
          ),
          child: Text(
            "連線", 
            style: themeData.textTheme.labelMedium,
          ),
        )
      )
    ];

    Color? getColor() {
      switch(state) {
        case ConnectionStatus.autoconnect: 
          return Colors.orange;
        case ConnectionStatus.failed:
          return Colors.red;
        case ConnectionStatus.successful:
          return Colors.green;
        default: 
          return Colors.grey;
      }
    }

    BoxConstraints getConstraints() {
      if (hide) return const BoxConstraints(maxHeight: 0);
      switch(state) {
        default:
          return const BoxConstraints(maxHeight: 40, minHeight: 40);
      }
    }

    List<Widget> getWidgets() {
      switch(state) {
        case ConnectionStatus.autoconnect:
          return connectingList;
        case ConnectionStatus.connecting:
          return connectingList;
        case ConnectionStatus.failed:
          return failedList;
        case ConnectionStatus.successful:
          return successList;
        case ConnectionStatus.never:
          return neverList;
        default:
          return [];
      }
    }

    EdgeInsetsGeometry getMargin() {
      if (hide) return const EdgeInsets.symmetric(vertical: 5);
      return const EdgeInsets.symmetric(vertical: 10);
    }
    
    return AnimatedContainer(
      curve: Curves.easeInOutSine,
      clipBehavior: Clip.hardEdge,
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 7),
      constraints: getConstraints(),
      margin: getMargin(),
      decoration: BoxDecoration(
        color: getColor(),
        borderRadius: BorderRadius.circular(10)
      ),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeInSine,
        switchOutCurve: Curves.easeInSine,
        duration: const Duration(milliseconds: 350),
        child: Row(
          key: ValueKey<int>(state.index),
          children: getWidgets()
        )
      ),
    );
  }
}