import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/parametres.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientState extends ChangeNotifier {
  bool __isLoading = false;
  bool get isLoading => __isLoading;
  set _isLoading(bool val) {
    if (val != __isLoading) {
      __isLoading = val;
      notifyListeners();
    }
  }

  Map<String, dynamic> _listClientByIdClient = {};

  Map<String, dynamic> get listClientByIdClient => _listClientByIdClient;

  //Global key for Indicator state use for refresh data
  final _refreshIndicatorStateClient = GlobalKey<RefreshIndicatorState>();

  get refreshIndicatorStateClient => _refreshIndicatorStateClient;

  //Client id List of Selected;
  List<int> _listIdClientSelected = [];

  List<int> get idClientSelected => _listIdClientSelected;

  //Add Id Client to Selected List
  void addSelected(int idClient) {
    if (!_listIdClientSelected.contains(idClient))
      _listIdClientSelected.add(idClient);
    notifyListeners();
  }

  //TODO : clean search

  void deleteSelected(int idClient) {
    if (_listIdClientSelected.contains(idClient))
      _listIdClientSelected.remove(idClient);
    notifyListeners();
  }

  void deleteAllSelected() {
    _listIdClientSelected.clear();
    notifyListeners();
  }

  void addAllSelected() {
    _listIdClientSelected.clear();
    this._clients.forEach((v) {
      _listIdClientSelected.add(v["idClient"]);
    });
    notifyListeners();
  }

  bool allSelected() =>
      this._clientsFiltered.length == _listIdClientSelected.length;

  bool emptySelected() => _listIdClientSelected.isEmpty;

  bool isSelected(int idClient) => _listIdClientSelected.contains(idClient);

  bool _isDeletingClient = false;

  set isDeletingClient(bool value) {
    if (!value) deleteAllSelected();
    _isDeletingClient = value;
    GlobalState().hideBottomNavBar = _isDeletingClient;
    notifyListeners();
  }

  bool get isDeletingClient => _isDeletingClient;

  bool _isSearchingClient = false;

  set isSearchingClient(bool value) {
    _isSearchingClient = value;
    if (!_isSearchingClient) {
      this.searchData("");
    }
    notifyListeners();
  }

  bool get isSearchingClient => _isSearchingClient;

  bool _isNotReverse = false;

  bool get isNotReverse => _isNotReverse;

  //Local Storage Variable
  SharedPreferences _sharedPreferences;

  Future<void> setIsReverse(bool isNotReverse) async {
    await _sharedPreferences.setBool(Parametres.clientSort, isNotReverse);
    this._isNotReverse = isNotReverse;
    await this.sort();
  }

  //Client List getter
  List<dynamic> get liste => _clientsFiltered;
  List<dynamic> _clients = [];
  List<dynamic> _clientsFiltered = [];

  Future<void> fetchData() async {
    try {
      _isLoading = true;
      await RestRequest().getDioInstance().then((Dio _dio) async {
        await _dio.get("/clients").then((response) {
          var data = response?.data;
          if (data != null) {
            _listClientByIdClient = data["data"];
          }else{
            throw "No data";
          }
        }).catchError((error) {
          if(error is DioError){
            if(error?.response?.statusCode != 401){
            GlobalState().isConnected = false;
            }

          }
        });
      });
      _clients = _listClientByIdClient.values.toList();
      _clientsFiltered = _clients;
      await this.sort();
      GlobalState().isConnected = true;
    } on SocketException catch (_) {
      GlobalState().isConnected = false;
    } on Exception catch (_) {
      print(_.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeData() async {
    Dio _dio = await RestRequest().getDioInstance();
    _dio.options.headers["deletelist"] = json.encode(_listIdClientSelected);
    try {
      Response response = await _dio.delete("/clients");
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> saveData(dynamic data) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.post("/clients", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> modifyData(dynamic data, {@required int idClient}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.put("/clients/$idClient", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  Future<void> sort() async {
    _clientsFiltered.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomClient"].toLowerCase().compareTo(b["nomClient"].toLowerCase())
          : b["nomClient"]
              .toLowerCase()
              .compareTo(a["nomClient"].toLowerCase());
    });
    _clients.sort((dynamic a, dynamic b) {
      return this._isNotReverse
          ? a["nomClient"].toLowerCase().compareTo(b["nomClient"].toLowerCase())
          : b["nomClient"]
              .toLowerCase()
              .compareTo(a["nomClient"].toLowerCase());
    });
    notifyListeners();
  }

  //Method for handling search
  Future<void> searchData(String search) async {
    search = search.trim();
    if (search.isNotEmpty)
      _clientsFiltered = _clients.where((v) {
        return v["nomClient"]
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase()) ||
            v["prenomClient"]
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase());
      }).toList();
    else
      _clientsFiltered = _clients;
    notifyListeners();
  }

  //Methode for async Constructor
  Future<void> asyncConstructor() async {
    await SharedPreferences.getInstance().then((pref) async {
      this._sharedPreferences = pref;
      if (!this._sharedPreferences.containsKey(Parametres.clientSort))
        this._sharedPreferences.setBool(Parametres.clientSort, true);
    }).then((_) {
      this._isNotReverse = _sharedPreferences.getBool(Parametres.clientSort);
    });
    await fetchData();
    GlobalState().externalStreamController.stream.listen((msg) {
      if (msg == "client") {
        fetchData();
      }
    });
    GlobalState().internalStreamController.stream.listen((msg) {
      if (msg == "refresh") {
        fetchData();
      }
    });
  }

  ClientState() {
    asyncConstructor();
  }
}
