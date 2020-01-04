import 'dart:async';

import 'package:berisheba/config.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class GlobalState extends ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;
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
    } on Exception catch (_) {
      GlobalState().isConnected = false;
    }
    return _channel;
  }

  set isConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      notifyListeners();
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
