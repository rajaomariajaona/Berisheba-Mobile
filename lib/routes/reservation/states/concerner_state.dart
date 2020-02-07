import 'dart:async';
import 'dart:core';

import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/cast.dart';
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

  Map<int, Map<int, dynamic>> _listeSalleDispoByIdReservation = {};

  Map<int, Map<int, dynamic>> get listeSalleDispoByIdReservation =>
      _listeSalleDispoByIdReservation;

  Map<int, Map<int, Salle>> _sallesByIdReservation = {};
  Map<int, Map<int, Salle>> get sallesByIdReservation => _sallesByIdReservation;

  Future<void> fetchData(int idReservation) async {
    try {
      _isLoading = idReservation;
      Dio _dio = await RestRequest().getDioInstance();
      try {
        var response = await _dio.get("/reservations/$idReservation/salles");
        var response2 = await _dio.get("/salles/$idReservation");
        var data = response?.data;
        var data2 = response2?.data;
        _sallesByIdReservation[idReservation] = Cast.stringToIntMap(
            data["data"],
            (salle) => Salle(
                idSalle: salle["idSalle"],
                nomSalle: salle["nomSalle"])).cast<int, Salle>();

        _listeSalleDispoByIdReservation[idReservation] = Cast.stringToIntMap(
            data2["data"],
            (salle) => Salle(
                idSalle: salle["idSalle"],
                nomSalle: salle["nomSalle"])).cast<int, Salle>();
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

  static Future<bool> removeData(
      {@required int idReservation, @required int idSalle}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      Response response =
          await _dio.delete("/reservations/$idReservation/salles/$idSalle");
      GlobalState().channel.sink.add("concerner $idReservation");
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> saveData(dynamic data,
      {@required int idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.post("/reservations/$idReservation/salles", data: data);
      GlobalState().channel.sink.add("concerner $idReservation");
      return true;
    } catch (error) {
      print(error);
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

  ConcernerState() {
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg.contains("concerner")) {
        int idReservation = int.tryParse(msg.split(" ")[1]);
        if (idReservation != null) {
          await this.fetchData(idReservation);
        }
      }
    });
  }
}
