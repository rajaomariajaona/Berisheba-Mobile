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

class MaterielState extends ChangeNotifier {
  bool __isLoading = false;
  bool get isLoading => __isLoading;
  set _isLoading(bool val) {
    if (val != __isLoading) {
      __isLoading = val;
      notifyListeners();
    }
  }

  Map<int, dynamic> _listMaterielByIdMateriel = {};

  Map<int, dynamic> get listMaterielByIdMateriel => _listMaterielByIdMateriel;

  //Global key for Indicator state use for refresh data
  final _refreshIndicatorStateMateriel = GlobalKey<RefreshIndicatorState>();

  get refreshIndicatorStateMateriel => _refreshIndicatorStateMateriel;

  //Materiel id List of Selected;
  List<int> _listIdMaterielSelected = [];

  List<int> get idMaterielSelected => _listIdMaterielSelected;

  //Add Id Materiel to Selected List
  void addSelected(int idMateriel) {
    if (!_listIdMaterielSelected.contains(idMateriel))
      _listIdMaterielSelected.add(idMateriel);
    notifyListeners();
  }

  //TODO : clean search

  void deleteSelected(int idMateriel) {
    if (_listIdMaterielSelected.contains(idMateriel))
      _listIdMaterielSelected.remove(idMateriel);
    notifyListeners();
  }

  void deleteAllSelected() {
    _listIdMaterielSelected.clear();
    notifyListeners();
  }

  void addAllSelected() {
    _listIdMaterielSelected.clear();
    this._materiels.forEach((v) {
      _listIdMaterielSelected.add(v["idMateriel"]);
    });
    notifyListeners();
  }

  bool allSelected() =>
      this._materielsFiltered.length == _listIdMaterielSelected.length;

  bool emptySelected() => _listIdMaterielSelected.isEmpty;

  bool isSelected(int idMateriel) => _listIdMaterielSelected.contains(idMateriel);

  bool _isDeletingMateriel = false;

  set isDeletingMateriel(bool value) {
    if (!value) deleteAllSelected();
    _isDeletingMateriel = value;
    GlobalState().hideBottomNavBar = _isDeletingMateriel;
    notifyListeners();
  }

  bool get isDeletingMateriel => _isDeletingMateriel;

  bool _isSearchingMateriel = false;

  set isSearchingMateriel(bool value) {
    _isSearchingMateriel = value;
    if (!_isSearchingMateriel) {
      this.searchData("");
    }
    notifyListeners();
  }

  bool get isSearchingMateriel => _isSearchingMateriel;

  bool _isNotReverse = false;

  bool get isNotReverse => _isNotReverse;

  //Local Storage Variable
  SharedPreferences _sharedPreferences;

  Future<void> setIsReverse(bool isNotReverse) async {
    await _sharedPreferences.setBool(Parametres.materielSort, isNotReverse);
    this._isNotReverse = isNotReverse;
    await this.sort();
  }

  //Materiel List getter
  List<dynamic> get liste => _materielsFiltered;
  List<dynamic> _materiels = [];
  List<dynamic> _materielsFiltered = [];

  Future<void> fetchData() async {
    try {
      _isLoading = true;
      Dio _dio = await RestRequest().getDioInstance();
      try {
        var response = await _dio.get("/materiels");
        var data = response?.data;

        _listMaterielByIdMateriel = Cast.stringToIntMap(data["data"], (value) => value);
      } catch (error) {
        print(error);
        if (error is DioError && error.type == DioErrorType.RESPONSE) {
          print(error);
        }
      }
      _materiels = _listMaterielByIdMateriel.values.toList();
      _materielsFiltered = _materiels;
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
    _dio.options.headers["deletelist"] = json.encode(_listIdMaterielSelected);
    try {
      Response response = await _dio.delete("/materiels");
      GlobalState().channel.sink.add("materiel");
      this.isDeletingMateriel = false;
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> removeData(int idMateriel) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      Response response = await _dio.delete("/materiels/$idMateriel");
      GlobalState().channel.sink.add("materiel");
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> saveData(dynamic data) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.post("/materiels", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> modifyData(dynamic data, {@required int idMateriel}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.put("/materiels/$idMateriel", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  Future<void> sort() async {
    _materielsFiltered.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomMateriel"].toLowerCase().compareTo(b["nomMateriel"].toLowerCase())
          : b["nomMateriel"].toLowerCase().compareTo(a["nomMateriel"].toLowerCase());
    });
    _materiels.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomMateriel"].toLowerCase().compareTo(b["nomMateriel"].toLowerCase())
          : b["nomMateriel"].toLowerCase().compareTo(a["nomMateriel"].toLowerCase());
    });
    notifyListeners();
  }

  //Method for handling search
  Future<void> searchData(String search) async {
    search = search.trim();
    if (search.isNotEmpty)
      _materielsFiltered = _materiels.where((v) {
        return v["nomMateriel"]
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase()) ||
            v["prenomMateriel"]
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase());
      }).toList();
    else
      _materielsFiltered = _materiels;
    notifyListeners();
  }

  //Methode for async Constructor
  Future<void> asyncConstructor() async {
    await SharedPreferences.getInstance().then((pref) async {
      this._sharedPreferences = pref;
      if (!this._sharedPreferences.containsKey(Parametres.materielSort))
        this._sharedPreferences.setBool(Parametres.materielSort, true);
    }).then((_) {
      this._isNotReverse = _sharedPreferences.getBool(Parametres.materielSort);
    });
    await fetchData();
    GlobalState().externalStreamController.stream.listen((msg) {
      if (msg == "materiel") {
        fetchData();
      }
      if (msg == "materiel delete") {
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

  MaterielState() {
    asyncConstructor();
  }
}

class Materiel {
  const Materiel({@required this.idMateriel, @required this.nomMateriel, @required this.nbStock});
  final int idMateriel;
  final String nomMateriel;
  final int nbStock;
  @override
  operator ==(materiel) =>
      materiel is Materiel && materiel.idMateriel == idMateriel && materiel.nomMateriel == nomMateriel;

  int get hashCode => idMateriel.hashCode ^ nomMateriel.hashCode;
}
