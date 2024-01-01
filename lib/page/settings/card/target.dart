import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_water_moblie/core/smart_water_api.dart';
import 'package:smart_water_moblie/main.dart';
import 'package:smart_water_moblie/page/settings/basic.dart';
import 'package:smart_water_moblie/page/settings/card/connect.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/card/temperature.dart';
import 'package:smart_water_moblie/provider/timely.dart';

class TargetSection extends StatefulWidget {
  const TargetSection({super.key});

  @override
  State<TargetSection> createState() => _TargetSectionState();
}

class _TargetSectionState extends State<TargetSection> {
  String? errorMsg;
  double targetValue = 0;
  
  void updateFromServer() async {
    final response = await SmartWaterAPI.instance.getTarget();
    if(!mounted) return;

    if (response.errorMsg != null || response.value == null) {
      targetValue = 0;
      setState(() => errorMsg=response.errorMsg);
      return;
    }

    errorMsg = null;
    response.value = (response.value! < 0) ? 0 : response.value;
    targetValue = response.value!;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateFromServer();
    SmartWaterAPI.instance.state.addListener(updateFromServer);
  }

  @override
  void dispose() {
    super.dispose();
    SmartWaterAPI.instance.state.removeListener(updateFromServer);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
          SectionHeading(
            title: "蓄水目標",
            icon: Icons.water_damage,
            errorMsg: errorMsg
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              WaterBottle(
                levelPercent: targetValue,
                width: mediaQuery.size.width / 3,
                height: mediaQuery.size.width / 3,
                controller: PageController(initialPage: 1),
                duration: const Duration(milliseconds: 0)
              ),
              SizedBox(
                width: mediaQuery.size.width / 1.5 - 90,
                child: Center(
                  child: VolumeIndicator(percent: targetValue)
                )
              ),
              const SizedBox(width: 20),
            ]
          ),
          Slider(
            value: targetValue,
            inactiveColor: Colors.grey,
            onChanged: (errorMsg != null) ? null : (value) =>
              setState(() => targetValue = value),
            onChangeEnd: (value) =>
              SmartWaterAPI.instance.setTarget(target: value)
          ),
          TextButton(
            onPressed: () => showCupertinoDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) => const SizeDialog()
            ),
            style: const ButtonStyle(
              padding: MaterialStatePropertyAll(EdgeInsets.fromLTRB(10, 3, 10, 5))
            ),
            child: Text("變更水塔大小", style: themeData.textTheme.labelMedium)
          ),
          const SizedBox(height: 10)
        ]
      )
    );
  }
}

class VolumeIndicator extends StatelessWidget {
  const VolumeIndicator({
    super.key,
    required this.percent
  });

  final double percent;

  double getVolume() {
    final area = timelyProvider.bottomArea;
    final height = timelyProvider.maxHeight;
    return percent * area * height;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "估計儲水量", style: themeData.textTheme.titleSmall),
            ]
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Text("${getVolume().toStringAsFixed(1)}L", style: themeData.textTheme.labelLarge?.copyWith(
            fontSize: 40
          ))
        )
      ]
    );
  }
}

class SizeDialog extends StatefulWidget {
  const SizeDialog({super.key});

  @override
  State<SizeDialog> createState() => _SizeDialogState();
}

class _SizeDialogState extends State<SizeDialog> {
  final maxHeight = TextEditingController(text: "${timelyProvider.maxHeight}");
  final bottomArea = TextEditingController(text: "${timelyProvider.bottomArea}");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return GestureDetector(
      child: AlertDialog(
        title: const Text('變更水塔規格'),
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: mediaQuery.size.width / 1.4,
              height: mediaQuery.textScaler.scale(40),
              child: TextBox(
                title: "底面積",
                onlyDouble: true,
                suffixString: "cm²",
                controller: bottomArea
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: mediaQuery.size.width / 1.4,
              height: mediaQuery.textScaler.scale(40),
              child: TextBox(
                title: "最高水位",
                onlyDouble: true,
                suffixString: "cm",
                controller: maxHeight
              ),
            )
          ]
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text('保存變更', style: themeData.textTheme.labelMedium?.copyWith(
              color: Colors.blue
            )),
            onPressed: () {
              timelyProvider.setTankSize(
                area: double.tryParse(bottomArea.value.text),
                height: double.tryParse(maxHeight.value.text)
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      }
    );
  }
}
