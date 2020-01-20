import 'dart:async';

import 'package:berisheba/home_page/no_internet.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class GlobalState extends ChangeNotifier {
  GlobalKey _client = GlobalKey();

  GlobalKey get client => _client;

  // The Matrial app Navigator State

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
  StreamController<String> _streamController = StreamController.broadcast();

  StreamController<String> get streamController => _streamController;

  IOWebSocketChannel connect() {
    try {
      _channel = IOWebSocketChannel.connect(Config.wsURI,
          pingInterval: Duration(seconds: 30));
      GlobalState().isConnected = true;
      _channel.stream.listen(
          (msg) {
            _streamController.sink.add(msg);
          },
          onError: (error) {},
          onDone: () {
            GlobalState().isConnected = false;
            _channel = null;
          });
    } catch (_) {
      if (_channel != null) _channel.sink.close();
      GlobalState().isConnected = false;
    }
    return _channel;
  }

  set isConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      notifyListeners();
      if (!_isConnected)
        _navigatorState.currentState.push(MaterialPageRoute(
          builder: (_context) => NoInternet(),
        ));
    }
  }

  bool _hideBottomNavBar = false;

  bool get hideBottomNavBar => _hideBottomNavBar;

  set hideBottomNavBar(bool value) {
    _hideBottomNavBar = value;
    notifyListeners();
  }

  static final GlobalState _singleton = GlobalState._internal();

  factory GlobalState() {
    return _singleton;
  }

  GlobalState._internal();
}
