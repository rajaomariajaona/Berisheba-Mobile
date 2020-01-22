import 'package:flutter/material.dart';

class MaterielState extends ChangeNotifier {
  bool _isSearching = false;
  get isSearching => _isSearching;
  set isSearching(bool value){
    this._isSearching = value;
    notifyListeners();
  }
}