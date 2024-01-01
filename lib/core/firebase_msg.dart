import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_water_moblie/core/local_notification.dart';

class FireBaseAPI {
  FireBaseAPI._();

  static FireBaseAPI? _instance;
  static FireBaseAPI get instance {
    _instance ??= FireBaseAPI._();
    return _instance!;
  }

  String? token;

  Future<void> toggleWaterLeakNotify(bool value) async {
    final instance = FirebaseMessaging.instance;
    if (value) {
      await instance.subscribeToTopic("waterLeakage");
    } else {
      await instance.unsubscribeFromTopic("waterLeakage");
    }
  }

  Future<void> toggleWaterLimitNotify(bool value) async {
    final instance = FirebaseMessaging.instance;
    if (value) {
      await instance.subscribeToTopic("waterLimit");
    } else {
      await instance.unsubscribeFromTopic("waterLimit");
    }
  }

  Future<void> togglePipeFreezeNotify(bool value) async {
    final instance = FirebaseMessaging.instance;
    if (value) {
      await instance.subscribeToTopic("PipeFreeze");
    } else {
      await instance.unsubscribeFromTopic("PipeFreeze");
    }
  }
  
  Future<void> toggleDevTestNotify(bool value) async {
    final instance = FirebaseMessaging.instance;
    if (value) {
      await instance.subscribeToTopic("devTest");
    } else {
      await instance.unsubscribeFromTopic("devTest");
    }
  }

  Future<void> initNotification() async {
    final prefs = await SharedPreferences.getInstance();
    await Firebase.initializeApp();
    await reqPermission();
    await toggleWaterLeakNotify(prefs.getBool("isLeakNotifyEnable")??false);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    token = await FirebaseMessaging.instance.getToken();

    // print("FireBase Token = $_token");

    FirebaseMessaging.instance.onTokenRefresh
    // This callback is fired at each app startup and whenever a new token is generated.
    .listen((fcmToken) => token = fcmToken)
    // Error getting token.
    .onError((err) => token = null);

    FirebaseMessaging.onMessage.listen(onMessage);
  }

  Future<void> reqPermission() async {
    /*NotificationSettings settings = */ await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    
  }

  static void onMessage(RemoteMessage message) {
    // print('Got a message whilst in the foreground!');

    final topic = message.from;
    // print(topic);
    switch(topic) {
      default: {
        NotificationAPI.instance.showBigTextNotification(
          title: message.notification?.title ?? "", 
          body: message.notification?.body ?? ""
        );
      }
    }
    message.messageId;

    if (message.notification != null) {
      debugPrint('Message also contained a notification: ${message.notification}');
    }
  }
}