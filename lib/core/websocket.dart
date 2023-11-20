import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:smart_water_moblie/core/extension.dart';

enum ConnectionStatus {
  never, successful, failed, connecting
}

class WebSocketAPI{
  WebSocketAPI._();

  static WebSocketAPI? _instance;
  static WebSocketAPI get instance {
    if (_instance == null) {
      _instance = WebSocketAPI._();
    }
    return _instance!;
  }

  static WebSocket? client;
  CancelableOperation? connection;

  int? _id;
  String? _addr;
  bool _verify = false;
  final ValueNotifier<ConnectionStatus> _state = ValueNotifier(ConnectionStatus.never);

  int? get id => _id;
  String? get addr => _addr;
  bool get verify => _verify;
  ValueNotifier<ConnectionStatus> get state => _state;

  static final chartDataReciever = StreamController<List<dynamic>>();
  final chartDataRecieveStream = chartDataReciever.stream.asBroadcastStream();

  static final timelyDataReciever = StreamController<Map<String, dynamic>>();
  final timelyDataRecieveStream = timelyDataReciever.stream.asBroadcastStream();

  Future<String?> _connect(String url) async {
    try{
      client = await WebSocket.connect("ws://$url");
    } on SocketException catch (error) {
      _state.value = ConnectionStatus.failed;
      return error.message;
    } on ArgumentError catch (error) {
      _state.value = ConnectionStatus.failed;
      return "無效的端口: ${(error.message as String).split(' ').last}";
    } on FormatException catch (_) {
      _state.value = ConnectionStatus.failed;
      return "無效的網址";
    } on Exception {
      _state.value = ConnectionStatus.failed;
      return "發生未知錯誤";
    } 
    return null;
  }

  Future<String?> connect(String url) async {
    // await client?.close();
    _addr = url;
    _verify = false;
    _state.value = ConnectionStatus.connecting;

    final process = _connect(url);
    try {
      connection = CancelableOperation.fromFuture(
        process,
        onCancel: () {}
      );
      await process.timeout(const Duration(seconds: 3));
      if (connection?.isCanceled??true) {return null;}
    } on TimeoutException catch (_) {
      if (connection?.isCanceled??true) {return null;}
      _state.value = ConnectionStatus.failed;
      return "連線逾時";
    } 

    final result = await process;
    if (result == null) {
      _state.value = ConnectionStatus.successful;
      client?.asBroadcastStream().listen(streamListener);
      return null;
    }
    return result;
    
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
      debugPrint("包含的資訊不對");
      return;
    }
    _id = data["id"];

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
        chartDataReciever.sink.add(map["d"]);
      }

      case "SENSOR_DATA_FORWARD": {
        timelyDataReciever.sink.add(map["d"]);
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
    _id = -1;
    _addr = null;
    _verify = false;
    _state.value = ConnectionStatus.never;
    await client?.close();
  }

  void resetConnection() async {
    state.value = ConnectionStatus.never;
    await connection?.cancel();
    disconnect();
    client = null;
  }

}