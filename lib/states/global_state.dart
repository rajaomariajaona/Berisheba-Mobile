import 'dart:async';
import 'dart:io';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class GlobalState extends ChangeNotifier {
  GlobalKey<NavigatorState> _navigatorState;

  set navigatorState(GlobalKey value) {
    _navigatorState = value;
  }

  GlobalKey<NavigatorState> get navigatorState => _navigatorState;

  // App State if the Websocket is connected or not
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  //WebSocket Channel (Listen for messages)
  IOWebSocketChannel _channel;

  IOWebSocketChannel get channel => _channel;
  StreamController<String> _externalStreamController =
      StreamController.broadcast();

  StreamController<String> _internalStreamController =
      StreamController.broadcast();

  StreamController<String> get internalStreamController =>
      _internalStreamController;

  StreamController<String> get externalStreamController =>
      _externalStreamController;

  Future<bool> connect() async {
    bool res;
    try {
      await WebSocket.connect(Config.wsURI).timeout(Duration(seconds: 15));
      _channel = IOWebSocketChannel.connect(Config.wsURI,
          pingInterval: Duration(seconds: 30));
      _channel.stream.listen(
        (msg) {
          _externalStreamController.sink.add(msg);
        },
        onError: (error) {
          res = false;
        },
        onDone: () {
          res = false;
          _channel = null;
        },
      );
      res = true;
      this.refreshAll();
    } catch (_) {
      res = false;
      if (_channel != null) _channel.sink.close();
    }
    this.isConnected = res;
    return res;
  }

  set isConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      if (!_isConnected) _navigatorState.currentState.pushNamed("no-internet");
      notifyListeners();
    }
  }

  bool _hideBottomNavBar = false;

  bool get hideBottomNavBar => _hideBottomNavBar;

  set hideBottomNavBar(bool value) {
    _hideBottomNavBar = value;
    notifyListeners();
  }

  void refreshAll() {
    this.internalStreamController.sink.add("refresh");
  }

  static final GlobalState _singleton = GlobalState._internal();

  factory GlobalState() {
    return _singleton;
  }

  GlobalState._internal();
}
