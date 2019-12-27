import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  bool _hideBottomNavBar = false;

  bool get hideBottomNavBar => _hideBottomNavBar;

  set hideBottomNavBar(bool value) {
    _hideBottomNavBar = value;
    notifyListeners();
  }
}
