import 'dart:async';
import 'dart:convert';

import 'package:berisheba/tools/widgets/no_internet.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class GlobalState extends ChangeNotifier {

  Future requestToken() async {
    http.post("${Config.baseURI}/device",
      body: {"deviceid" : "${await ImeiPlugin.getImei()}"}
    ).then((result) {
        var storage = FlutterSecureStorage();
      if(result.statusCode == 200){
        storage.write(key: "token", value: json.decode(result.body)["token"]);
      }else{
        storage.delete(key: "token");
      }
    });
  }

  GlobalKey<NavigatorState> _navigatorState;

  set navigatorState(GlobalKey value) {
    _navigatorState = value;
  }

  GlobalKey<NavigatorState> get navigatorState => _navigatorState;

  // App State if the Websocket is connected or not
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  //WebSocket Channel (Listen for messages)
  IOWebSocketChannel _channel;

  IOWebSocketChannel get channel => _channel;
  StreamController<String> _externalStreamController = StreamController.broadcast();

  StreamController<String> _internalStreamController = StreamController.broadcast();

  StreamController<String> get internalStreamController => _internalStreamController;

  StreamController<String> get externalStreamController => _externalStreamController;

  IOWebSocketChannel connect() {
    try {
      _channel = IOWebSocketChannel.connect(Config.wsURI,
          pingInterval: Duration(seconds: 30));
      GlobalState().isConnected = true;
      _channel.stream.listen(
          (msg) {
            _externalStreamController.sink.add(msg);
          },
          onError: (error) {},
          onDone: () {
            GlobalState().isConnected = false;
            _channel = null;
          });
      this.refreshAll();
    } catch (_) {
      if (_channel != null) _channel.sink.close();
      GlobalState().isConnected = false;
    }
    return _channel;
  }

  set isConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      if (!_isConnected)
        _navigatorState.currentState.push(MaterialPageRoute(
          builder: (_context) => NoInternet(),
        ));
      notifyListeners();
    }
  }

  bool _hideBottomNavBar = false;

  bool get hideBottomNavBar => _hideBottomNavBar;

  set hideBottomNavBar(bool value) {
    _hideBottomNavBar = value;
    notifyListeners();
  }

  void refreshAll(){
    this.internalStreamController.sink.add("refresh");
  }

  static final GlobalState _singleton = GlobalState._internal();

  factory GlobalState() {
    return _singleton;
  }

  GlobalState._internal();
}
