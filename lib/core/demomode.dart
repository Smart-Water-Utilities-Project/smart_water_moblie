import 'dart:math';
import 'dart:async';

import 'package:smart_water_moblie/page/summary/summary.dart';

class DemoMode {
  Timer? waterflowUpdateTimer;

  void waterflow() {
    const oneSec = Duration(milliseconds: 1000);
    waterflowUpdateTimer = Timer.periodic(oneSec, (Timer t) {
      sumController.set(sumController.value + 1.3);
      tempController.set(Random().nextDouble() * 32);
      flowController.set(Random().nextInt(1000).toDouble());
    });
  }
}
