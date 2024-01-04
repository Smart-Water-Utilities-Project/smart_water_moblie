import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:smart_water_moblie/core/extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_water_moblie/page/summary/article/article.dart';

enum ConnectionStatus {
  never,
  failed,
  connecting,
  successful,
  autoconnect;
}

class SmartWaterAPI{
  SmartWaterAPI._();

  static SmartWaterAPI? _instance;
  static SmartWaterAPI get instance {
    _instance ??= SmartWaterAPI._();
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

  static const String _articleEndPoints = "https://smart-water-utilities-project.github.io/smart_water_page/article/";
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
    if (event.runtimeType == String) {
      final data = jsonDecode(event);
      switch(data["op"]) { // Check op code
        case 0: onGeneral(data); break;
        case 1: onHello(data); break;
      }
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
    switch(map["t"] as String?) {
      case "REQUEST_HISTORY_DATA_ACK": { // Departured
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

  // HTTP protocol
  Future<HttpAPIResponse<dynamic>> getHistory((DateTime, DateTime) range) async {
    final startTs = range.$1.toMinutesSinceEpoch().floor();
    final endTs = range.$2.toMinutesSinceEpoch().floor();
    final uri = Uri.tryParse("http://$_addr/history?start=$startTs&end=$endTs");

    if (uri==null || _addr==null || _state.value != ConnectionStatus.successful) {
      return HttpAPIResponse.error("尚未連線至伺服器");
    }

    try{
      final result = await http.get(uri)
        .timeout(const Duration(seconds: 5));
      // debugPrint(result.body);
      return HttpAPIResponse(
        value: jsonDecode(result.body),
        statusCode: result.statusCode,
      );
    } on ArgumentError catch (_) {
      return HttpAPIResponse.error("無法連線至伺服器");
    } on TimeoutException catch (_) {
      return HttpAPIResponse.error("伺服器連線逾時");
    }
  }

  Future<HttpAPIResponse<bool?>> getVavleState() async {
    final uri = Uri.tryParse("http://$_addr/waterValve");
    if (uri==null || _addr == null || _state.value != ConnectionStatus.successful) {
      return HttpAPIResponse.error("在連線到伺服器前，您無法變更部分項目");
    }

    try{
      final result = await http.get(uri)
        .timeout(const Duration(seconds: 5));
        // print(result.body);
      return HttpAPIResponse(
        statusCode: result.statusCode,
        value: jsonDecode(result.body)["status"],
      );
      
    } on ArgumentError catch (_) {
      return HttpAPIResponse.error("無法連線至伺服器");
    } on TimeoutException catch (_) {
      return HttpAPIResponse.error("伺服器連線逾時");
    }
  }

  Future<HttpAPIResponse<bool?>> setVavleState(bool value) async {
    final payload = jsonEncode({"status": value});
    final uri = Uri.tryParse("http://$_addr/waterValve");

    if (uri == null || _addr == null || _state.value != ConnectionStatus.successful) {
      return HttpAPIResponse.error("無法設定水閥狀態，尚未連線至伺服器");
    }

    try{
      final result = await http.put(uri, body: payload);
      if (result.body.isNotEmpty) {
        return HttpAPIResponse.error("API炸了, YFHD 的 Skill issue");
      }

      return HttpAPIResponse(
        value: value,
        statusCode: result.statusCode,
      );

    } on ArgumentError catch (_) {
      return HttpAPIResponse.error("尚未連線至伺服器");
    } on TimeoutException catch (_) {
      return HttpAPIResponse.error("伺服器連線逾時");
    }
  }

  Future<HttpAPIResponse<Response?>> setLimit({int? daily, monthly}) async {
    final uri = Uri.tryParse("http://$_addr/waterLimit");
    final payload = jsonEncode({"daily_limit": daily, "monthly_limit": monthly});

    if (uri==null || _addr==null || _state.value != ConnectionStatus.successful) {
      return HttpAPIResponse.error("尚未連線至伺服器");
    }

    try{
      final result = await http.put(uri, body: payload)
        .timeout(const Duration(seconds: 5));
      return HttpAPIResponse(
        value: result,
        statusCode: result.statusCode,
      );
    } on ArgumentError catch (_) {
      return HttpAPIResponse.error("無法連線至伺服器");
    } on TimeoutException catch (_) {
      return HttpAPIResponse.error("伺服器連線逾時");
    }
  }

  Future<HttpAPIResponse<(int, int)?>> getLimit() async {
    final uri = Uri.tryParse("http://$_addr/waterLimit");

    if (uri==null || _addr==null || _state.value != ConnectionStatus.successful) {
      return HttpAPIResponse.error("在連線到伺服器前，您無法變更部分項目");
    }

    try{
      final result = await http.get(uri)
        .timeout(const Duration(seconds: 5));

      final dictResp = jsonDecode(result.body);
      print(dictResp);
      return HttpAPIResponse(
        value: (dictResp["daily_limit"], dictResp["monthly_limit"]),
        statusCode: result.statusCode,
      );
    } on ArgumentError catch (_) {
      return HttpAPIResponse.error("無法連線至伺服器");
    } on TimeoutException catch (_) {
      return HttpAPIResponse.error("伺服器連線逾時");
    }
  }

  Future<HttpAPIResponse<double?>> getTarget() async {
    final uri = Uri.tryParse("http://$_addr/waterDistTarget");

    if (uri==null || _addr==null || _state.value != ConnectionStatus.successful) {
      return HttpAPIResponse.error("在連線到伺服器前，您無法變更部分項目");
    }

    try{
      final result = await http.get(uri)
        .timeout(const Duration(seconds: 5));

      final dictResp = jsonDecode(result.body);
      dictResp["target"] = (dictResp["target"] == -1) ? 0.0 : dictResp["target"]; // ERr0R HaNdLiNg 
      return HttpAPIResponse(
        value: dictResp["target"],
        statusCode: result.statusCode,
      );
    } on ArgumentError catch (_) {
      return HttpAPIResponse.error("無法連線至伺服器");
    } on TimeoutException catch (_) {
      return HttpAPIResponse.error("伺服器連線逾時");
    }
  } 

  Future<HttpAPIResponse<Response?>> setTarget({required double target}) async {
    final uri = Uri.tryParse("http://$_addr/waterDistTarget");
    final payload = jsonEncode({"target": target});

    if (uri==null || _addr==null || _state.value != ConnectionStatus.successful) {
      return HttpAPIResponse.error("尚未連線至伺服器");
    }

    try{
      final result = await http.put(uri, body: payload)
        .timeout(const Duration(seconds: 5));
      return HttpAPIResponse(
        value: result,
        statusCode: result.statusCode,
      );
    } on ArgumentError catch (_) {
      return HttpAPIResponse.error("無法連線至伺服器");
    } on TimeoutException catch (_) {
      return HttpAPIResponse.error("伺服器連線逾時");
    }
  }

  // Article API
  Future<List<ArticleCover>> listArticle() async {
    final uri = Uri.parse("$_articleEndPoints/main.json");
    final response = jsonDecode((await http.get(uri)).body);

    if (response["articles"] == null) return [];
    final article = response["articles"] as List<dynamic>;

    return article.map((map) => 
      ArticleCover(
        lore: map["lore"],
        title: map["title"],
        articleId: map["id"],
        coverUrl: map["cover_url"]
      )
    ).toList();
  }

  Future<JsonWidgetData> getArticle(String id) async {
    final uri = Uri.parse("$_articleEndPoints/$id");
    final response = jsonDecode((await http.get(uri)).body);
    return JsonWidgetData.fromDynamic(response);
  }
}

class Date {
  static (DateTime, DateTime) reqDay({int daysOffset = 0}) {
    final now = DateTime.now();

    final startTime = DateTime(now.year, now.month, now.day-daysOffset);
    final endTime = startTime.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    return (startTime, endTime);
  }

  static (DateTime, DateTime) reqWeek({int weekOffset = 0}) {
    final now = DateTime.now();

    final startTime = now.subtract(Duration(days: now.weekday + weekOffset*7)).add(const Duration(days: 1));
    final endTime = startTime.add(const Duration(days: 8)).subtract(const Duration(milliseconds: 1));
    
    return (startTime, endTime);
  }

  static (DateTime, DateTime) reqMonth({int monthOffset = 0}) {
    final now = DateTime.now();

    final startTime = DateTime(now.year, now.month-monthOffset, 1);
    final endTime = DateTime(now.year, now.month-monthOffset+1, 1).subtract(const Duration(milliseconds: 1));

    return (startTime, endTime);
  }
}

class HttpAPIResponse<T> {
  HttpAPIResponse({
    this.errorMsg,
    required this.value,
    required this.statusCode,
  });

  final String? errorMsg;
  final int statusCode;
  T value;

  static HttpAPIResponse<Null> error(String message) => HttpAPIResponse(
    value: null,
    statusCode: 100,
    errorMsg: message
  );

  static HttpAPIResponse<Response> fromResponse(Response response) => HttpAPIResponse(
    value: response,
    statusCode: response.statusCode,
  );
}

