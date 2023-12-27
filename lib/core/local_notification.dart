import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:smart_water_moblie/main.dart';
import 'package:smart_water_moblie/page/summary/timelyInfo/summary.dart';

class NotificationAPI {
  NotificationAPI._();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static NotificationAPI? _instance;
  static NotificationAPI get instance {
    _instance ??= NotificationAPI._();
    return _instance!;
  }

  // late BuildContext context;

  Future<void> initizlize() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
    final initializationSettingsDarwin = DarwinInitializationSettings(onDidReceiveLocalNotification: (a, b, c, d) => print(a));
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        final context = appkey.currentState?.context;
        if(context == null) {
          print("context is null");
          return;
        }

        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SummaryPage()));
        
        print(response.payload);
      });
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
      }
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute<void>(builder: (context) => SummaryPage()),
      // );
  }

  Future showBigTextNotification({var id =0,required String title, required String body,
    var payload
  } ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'you_can_name_it_atever21',
      '智慧用水警告',

      // playSound: true,
      // sound: RawResourceAndroidNotificationSound('notification'),
      icon: 'app_icon',
      importance: Importance.max,
      priority: Priority.high,
    );

    var not= NotificationDetails(android: androidPlatformChannelSpecifics,
        // iOS: IOSNotificationDetails()
    );
    await flutterLocalNotificationsPlugin.show(0, title, body, not, payload: "asdasd");
  }

}