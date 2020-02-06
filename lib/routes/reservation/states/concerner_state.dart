import 'dart:async';
import 'dart:core';

import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ConcernerState extends ChangeNotifier {
  int __isLoading = 0;
  int get isLoading => __isLoading;
  set _isLoading(int val) {
    if (val != __isLoading) {
      __isLoading = val;
    }
  }

  Map<int, Map<int,dynamic>> _listeSalleDispoByIdReservation = {};

  Map<int, Map<int,dynamic>> get listeSalleDispoByIdReservation =>  _listeSalleDispoByIdReservation;

  Map<int, Map<int,Salle>> _sallesByIdReservation = {};
  Map<int, Map<int,Salle>> get sallesByIdReservation => _sallesByIdReservation;

   //Salle id List of Selected;
  // List<int> _listIdSalleSelected = [];

  // List<int> get idSalleSelected => _listIdSalleSelected;

  // //Add Id Salle to Selected List
  // void addSelected(int idSalle) {
  //   if (!_listIdSalleSelected.contains(idSalle))
  //     _listIdSalleSelected.add(idSalle);
  //   notifyListeners();
  // }

  // void deleteSelected(int idSalle) {
  //   if (_listIdSalleSelected.contains(idSalle))
  //     _listIdSalleSelected.remove(idSalle);
  //   notifyListeners();
  // }

  // void deleteAllSelected() {
  //   _listIdSalleSelected.clear();
  //   notifyListeners();
  // }

  // void addAllSelected() {
  //   _listIdSalleSelected.clear();
  //   this._salles.forEach((v) {
  //     _listIdSalleSelected.add(v["idSalle"]);
  //   });
  //   notifyListeners();
  // }

  // bool allSelected() =>
  //     this._sallesFiltered.length == _listIdSalleSelected.length;

  // bool emptySelected() => _listIdSalleSelected.isEmpty;

  // bool isSelected(int idSalle) => _listIdSalleSelected.contains(idSalle);

  // bool _isNotReverse = false;

  // bool get isNotReverse => _isNotReverse;

  // //Local Storage Variable
  // SharedPreferences _sharedPreferences;

  // Future<void> setIsReverse(bool isNotReverse) async {
  //   await _sharedPreferences.setBool(Parametres.salleSort, isNotReverse);
  //   this._isNotReverse = isNotReverse;
  //   await this.sort();
  // }

  Future<void> fetchData(int idReservation) async {
    try {
      _isLoading = idReservation;
      Dio _dio = await RestRequest().getDioInstance();
      try {
        Stopwatch st = Stopwatch()..start();
        var response = await _dio.get("/reservations/$idReservation/salles");
        var response2 = await _dio.get("/salles/$idReservation");
        var data = response?.data;
        var data2 = response2?.data;
        _sallesByIdReservation[idReservation] = (data["data"] as Map<String,dynamic>).map<int,Salle>((String idSalle, dynamic salle){
          return MapEntry<int,Salle> (int.parse(idSalle), Salle(idSalle: int.parse(idSalle), nomSalle: salle["nomSalle"]));
        });
        _listeSalleDispoByIdReservation[idReservation] = (data2["data"] as Map<String,dynamic>).map<int,Salle>((String idSalle, dynamic salle){
          return MapEntry<int,Salle> (int.parse(idSalle), Salle(idSalle: int.parse(idSalle), nomSalle: salle["nomSalle"]));
        });
      } catch (error) {
        print(error);
        if (error is DioError && error.type == DioErrorType.RESPONSE) {
          print(error);
        }
      }
    } catch (_) {
      print(_.toString());
    } finally {
      _isLoading = 0;
      notifyListeners();
    }
  }

  static Future<bool> removeData({@required int idReservation,@required  int idSalle}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      Response response = await _dio.delete("/reservations/$idReservation/salles/$idSalle");
      GlobalState().channel.sink.add("concerner $idReservation");
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> saveData(dynamic data,{@required int idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.post("/reservations/$idReservation/salles", data: data);
      GlobalState().channel.sink.add("concerner $idReservation");
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

  Future<void> asyncConstructor() async {
    // await SharedPreferences.getInstance().then((pref) async {
    //   this._sharedPreferences = pref;
    //   if (!this._sharedPreferences.containsKey(Parametres.salleSort))
    //     this._sharedPreferences.setBool(Parametres.salleSort, true);
    // }).then((_) {
    //   this._isNotReverse = _sharedPreferences.getBool(Parametres.salleSort);
    // });
  }

  ConcernerState() {
    GlobalState().externalStreamController.stream.listen((msg) async {
      if(msg.contains("concerner")){
        int idReservation = int.tryParse(msg.split(" ")[1]);
        if(idReservation != null){
          await this.fetchData(idReservation);
        }
      }
    });
  }
}
