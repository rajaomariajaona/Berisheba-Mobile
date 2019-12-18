import 'package:berisheba/config.dart';
import 'package:flutter/material.dart';

class TabState extends ChangeNotifier {
  int _index = 0;
  String _titleAppBar = "Berisheba";

  int get index => _index;
  String get titleAppBar => _titleAppBar;
  void changeIndex(int index) {
    _index = index;
    _titleAppBar = index == 0 ? "Berisheba" : Config.routesName[index];
    notifyListeners();
  }
}
