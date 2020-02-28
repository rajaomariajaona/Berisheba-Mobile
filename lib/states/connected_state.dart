import 'package:berisheba/states/global_state.dart';
import 'package:flutter/widgets.dart';

class ConnectedState extends ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;
  setIsConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      if (!_isConnected)
        GlobalState().navigatorState.currentState.pushNamed("no-internet");
      notifyListeners();
    }
  }

  static final ConnectedState _singleton = ConnectedState._internal();

  factory ConnectedState() {
    return _singleton;
  }

  ConnectedState._internal();
}
