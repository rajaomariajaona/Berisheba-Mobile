import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/parametres.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SalleState extends ChangeNotifier {
  Map<String, dynamic> _listSalleByIdSalle = {};

  Map<String, dynamic> get listSalleByIdSalle => _listSalleByIdSalle;

  //Global key for Indicator state use for refresh data
  final _refreshIndicatorStateSalle = GlobalKey<RefreshIndicatorState>();

  get refreshIndicatorStateSalle => _refreshIndicatorStateSalle;

  //Salle id List of Selected;
  List<int> _listIdSalleSelected = [];

  List<int> get idSalleSelected => _listIdSalleSelected;

  //Add Id Salle to Selected List
  void addSelected(int idSalle) {
    if (!_listIdSalleSelected.contains(idSalle))
      _listIdSalleSelected.add(idSalle);
    notifyListeners();
  }

  //TODO : clean search

  void deleteSelected(int idSalle) {
    if (_listIdSalleSelected.contains(idSalle))
      _listIdSalleSelected.remove(idSalle);
    notifyListeners();
  }

  void deleteAllSelected() {
    _listIdSalleSelected.clear();
    notifyListeners();
  }

  void addAllSelected() {
    _listIdSalleSelected.clear();
    this._salles.forEach((v) {
      _listIdSalleSelected.add(v["idSalle"]);
    });
    notifyListeners();
  }

  bool allSelected() => this._salles.length == _listIdSalleSelected.length;

  bool emptySelected() => _listIdSalleSelected.isEmpty;

  bool isSelected(int idSalle) => _listIdSalleSelected.contains(idSalle);

  bool _isDeletingSalle = false;

  set isDeletingSalle(bool value) {
    if (!value) deleteAllSelected();
    _isDeletingSalle = value;
    GlobalState().hideBottomNavBar = _isDeletingSalle;
    notifyListeners();
  }

  bool get isDeletingSalle => _isDeletingSalle;

  bool _isNotReverse = false;

  bool get isNotReverse => _isNotReverse;

  //Local Storage Variable
  SharedPreferences _sharedPreferences;

  Future<void> setIsReverse(bool isNotReverse) async {
    await _sharedPreferences.setBool(Parametres.salleSort, isNotReverse);
    this._isNotReverse = isNotReverse;
    await this.sort();
  }

  //Salle List getter
  List<dynamic> get liste => _sallesFiltered;
  List<dynamic> _salles = [];
  List<dynamic> _sallesFiltered = [];

  Future<void> fetchData() async {
    try {
      _listSalleByIdSalle = await jsonDecode(
          (await http.get(Config.apiURI + "salles")).body)["data"];
      _salles = _listSalleByIdSalle.values.toList();
      _sallesFiltered = _salles;
      await this.sort();
      GlobalState().isConnected = true;
    } on SocketException catch (_) {
      GlobalState().isConnected = false;
    } on Exception catch (_) {
      print(_.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<bool> removeDataInDatabase() async {
    http.Response response = await http.delete(Config.apiURI + "salles",
        headers: {"deletelist": _listIdSalleSelected.toString()});
    if (response.statusCode == 204) {
      return true;
    } else {
      print(response.statusCode);
      print(response.body);
      return false;
    }
  }

  Future<void> sort() async {
    _sallesFiltered.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomSalle"].toLowerCase().compareTo(b["nomSalle"].toLowerCase())
          : b["nomSalle"]
          .toLowerCase()
          .compareTo(a["nomSalle"].toLowerCase());
    });
    _salles.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomSalle"].toLowerCase().compareTo(b["nomSalle"].toLowerCase())
          : b["nomSalle"]
          .toLowerCase()
          .compareTo(a["nomSalle"].toLowerCase());
    });
    notifyListeners();
  }

  //Method for handling search
  Future<void> searchData(String search) async {
    search = search.trim();
    if (search.isNotEmpty)
      _sallesFiltered = _salles.where((v) {
        return v["nomSalle"]
            .toString()
            .toLowerCase()
            .contains(search.toLowerCase()) ||
            v["prenomSalle"]
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase());
      }).toList();
    else
      _sallesFiltered = _salles;
    notifyListeners();
  }

  //Methode for async Constructor
  Future<void> asyncConstructor() async {
    await SharedPreferences.getInstance().then((pref) async {
      this._sharedPreferences = pref;
      if (!this._sharedPreferences.containsKey(Parametres.salleSort))
        this._sharedPreferences.setBool(Parametres.salleSort, true);
    }).then((_) {
      this._isNotReverse = _sharedPreferences.getBool(Parametres.salleSort);
    });
    await fetchData();
    GlobalState().externalStreamController.stream.listen((msg) {
      //Reload data
      print(msg);
      if (msg == "salle") {
        fetchData();
      }
    });
  }

  SalleState() {
    asyncConstructor();
  }
}
