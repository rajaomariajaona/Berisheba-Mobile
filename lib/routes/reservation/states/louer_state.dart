import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/cast.dart';
import 'package:berisheba/tools/others/handle_dio_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LouerState extends ChangeNotifier {
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

  Map<int, Map<int, Louer>> _materielsLoueeByIdReservation = {};
  Map<int, Map<int, Louer>> get materielsLoueeByIdReservation =>
      _materielsLoueeByIdReservation;

  Future<void> fetchData(int idReservation) async {
    try {
      _isLoading = idReservation;
      Dio _dio = await RestRequest().getDioInstance();
      try {
        var response = await _dio.get("/reservations/$idReservation/materiels");
        var response2 = await _dio.get("/materiels/$idReservation");
        var data = response?.data;
        var data2 = response2?.data;
        _materielsLoueeByIdReservation[idReservation] = Cast.stringToIntMap(
            data["data"],
            (materiel) => Louer(
                materiel: Materiel(
                    idMateriel: materiel["idMateriel"],
                    nomMateriel: materiel["nomMateriel"],
                    nbStock: materiel["nbStock"]),
                idReservation: idReservation,
                nbLouee: materiel["nbLouee"])).cast<int, Louer>();

        _listeMaterielDispoByIdReservation[idReservation] = Cast.stringToIntMap(
            data2["data"],
            (materiel) => Materiel(
                idMateriel: materiel["idMateriel"],
                nomMateriel: materiel["nomMateriel"],
                nbStock: materiel["nbStock"])).cast<int, Materiel>();
      } catch (error) {
        HandleDioError(error);
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
      await _dio.delete("/reservations/$idReservation/materiels/$idMateriel");
      GlobalState().channel.sink.add("louer $idReservation");
      return true;
    } catch (error) {
      HandleDioError(error);
      return false;
    }
  }

  static Future<bool> saveData(dynamic data,
      {@required int idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio
          .post("/reservations/$idReservation/materiels", data: {"data": data});
      GlobalState().channel.sink.add("louer $idReservation");
      return true;
    } catch (error) {
      HandleDioError(error);
      return false;
    }
  }

  static Future<bool> modifyData(dynamic data,
      {@required int idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      Map<String, int> dataEncodable = (data as Map<int, int>)
          .map<String, int>((key, value) => MapEntry(key.toString(), value));
      await _dio.put("/reservations/$idReservation/materiels",
          data: {"data": json.encode(dataEncodable)});
      GlobalState().channel.sink.add("louer $idReservation");
      return true;
    } catch (error) {
      HandleDioError(error);
      return false;
    }
  }

  LouerState() {
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg.contains("louer")) {
        int idReservation = int.tryParse(msg.split(" ")[1]);
        if (idReservation != null) {
          await this.fetchData(idReservation);
        }
      }
    });
    GlobalState().internalStreamController.stream.listen((msg) async {
      if (msg == "refresh" || msg == "materiel delete") {
        _listeMaterielDispoByIdReservation.keys.forEach((idReservation) async {
          await fetchData(idReservation);
        });
      }
    });
  }
}

class Louer {
  Louer(
      {@required this.materiel,
      @required this.idReservation,
      @required this.nbLouee});
  final int idReservation;
  final Materiel materiel;
  int nbLouee;
  @override
  operator ==(louer) =>
      materiel is Louer &&
      louer.idReservation == idReservation &&
      louer.materiel == materiel;

  int get hashCode => idReservation.hashCode ^ materiel.hashCode;
}
