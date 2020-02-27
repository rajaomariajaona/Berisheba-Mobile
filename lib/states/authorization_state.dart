import 'package:flutter/widgets.dart';

class AuthorizationState extends ChangeNotifier {
  bool _isAuthorized = true;
  set isAuthorized(bool val) {
    if (_isAuthorized != val) {
      _isAuthorized = val;
      notifyListeners();
    }
  }
  bool get isAuthorized => _isAuthorized;

  static final AuthorizationState _singleton = AuthorizationState._internal();

  factory AuthorizationState() {
    return _singleton;
  }

  AuthorizationState._internal();
}
