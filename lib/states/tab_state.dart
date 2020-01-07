import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';

class TabState extends ChangeNotifier {
  int _index = 0;
  String _titleAppBar = "Berisheba";
  static PageController _controller = PageController(initialPage: 0);
  int get index => _index;
  String get titleAppBar => _titleAppBar;
  static PageController get controllerPage => _controller;
  void changeIndex(int index) {
    _index = index;
    _titleAppBar = index == 0 ? "Berisheba" : Config.routesName[index];
    notifyListeners();
  }

  void changePage(int index) {
    if (index == _index - 1 || index == _index + 1)
      _controller.animateToPage(index,
          duration: Duration(seconds: 1), curve: Curves.ease);
    else
      _controller.jumpToPage(index);
  }
}
