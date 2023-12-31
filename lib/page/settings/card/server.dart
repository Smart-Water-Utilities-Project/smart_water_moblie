import 'package:flutter/material.dart';

import 'package:smart_water_moblie/core/smart_water_api.dart';
import 'package:smart_water_moblie/page/settings/basic.dart';
import 'package:smart_water_moblie/page/settings/card/connect.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: themeData.colorScheme.primaryContainer
      ),
      child: ListenableBuilder(
        listenable: SmartWaterAPI.instance.state,
        builder: (context, child) => const Column(
          children: [
            SectionHeading(
              title: "主機連線",
              icon: Icons.rss_feed
            ),
            DetailBox(),
            SizedBox(height: 10)
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

  @override
  Widget build(BuildContext context) {
    final websocketState = SmartWaterAPI.instance.state;
    return ListenableBuilder(
      listenable: websocketState,
      builder: (context, child) => LayoutBuilder(
        builder: (context, constraints) {
          switch (websocketState.value) {
            case ConnectionStatus.successful:
              return const SucceussfulCard();
            
            default:
              return const FailedCard();
          }
        }
        
      )
    );
  }
}
/*
AnimatedContainer(
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
*/
class FailedCard extends StatefulWidget {
  const FailedCard({super.key});

  @override
  State<FailedCard> createState() => _FailedCardState();
}

class _FailedCardState extends State<FailedCard> with TickerProviderStateMixin{

  void showDialog() {
    SmartWaterAPI.instance.resetConnection();
        
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
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5),
          width: 5,
          height: mediaQuery.textScaler.scale(50),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20)
          )
        ),
        RichText(
          text: TextSpan(
            children: [
              const WidgetSpan(
                child: Icon(Icons.error)
              ),
              TextSpan(
                text: " 尚未連線至伺服器\n",
                style: themeData.textTheme.labelMedium
              ),
              TextSpan(
                text: " 連接到伺服器之前，多數功能可能無法使用",
                style: themeData.textTheme.labelSmall?.copyWith(
                  color: Colors.grey
                )
              )
            ]
          )
        ),
        const Spacer(),
        TextButton(
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.transparent)
          ),
          onPressed: showDialog,
          child: Text("連線", style: themeData.textTheme.labelMedium?.copyWith(
            color: Colors.blue
          )),
        )
      ]
    );
  }
}

class SucceussfulCard extends StatelessWidget {
  const SucceussfulCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final addrList = SmartWaterAPI.instance.addr?.split(":");
    final clientId = SmartWaterAPI.instance.id;

    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 5,
            height: mediaQuery.textScaler.scale(80),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20)
            )
          ),
          RichText(
            text: TextSpan(
              children: [
                const WidgetSpan(
                  child: Icon(Icons.check_circle)
                ),
                TextSpan(
                  text: " 連線成功\n",
                  style: themeData.textTheme.labelMedium
                ),
                const WidgetSpan(
                  child: Icon(Icons.location_pin)
                ),
                TextSpan(
                  text: " ${addrList!.first}",
                  style: themeData.textTheme.labelMedium
                ),
                TextSpan(
                  text: ":${addrList.last}\n",
                  style: themeData.textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade400, 
                    // fontWeight: FontWeight.normal
                  )
                ),
                const WidgetSpan(
                  child: Icon(Icons.perm_identity)
                ),
                TextSpan(
                  text: " $clientId",
                  style: themeData.textTheme.labelMedium
                )
              ]
            )
          ),
          const Spacer(),
          TextButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.transparent)
            ),
            child: Text("中斷連線", style: themeData.textTheme.labelMedium?.copyWith(
              color: Colors.blue
            )),
            onPressed: () async {
              await SmartWaterAPI.instance.disconnect();
            }
          )
        ]
      );
  }
}