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

class UstensileState extends ChangeNotifier {
  bool __isLoading = false;
  bool get isLoading => __isLoading;
  set _isLoading(bool val) {
    if (val != __isLoading) {
      __isLoading = val;
      notifyListeners();
    }
  }

  Map<int, dynamic> _listUstensileByIdUstensile = {};

  Map<int, dynamic> get listUstensileByIdUstensile => _listUstensileByIdUstensile;

  //Global key for Indicator state use for refresh data
  final _refreshIndicatorStateUstensile = GlobalKey<RefreshIndicatorState>();

  get refreshIndicatorStateUstensile => _refreshIndicatorStateUstensile;

  //Ustensile id List of Selected;
  List<int> _listIdUstensileSelected = [];

  List<int> get idUstensileSelected => _listIdUstensileSelected;

  //Add Id Ustensile to Selected List
  void addSelected(int idUstensile) {
    if (!_listIdUstensileSelected.contains(idUstensile))
      _listIdUstensileSelected.add(idUstensile);
    notifyListeners();
  }

  //TODO : clean search

  void deleteSelected(int idUstensile) {
    if (_listIdUstensileSelected.contains(idUstensile))
      _listIdUstensileSelected.remove(idUstensile);
    notifyListeners();
  }

  void deleteAllSelected() {
    _listIdUstensileSelected.clear();
    notifyListeners();
  }

  void addAllSelected() {
    _listIdUstensileSelected.clear();
    this._ustensiles.forEach((v) {
      _listIdUstensileSelected.add(v["idUstensile"]);
    });
    notifyListeners();
  }

  bool allSelected() =>
      this._ustensilesFiltered.length == _listIdUstensileSelected.length;

  bool emptySelected() => _listIdUstensileSelected.isEmpty;

  bool isSelected(int idUstensile) => _listIdUstensileSelected.contains(idUstensile);

  bool _isDeletingUstensile = false;

  set isDeletingUstensile(bool value) {
    if (!value) deleteAllSelected();
    _isDeletingUstensile = value;
    GlobalState().hideBottomNavBar = _isDeletingUstensile;
    notifyListeners();
  }

  bool get isDeletingUstensile => _isDeletingUstensile;

  bool _isSearchingUstensile = false;

  set isSearchingUstensile(bool value) {
    _isSearchingUstensile = value;
    if (!_isSearchingUstensile) {
      this.searchData("");
    }
    notifyListeners();
  }

  bool get isSearchingUstensile => _isSearchingUstensile;

  bool _isNotReverse = false;

  bool get isNotReverse => _isNotReverse;

  //Local Storage Variable
  SharedPreferences _sharedPreferences;

  Future<void> setIsReverse(bool isNotReverse) async {
    await _sharedPreferences.setBool(Parametres.ustensileSort, isNotReverse);
    this._isNotReverse = isNotReverse;
    await this.sort();
  }

  //Ustensile List getter
  List<dynamic> get liste => _ustensilesFiltered;
  List<dynamic> _ustensiles = [];
  List<dynamic> _ustensilesFiltered = [];

  Future<void> fetchData() async {
    try {
      _isLoading = true;
      Dio _dio = await RestRequest().getDioInstance();
      try {
        var response = await _dio.get("/ustensiles");
        var data = response?.data;

        _listUstensileByIdUstensile = Cast.stringToIntMap(data["data"], (value) => value);
      } catch (error) {
        print(error);
        if (error is DioError && error.type == DioErrorType.RESPONSE) {
          print(error);
        }
      }
      _ustensiles = _listUstensileByIdUstensile.values.toList();
      _ustensilesFiltered = _ustensiles;
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
    _dio.options.headers["deletelist"] = json.encode(_listIdUstensileSelected);
    try {
      Response response = await _dio.delete("/ustensiles");
      GlobalState().channel.sink.add("ustensile");
      this.isDeletingUstensile = false;
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> removeData(int idUstensile) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      Response response = await _dio.delete("/ustensiles/$idUstensile");
      GlobalState().channel.sink.add("ustensile");
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> saveData(dynamic data) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.post("/ustensiles", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> modifyData(dynamic data, {@required int idUstensile}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.put("/ustensiles/$idUstensile", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  Future<void> sort() async {
    _ustensilesFiltered.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomUstensile"].toLowerCase().compareTo(b["nomUstensile"].toLowerCase())
          : b["nomUstensile"].toLowerCase().compareTo(a["nomUstensile"].toLowerCase());
    });
    _ustensiles.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomUstensile"].toLowerCase().compareTo(b["nomUstensile"].toLowerCase())
          : b["nomUstensile"].toLowerCase().compareTo(a["nomUstensile"].toLowerCase());
    });
    notifyListeners();
  }

  //Method for handling search
  Future<void> searchData(String search) async {
    search = search.trim();
    if (search.isNotEmpty)
      _ustensilesFiltered = _ustensiles.where((v) {
        return v["nomUstensile"]
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase()) ||
            v["prenomUstensile"]
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase());
      }).toList();
    else
      _ustensilesFiltered = _ustensiles;
    notifyListeners();
  }

  //Methode for async Constructor
  Future<void> asyncConstructor() async {
    await SharedPreferences.getInstance().then((pref) async {
      this._sharedPreferences = pref;
      if (!this._sharedPreferences.containsKey(Parametres.ustensileSort))
        this._sharedPreferences.setBool(Parametres.ustensileSort, true);
    }).then((_) {
      this._isNotReverse = _sharedPreferences.getBool(Parametres.ustensileSort);
    });
    await fetchData();
    GlobalState().externalStreamController.stream.listen((msg) {
      if (msg == "ustensile") {
        fetchData();
      }
      if (msg == "ustensile delete") {
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

  UstensileState() {
    asyncConstructor();
  }
}

class Ustensile {
  const Ustensile({@required this.idUstensile, @required this.nomUstensile, @required this.nbStock});
  final int idUstensile;
  final String nomUstensile;
  final int nbStock;
  @override
  operator ==(ustensile) =>
      ustensile is Ustensile && ustensile.idUstensile == idUstensile && ustensile.nomUstensile == nomUstensile;

  int get hashCode => idUstensile.hashCode ^ nomUstensile.hashCode;
}
