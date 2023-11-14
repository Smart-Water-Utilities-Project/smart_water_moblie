import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

enum ConnectState {
  never, successful, failed, connecting
}

extension DateTimeConvert on DateTime {
  double toMinutesSinceEpoch() {
    return millisecondsSinceEpoch / (60 * 1000);
  }
}

class WebsocketAPI extends ChangeNotifier{
  WebSocket? client;
  int clientID = -1;
  bool verified = false;
  String? serverAddress;
  ConnectState get state => _state;
  ConnectState _state = ConnectState.never;

  static final dataReciever = StreamController<List<dynamic>>();
  final dataRecieveStream = dataReciever.stream.asBroadcastStream();

  Future<String?> connect(String url) async {
    verified = false;
    await client?.close();
    
    serverAddress = url;
    _state = ConnectState.connecting;
    notifyListeners();
    try { client = await WebSocket.connect("ws://$url"); }
    on SocketException catch (error) {
      _state = ConnectState.failed;
      return error.message;
    } on ArgumentError catch (error) {
      _state = ConnectState.failed;
      return "無效的端口: ${(error.message as String).split(' ').last}";
    } on FormatException catch (_) {
      _state = ConnectState.failed;
      return "無效的網址";
    } on Exception {
      _state = ConnectState.failed;
      return "發生未知錯誤";
    }

    _state = ConnectState.successful;
    client?.asBroadcastStream().listen(streamListener);
    notifyListeners();
    return null;
  }

  void streamListener(dynamic event) {
    switch (event.runtimeType) {
      case String:
        final data = jsonDecode(event) as Map<String, dynamic>;
        switch(data["op"]) { // Check op code
          case 0: onGeneral(data); break;
          case 1: onHello(data); break;
        }
        break;
    }
  }

  void onHello(Map<String, dynamic> map) {
    final data = map["d"] as Map<String, dynamic>;
    final exceptedKeys = ["id"];
    if (!exceptedKeys.every(data.keys.contains)) {
      print("包含的資訊不對");
      return;
    }
    clientID = data["id"];

    final returnData = {
      "op": 2,
      "d": {
        "dt": "mobile_app"
      }
    };

    client?.add(jsonEncode(returnData));
  }

  void onGeneral(Map<String, dynamic> map) {
    switch(map["t"] as String) {
      case "REQUEST_HISTORY_DATA_ACK": {
        dataReciever.sink.add(map["d"]);
      }

    }
  }


  void getData((DateTime, DateTime) range) async {
    Map<String, dynamic> uploadData = {
      "op": 0,
      "d": {
        "s": range.$1.toMinutesSinceEpoch().floor(),
        "e": range.$2.toMinutesSinceEpoch().floor()
      },
      "t": "REQUEST_HISTORY_DATA"
    };

    client?.add(jsonEncode(uploadData));
  }

  Future<void> disconnect() async {
    client = null;
    clientID = -1;
    verified = false;
    serverAddress = null;
    _state = ConnectState.never;
    notifyListeners();
    await client?.close();
  }
}

WebsocketAPI wsAPI = WebsocketAPI(); 