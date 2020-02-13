import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/cast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EmprunterState extends ChangeNotifier {
  int __isLoading = 0;
  int get isLoading => __isLoading;
  set _isLoading(int val) {
    if (val != __isLoading) {
      __isLoading = val;
    }
  }

  Map<int, Map<int, dynamic>> _listeMaterielDispoByIdReservation = {};

  Map<int, Map<int, dynamic>> get listeMaterielDispoByIdReservation =>
      _listeMaterielDispoByIdReservation;

  Map<int, Map<int,Emprunter>> _materielsEmprunteByIdReservation = {};
  Map<int, Map<int, Emprunter>> get materielsEmprunteByIdReservation =>
      _materielsEmprunteByIdReservation;

  Future<void> fetchData(int idReservation) async {
    try {
      _isLoading = idReservation;
      Dio _dio = await RestRequest().getDioInstance();
      try {
        var response = await _dio.get("/reservations/$idReservation/materiels");
        var response2 = await _dio.get("/materiels/$idReservation");
        var data = response?.data;
        var data2 = response2?.data;
        _materielsEmprunteByIdReservation[idReservation] = Cast.stringToIntMap(
            data["data"],
            (materiel) => Emprunter(
                materiel: Materiel(
                idMateriel: materiel["idMateriel"],
                nomMateriel: materiel["nomMateriel"],
                nbStock: materiel["nbStock"]),
                idReservation: idReservation,
                nbEmprunte: materiel["nbEmprunte"])).cast<int, Emprunter>();

        _listeMaterielDispoByIdReservation[idReservation] = Cast.stringToIntMap(
            data2["data"],
            (materiel) => Materiel(
                idMateriel: materiel["idMateriel"],
                nomMateriel: materiel["nomMateriel"],
                nbStock: materiel["nbStock"])).cast<int, Materiel>();
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
      {@required int idReservation, @required int idMateriel}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      Response response = await _dio
          .delete("/reservations/$idReservation/materiels/$idMateriel");
      GlobalState().channel.sink.add("emprunter $idReservation");
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
      await _dio.post("/reservations/$idReservation/materiels", data: {"data" : data});
      GlobalState().channel.sink.add("emprunter $idReservation");
      return true;
    } catch (error) {
      print(error);
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> modifyData(dynamic data,
      {@required int idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      Map<String, int> dataEncodable = (data as Map<int, int>).map<String,int>((key,value) => MapEntry(key.toString(), value));
      await _dio.put("/reservations/$idReservation/materiels", data: {"data" : json.encode(dataEncodable)});
      GlobalState().channel.sink.add("emprunter $idReservation");
      return true;
    } catch (error) {
      print(error);
      print(error?.response?.data);
      return false;
    }
  }

  EmprunterState() {
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg.contains("emprunter")) {
        int idReservation = int.tryParse(msg.split(" ")[1]);
        if (idReservation != null) {
          await this.fetchData(idReservation);
        }
      }
    });
  }
}

class Emprunter {
  Emprunter({@required this.materiel, @required this.idReservation, @required this.nbEmprunte});
  final int idReservation;
  final Materiel materiel;
  int nbEmprunte;
  @override
  operator ==(emprunter) =>
      materiel is Emprunter && emprunter.idReservation == idReservation && emprunter.materiel == materiel;

  int get hashCode => idReservation.hashCode ^ materiel.hashCode;
}