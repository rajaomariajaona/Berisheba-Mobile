import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/parametres.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/cast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalleState extends ChangeNotifier {
  bool __isLoading = false;
  bool get isLoading => __isLoading;
  set _isLoading(bool val) {
    if (val != __isLoading) {
      __isLoading = val;
      notifyListeners();
    }
  }

  Map<int, dynamic> _listSalleByIdSalle = {};

  Map<int, dynamic> get listSalleByIdSalle => _listSalleByIdSalle;

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

  bool allSelected() =>
      this._sallesFiltered.length == _listIdSalleSelected.length;

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

  bool _isSearchingSalle = false;

  set isSearchingSalle(bool value) {
    _isSearchingSalle = value;
    if (!_isSearchingSalle) {
      this.searchData("");
    }
    notifyListeners();
  }

  bool get isSearchingSalle => _isSearchingSalle;

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
      _isLoading = true;
      Dio _dio = await RestRequest().getDioInstance();
      try {
        var response = await _dio.get("/salles");
        var data = response?.data;
        _listSalleByIdSalle = Cast.stringToIntMap(data["data"], (value) => value);
      } catch (error) {
        print(error);
        if (error is DioError && error.type == DioErrorType.RESPONSE) {
          print(error);
        }
      }
      _salles = _listSalleByIdSalle.values.toList();
      _sallesFiltered = _salles;
      await this.sort();
    } catch (_) {
      print(_.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeDatas() async {
    Dio _dio = await RestRequest().getDioInstance();
    _dio.options.headers["deletelist"] = json.encode(_listIdSalleSelected);
    try {
      Response response = await _dio.delete("/salles");
      GlobalState().channel.sink.add("salle delete");
      this.isDeletingSalle = false;
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> removeData(int idSalle) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      Response response = await _dio.delete("/salles/$idSalle");
      GlobalState().channel.sink.add("salle delete");
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> saveData(dynamic data) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.post("/salles", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> modifyData(dynamic data, {@required int idSalle}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.put("/salles/$idSalle", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  Future<void> sort() async {
    _sallesFiltered.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomSalle"].toLowerCase().compareTo(b["nomSalle"].toLowerCase())
          : b["nomSalle"].toLowerCase().compareTo(a["nomSalle"].toLowerCase());
    });
    _salles.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomSalle"].toLowerCase().compareTo(b["nomSalle"].toLowerCase())
          : b["nomSalle"].toLowerCase().compareTo(a["nomSalle"].toLowerCase());
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
      if (msg == "salle") {
        fetchData();
      }
      if (msg == "salle delete") {
        //TODO: Optimize this
        ReservationState().fetchDataByWeekRange("1-53");
      }
    });
    GlobalState().internalStreamController.stream.listen((msg) {
      if (msg == "refresh") {
        fetchData();
      }
    });
  }

  SalleState() {
    asyncConstructor();
  }
}

class Salle {
  const Salle({@required this.idSalle, @required this.nomSalle});
  final int idSalle;
  final String nomSalle;
  @override
  operator ==(salle) =>
      salle is Salle && salle.idSalle == idSalle && salle.nomSalle == nomSalle;

  int get hashCode => idSalle.hashCode ^ nomSalle.hashCode;
}
