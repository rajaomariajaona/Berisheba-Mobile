import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:berisheba/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/parametres.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClientState extends ChangeNotifier {
  List<int> _clientSelected = [];

  List<int> get selected => _clientSelected;

  void addSelected(int idClient) {
    if (!_clientSelected.contains(idClient)) _clientSelected.add(idClient);
    notifyListeners();
  }

  void deleteSelected(int idClient) {
    if (_clientSelected.contains(idClient)) _clientSelected.remove(idClient);
    notifyListeners();
  }

  bool _isDeleting = false;

  void deleteAllSelected() {
    _clientSelected.clear();
    notifyListeners();
  }

  void addAllSelected() {
    _clientSelected.clear();
    this._clients.forEach((v) {
      _clientSelected.add(v["idClient"]);
    });
    notifyListeners();
  }

  bool allSelected() => this._clients.length == _clientSelected.length;
  bool emptySelected() => _clientSelected.isEmpty;
  bool isSelected(int idClient) => _clientSelected.contains(idClient);

  set isDeleting(bool value) {
    if (!value) deleteAllSelected();
    _isDeleting = value;
    GlobalState().hideBottomNavBar = _isDeleting;
    notifyListeners();
  }

  bool get isDeleting => _isDeleting;

  SharedPreferences _sharedPreferences;

  bool _isNotReverse = false;

  bool get isNotReverse => _isNotReverse;

  Future<void> setIsReverse(bool isNotReverse) async {
    await _sharedPreferences.setBool(Parametres.clientSort, isNotReverse);
    this._isNotReverse = isNotReverse;
    await this.sort();
  }

  List<dynamic> get liste => _clientsFiltered;
  List<dynamic> _clients = [];
  List<dynamic> _clientsFiltered = [];
  Future<void> getData() async {
    try {
      _clients = await jsonDecode(
          (await http.get(Config.apiURI + "clients")).body)["data"];
      _clientsFiltered = _clients;
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

  Future<void> asyncConstructor() async {
    await SharedPreferences.getInstance().then((pref) async {
      this._sharedPreferences = pref;
      if (!this._sharedPreferences.containsKey(Parametres.clientSort))
        this._sharedPreferences.setBool(Parametres.clientSort, true);
    }).then((_) {
      this._isNotReverse = _sharedPreferences.getBool(Parametres.clientSort);
    });
    await getData();
    GlobalState().streamController.stream.listen((msg) {
      print(msg);
      if (msg == "client") {
        getData();
      }
    });
  }

  ClientState() {
    asyncConstructor();
  }
}
