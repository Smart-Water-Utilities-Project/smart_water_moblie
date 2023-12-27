import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_water_moblie/core/smart_water_api.dart';

class DataViewDialog {
  late final BuildContext context;
  late final AnimationController? animation;

  bool isProcessing = false;

  DataViewDialog({
    required this.context,
    required this.animation,
  });

  Future<void> show() async => await showModalBottomSheet(
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
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setState) => const ServerInitialize()
        );
      }
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
  final addrTextController = TextEditingController(text: "192.168.1.110");
  final portTextController = TextEditingController(text: "5678");

  @override
  void initState() {
    super.initState();
  }

  void connectWS() async {
    final String addr = addrTextController.value.text;
    final String port = portTextController.value.text;
    errorLore = await SmartWaterAPI.instance.connect("$addr:$port");
  }

  String doneString() {
    switch(SmartWaterAPI.instance.state.value){
      case ConnectionStatus.successful: return "完成";
      case ConnectionStatus.connecting: return "連線中";
      case ConnectionStatus.never: return "連線";
      
      default: return "連線";
    }

    
  }

  Function()? getOnCencel() {
    final state = SmartWaterAPI.instance.state.value;
    switch(state) {
      case ConnectionStatus.successful: return () {
        SmartWaterAPI.instance.resetConnection();
      };
      default: return () {
        SmartWaterAPI.instance.connection?.cancel();
        Navigator.pop(context);
      };
    }
  }

  Function()? getOnDone() {
    final String addr = addrTextController.text;
    final String port = portTextController.text;
    final socketValue = SmartWaterAPI.instance.state.value;
    if (addr.isEmpty || port.isEmpty || socketValue == ConnectionStatus.connecting) {
      return null;
    }
    if (SmartWaterAPI.instance.state.value == ConnectionStatus.successful) {
      return Navigator.of(context).pop;
    }
    if (mounted) {
      return connectWS;
    }
    return null;
  }

  final socketState = SmartWaterAPI.instance.state;
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetList = [
      ListenableBuilder(
        listenable: SmartWaterAPI.instance.state,
        builder: (context, child) => HeadingBar(
          cancelText: "取消",
          title: "連線至伺服器",
          doneText: doneString(),
          onCancel: getOnCencel(),
          onDone: getOnDone(),
        )
      ),
      ListenableBuilder(
        listenable: socketState,
        builder: (context, child) => TextBox(
          title: "IP位置",
          controller: addrTextController
        )
      ),
      ListenableBuilder(
        listenable: socketState,
        builder: (context, child) => TextBox(
          title: "端口",
          onlyDigits: true,
          controller: portTextController
        )
      ),
      ListenableBuilder(
        listenable: socketState,
        builder: (context, child) => InfoBox(
          result: socketState.value,
          errorLore: errorLore
        )
      )
    ];

    return GestureDetector(
      child: Container(
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
      ),
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
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

  Color textColor(Function()? function, BuildContext context) => (
    function == null
  ) ? Colors.grey.shade600 : Theme.of(context).colorScheme.secondary;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

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
              child: Text(cancelText,
                style: themeData.textTheme.labelMedium!.copyWith(
                  color: textColor(onCancel, context),
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
              child: Text(doneText,
                style: themeData.textTheme.labelMedium!.copyWith(
                  color: textColor(onDone, context)
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
  const TextBox({
    super.key,
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
    return LayoutBuilder(
      builder: (context, constraint) {
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
      }
    );
  }
}

class InfoBox extends StatefulWidget {
  const InfoBox({
    super.key,
    required this.errorLore,
    required this.result
  });

  final String? errorLore;
  final ConnectionStatus result;

  @override
  State<InfoBox> createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> {
  Color getColor() {
    final themeData = Theme.of(context);
    switch(widget.result) {
      case ConnectionStatus.failed:
        print("set error lore => ${widget.errorLore}");
        if (widget.errorLore != null) { return Colors.red.shade400; }
        return themeData.inputDecorationTheme.fillColor!;
        
      default: return themeData.inputDecorationTheme.fillColor!;
    }
  }

  String getLore() {
    switch(widget.result) {
      case ConnectionStatus.successful: return '連線成功';
      case ConnectionStatus.connecting: return "正在嘗試連線...";
      case ConnectionStatus.failed:
        if (widget.errorLore == null) {
          return "尚未連接至伺服器";
        } else {return widget.errorLore??'';}
        
      default: return "尚未連接至伺服器";
    }
  }

  IconData getIcon() {
    switch(widget.result) {
      case ConnectionStatus.successful: return Icons.check;
      case ConnectionStatus.failed: return Icons.error;
      case ConnectionStatus.never: return Icons.wifi;
      default: return Icons.sensors_off_rounded;
    }
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
                child: Icon(
                  getIcon(),
                  size: 200,
                  key: ValueKey<int>(widget.result.index)
                ),
              ),
              Text(getLore()),
              const SizedBox(height: 25)
            ],
          ),
          (
            SmartWaterAPI.instance.state.value == ConnectionStatus.connecting
          ) ? const LinearProgressIndicator() : const SizedBox.shrink()
        ]
      )
    );
  }
}
