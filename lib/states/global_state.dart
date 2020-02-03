import 'dart:async';

import 'package:berisheba/tools/widgets/no_internet.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class GlobalState extends ChangeNotifier {
  GlobalKey<NavigatorState> _navigatorState;
  bool _isAuthorized = true;
  set isAuthorized(bool val) {
    if (_isAuthorized != val) {
      _isAuthorized = val;
      notifyListeners();
    }
  }

  bool get isAuthorized => _isAuthorized;

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
  StreamController<String> _externalStreamController =
      StreamController.broadcast();

  StreamController<String> _internalStreamController =
      StreamController.broadcast();

  StreamController<String> get internalStreamController =>
      _internalStreamController;

  StreamController<String> get externalStreamController =>
      _externalStreamController;

  Future<bool> connect() async {
    try {
      _channel = IOWebSocketChannel.connect(Config.wsURI,
          pingInterval: Duration(seconds: 30));
      this.isConnected = true;
      _channel.stream.listen(
        (msg) {
          _externalStreamController.sink.add(msg);
        },
        onError: (error) {
          this.isConnected = false;
        },
        onDone: () {
          this.isConnected = false;
          _channel = null;
        },
      );
      this.refreshAll();
    } catch (_) {
      if (_channel != null) _channel.sink.close();
      this.isConnected = false;
    }
    return this.isConnected;
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

  void refreshAll() {
    this.internalStreamController.sink.add("refresh");
  }

  static final GlobalState _singleton = GlobalState._internal();

  factory GlobalState() {
    return _singleton;
  }

  GlobalState._internal();
}
