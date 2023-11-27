import 'dart:async';
import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/api.dart';
import 'package:smart_water_moblie/core/notification.dart';
import 'package:smart_water_moblie/page/settings/connect_dialog.dart';
import 'package:smart_water_moblie/page/settings/settings.dart';
import 'package:smart_water_moblie/page/summary/info_card.dart';
import 'package:smart_water_moblie/page/waterflow/waterflow.dart';

import 'package:animated_flip_counter/animated_flip_counter.dart';

class CounterModel with ChangeNotifier {
  double value = 0;
  double get count => value;

  void set(double val) {
    value = val;
    notifyListeners();
  }
}

CounterModel sumController = CounterModel();
CounterModel flowController = CounterModel();
CounterModel tempController = CounterModel();

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> with TickerProviderStateMixin{
  late StreamSubscription subscribe;
  bool isHide = false;

  void onData(Map<String, dynamic> value) {
    tempController.value = value["wt"]??0;
    flowController.value = value["wf"]??0;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    subscribe = WebSocketAPI.instance.timelyDataRecieveStream.listen(onData);
  }

  @override
  void dispose() {
    super.dispose();
    subscribe.cancel();
  }

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
    final ThemeData themeData = Theme.of(context);
    
    List<Widget> cardList = [
      ListenableBuilder(
        listenable: flowController,
        builder: (context, child) => InfoCard(
          title: '流量',
          color: Colors.cyan.shade700,
          icon: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              Icons.water,
              size: 30,
              color: Colors.cyan.shade700
            )
          ),
          textSpan: [
            AnimatedFlipCounter(
              value: flowController.value,
              curve: Curves.easeInOutSine,
              duration: const Duration(milliseconds: 600),
              textStyle: themeData.textTheme.titleLarge
            ),
            const Text(
              " 公升/小時",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey
              )
            )
          ],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (contxt) => WaterflowPage())
          )
        ),
      ),

      ListenableBuilder(
        listenable: tempController,
        builder: (context, child) => InfoCard(
          title: '水溫',
          color: Colors.orange.shade700,
          icon: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              size: 30,
              Icons.thermostat,
              color: Colors.orange.shade700,
            )
          ),
          textSpan: [
            AnimatedFlipCounter(
              fractionDigits: 1,
              value: tempController.value,
              curve: Curves.easeInOutSine,
              duration: const Duration(milliseconds: 600),
              textStyle: themeData.textTheme.titleLarge
            ),
            const Text(
              " 攝氏度",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey
              )
            )
          ]
        )
      ),
      
      ListenableBuilder(
        listenable: sumController,
        builder: (context, child) => InfoCard(
          title: '本月累計用水',
          color: Colors.green.shade700,
          icon: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              size: 25,
              Icons.calendar_today,
              color: Colors.green.shade700,
            )
          ),
          textSpan: [
            AnimatedFlipCounter(
              fractionDigits: 1,
              value: sumController.value,
              curve: Curves.easeInOutSine,
              duration: const Duration(milliseconds: 600),
              textStyle: themeData.textTheme.titleLarge
            ),
            const Text(
              " 公升",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey
              )
            )
          ]
        )
      ),

      ListenableBuilder(
        listenable: flowController,
        builder: (context, child) => InfoCard(
          title: '用水量目標',
          color: Colors.red.shade400,
          icon: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              size: 30,
              Icons.ads_click,
              color: Colors.red.shade400,
            )
          ),
          textSpan: [
            Text(
              "666",
              style: themeData.textTheme.titleLarge
            ),
            Text(
              " / 234",
              style: themeData.textTheme.titleMedium?.copyWith(
                fontSize: 22
              )
            ),
            const Text(
              " 公升",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey
              )
            )
          ]
        )
      ),

      ListenableBuilder(
        listenable: flowController,
        builder: (context, child) => InfoCard(
          title: '水塔儲水量',
          color: Colors.yellow,
          icon: const SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              size: 30,
              Icons.water_damage,
              color: Colors.yellow,
            )
          ),
          textSpan: [
            Text(
              "INOP",
              style: themeData.textTheme.titleLarge
            ),
            const Text(
              " 公升",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey
              )
            )
          ]
        )
      ),

      const InfoCard(
        title: '全部資料',
        color: Colors.yellow,
        icon: SizedBox(
          width: 30,
          height: 50,
          child: Icon(
            size: 30,
            Icons.water_damage,
            color: Colors.yellow,
          )
        ),
        textSpan: []
      )
    ];

    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          NotificationAPI.instance.showBigTextNotification(
            title: "asd", body: "asd"
          );
        },
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('即時資訊', style: themeData.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 35),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage()
                        ),
                      );
                    } 
                  )
                ],
              ),
              ListenableBuilder(
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
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: cardList.length,
                  itemBuilder: (BuildContext context, int index) => cardList[index],
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 10);
                  }
                )
              )
            ]
          )
        )
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