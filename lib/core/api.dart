import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:smart_water_moblie/core/extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ConnectionStatus {
  never,
  failed,
  connecting,
  successful,
  autoconnect;
}

class WebSocketAPI{
  WebSocketAPI._();

  static WebSocketAPI? _instance;
  static WebSocketAPI get instance {
    _instance ??= WebSocketAPI._();
    return _instance!;
  }

  static WebSocket? client;
  CancelableOperation? connection;

  int? _id;
  String? _addr;
  bool _verify = false;
  final ValueNotifier<int> _retryCount = ValueNotifier(0) ;
  final ValueNotifier<ConnectionStatus> _state = ValueNotifier(ConnectionStatus.never);

  int? get id => _id;
  ValueNotifier<int> get retryCount => _retryCount;
  String? get addr => _addr;
  bool get verify => _verify;
  ValueNotifier<ConnectionStatus> get state => _state;

  static final chartDataReciever = StreamController<List<dynamic>>();
  final chartDataRecieveStream = chartDataReciever.stream.asBroadcastStream();

  static final timelyDataReciever = StreamController<Map<String, dynamic>>();
  final timelyDataRecieveStream = timelyDataReciever.stream.asBroadcastStream();

  Future<String?> _connect(String url) async {
    try{
      client = await WebSocket.connect("ws://$url/ws");
    } on SocketException catch (error) {
      setStatusSafe(ConnectionStatus.failed);
      return error.message;
    } on ArgumentError catch (error) {
      setStatusSafe(ConnectionStatus.failed);
      return "無效的端口: ${(error.message as String).split(' ').last}";
    } on FormatException catch (_) {
      setStatusSafe(ConnectionStatus.failed);
      return "無效的網址";
    } on Exception {
      setStatusSafe(ConnectionStatus.failed);
      return "發生未知錯誤";
    }

    return null;
  }

  // Do not set status while auto connecting to prevent splash on summary screen
  void setStatusSafe(ConnectionStatus status) {
    if (_state.value == ConnectionStatus.autoconnect) return;
    _state.value = status;
  }

  Future<String?> connect(String url) async {
    disconnect();
    setStatusSafe(ConnectionStatus.connecting);

    final process = _connect(url);
    try {
      connection = CancelableOperation.fromFuture(process);
      await process.timeout(const Duration(seconds: 3));
      if (connection?.isCanceled??true) {return "連線已取消";}
    } on TimeoutException catch (_) {
      if (connection?.isCanceled??true) {return "連線已取消";}
      setStatusSafe(ConnectionStatus.failed);
      return "連線逾時";
    }

    final result = await process;
    if (result == null) {
      _addr = url;
      client?.asBroadcastStream().listen(
        onData, onDone: onDone, onError: onError
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lastConnectIP', url);

      setStatusSafe(ConnectionStatus.successful);

      return null;
    }

    return result;
  }

  void onDone() async {
    debugPrint('ws channel closed');
    _id = -1;
    _addr = null;
    _verify = false;
    _state.value = ConnectionStatus.failed;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('lastConnectIP');
    if (url == null) return;
    reteyConnect(url:url);
  }

  void onError(error) {
    debugPrint('ws error $error');
  }

  void onData(dynamic event) {
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

      case "SENSOR_DATA_FORWARD": { // 即時流量
        timelyDataReciever.sink.add(map["d"]);
      }
    }
  }

  Future<void> getData((DateTime, DateTime) range) async {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('lastConnectIP');
  }

  Future<void> resetConnection() async {
    state.value = ConnectionStatus.never;
    await connection?.cancel();
    disconnect();
    client = null;
  }

  Future<void> reteyConnect({String? url, int count=5}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    url ??= prefs.getString('lastConnectIP');
    if (url == null) return;

    _state.value = ConnectionStatus.autoconnect;
    _retryCount.value = count;
    if (count <= 0) { 
      state.value = ConnectionStatus.failed;
      return;
    }

    final result = await instance.connect(url);
    if (result != null) {
      return reteyConnect(url: url, count: count-1);
    }

    _state.value = ConnectionStatus.successful;
    return;
  }

}

class HttpAPI{
  HttpAPI._();

  static HttpAPI? _instance;
  static HttpAPI get instance {
    _instance ??= HttpAPI._();
    return _instance!;
  }

  static Future<Response> getHistory((DateTime, DateTime) range) async {
    final startTs = range.$1.toMinutesSinceEpoch().floor();
    final endTs = range.$2.toMinutesSinceEpoch().floor();
    final uri = Uri.parse("http://192.168.1.110:5678/history?start=$startTs&end=$endTs");
    return await http.get(uri);
  }

  static Future<bool?> getVavleState() async {
    final uri = Uri.parse("http://192.168.1.110:5678/waterValve");
    final result = await http.get(uri);
    final resultMap = jsonDecode(result.body);

    print(resultMap["status"]);

    return resultMap["status"];

  }

  static Future<bool?> setVavleState(bool value) async {
    final payload = jsonEncode({"status": "$value"});
    final uri = Uri.parse("http://192.168.1.110:5678/waterValve");
    try{ 
      await http.put(uri, body: payload);
    }on Exception catch (error) {
      return null;
    }
    return value;
  }

}