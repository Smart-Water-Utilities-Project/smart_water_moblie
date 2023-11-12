import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_water_moblie/websocket.dart';

class DataViewDialog {
  late final BuildContext context;
  late final AnimationController? animation;

  bool isProcessing = false;

  DataViewDialog({
    required this.context,
    required this.animation,
  });

  Future<void> show() async 
  => await showModalBottomSheet(
    context: context,
    enableDrag: !isProcessing,
    useSafeArea: true,
    isDismissible: !isProcessing,
    isScrollControlled: true,
    transitionAnimationController: animation,
    backgroundColor: Theme.of(context).colorScheme.background,
    builder: (context) => DraggableScrollableSheet(
      snap: false,
      expand: false,
      maxChildSize: 0.9,
      minChildSize: 0.9,
      initialChildSize: 0.9,
      builder: (context, scrollController) => build(context)
    )
  );

  Widget build(BuildContext context) 
  => StatefulBuilder(
    builder: ((context, setState) 
    => const ServerInitialize()
    ) 
  );
}

class ServerInitialize extends StatefulWidget {
  const ServerInitialize({super.key});

  @override
  State<ServerInitialize> createState() => _ServerInitializeState();
}

class _ServerInitializeState extends State<ServerInitialize> {
  String? errorLore;
  ConnectState result = ConnectState.never;
  final addrTextController = TextEditingController();
  final portTextController = TextEditingController();
  
  void connectWS() async {
    final String addr = addrTextController.value.text;
    final String port = portTextController.value.text;

    setState(() => result = ConnectState.connecting);
    errorLore = await wsAPI.connect("$addr:$port");
    setState(() => result = wsAPI.state);

    return;
  }

  Function()? doneFunction() {
    if (result == ConnectState.connecting) return null;
    if (addrTextController.value.text.isEmpty || portTextController.text.isEmpty) return null;
    if (result == ConnectState.successful) return () => Navigator.pop(context);

    return connectWS;
  }

  Function()? cancelFunction() {
    if (result == ConnectState.successful) return null;

    return () => Navigator.pop(context);
  }

  String doneString() {
    switch(result.index){
      case 1: return "完成";
      case 3: return "連線中";
    }

    return "連線";
  }

  @override
  Widget build(BuildContext context) {
    final widgetList = [
      const SizedBox(height: 0),
      HeadingBar(
        doneText: doneString(),
        cancelText: "取消",
        title: "連線至伺服器",
        onCancel: cancelFunction(),
        onDone: doneFunction(),
      ),
      TextBox(
        title: "IP位置",
        controller: addrTextController,
        onChanged: (value) => setState(() => {})
      ),
      TextBox(
        title: "端口",
        onlyDigits: true,
        controller: portTextController,
        onChanged: (value) => setState(() => {})
      ),
      InfoBox(
        result: result,
        errorLore: errorLore
      )
    ];

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15)
        )
      ),
      child: Scaffold(
        appBar: AppBar(elevation: 0, toolbarHeight: 0),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.separated(
            itemBuilder: (context, index) => widgetList[index],
            separatorBuilder:(context, index) => const SizedBox(height: 10),
            itemCount: widgetList.length
          )
        )
      )
    );
  }
}

class HeadingBar extends StatelessWidget {
  const HeadingBar({
    super.key,
    required this.title,
    required this.onDone,
    required this.onCancel,
    required this.doneText,
    required this.cancelText
  });

  final String title;
  final String doneText;
  final String cancelText;
  final Function()? onDone;
  final Function()? onCancel;

  Color textColor(Function()? function, BuildContext context) {
    final themeData = Theme.of(context);

    return (function==null) ? Colors.grey.shade600 : 
      themeData.colorScheme.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: onCancel,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.transparent
                )
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(cancelText,
                  style: themeData.textTheme.labelMedium!.copyWith(
                    color: textColor(onCancel, context),
                  )
                )
              )
            ),
            const Spacer(),
            TextButton(
              onPressed: onDone,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.transparent
                )
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(doneText,
                  style: themeData.textTheme.labelMedium!.copyWith(
                    color: textColor(onDone, context)
                  )
                )
              )
            )
          ]
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(title)
        )
      ]
    );
  }
}

class TextBox extends StatelessWidget {
  const TextBox({super.key,
    required this.title,
    required this.controller,
    this.onChanged,
    this.onlyDigits = false
  });

  final String title;
  final bool onlyDigits;
  final TextEditingController controller;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(builder: (context, constraint) {
      return SizedBox(
        width: constraint.maxWidth, 
        child: TextField(
          maxLines: 1,
          autocorrect: false,
          onChanged: onChanged,
          controller: controller,
          enableSuggestions: false,
          style: const TextStyle(fontSize: 18),
          keyboardType: onlyDigits ? TextInputType.number : null,
          inputFormatters: onlyDigits ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            isCollapsed: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(title, 
                    style: themeData.textTheme.bodyMedium!.copyWith(
                      color: Colors.grey
                    )
                  )
                )
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15, vertical: 12
            )
          )
        )
      );
    });
  }
}

class InfoBox extends StatefulWidget {
  const InfoBox({super.key,
    required this.errorLore,
    required this.result
  });

  final String? errorLore;
  final ConnectState result;

  @override
  State<InfoBox> createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> {

  Color getColor() {
    final themeData = Theme.of(context);
    switch(widget.result.index) {
      case 2: return Colors.red.shade400;
      default: return themeData.inputDecorationTheme.fillColor!;
    }
  }

  String getLore() {
    switch(widget.result.index) {
      case 1: return '連線成功';
      case 2: return widget.errorLore??'';
      case 3: return "正在嘗試連線...";
    }
    return "尚未連接至伺服器";
  }

  IconData getIcon() {
    switch(widget.result.index) {
      case 1: return Icons.check;
      case 2: return Icons.error;
      case 3: return Icons.wifi;
    }
    return Icons.sensors_off_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: double.infinity,
      curve: Curves.easeInOutSine,
      duration: const Duration(milliseconds: 150),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: getColor(),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                switchInCurve: Curves.easeInSine,
                switchOutCurve: Curves.easeInOutSine,
                duration: const Duration(milliseconds: 150),
                child: Icon(getIcon(), size: 200, key: ValueKey<int>(widget.result.index)),
              ),
              Text(getLore()),
              const SizedBox(height: 25)
            ],
          ),
          (widget.result == ConnectState.connecting) ? const LinearProgressIndicator() : Container()
        ]
      )
    );
  }
}