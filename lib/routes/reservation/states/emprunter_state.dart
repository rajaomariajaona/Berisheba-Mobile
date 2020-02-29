import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:berisheba/routes/ustensile/ustensile_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/cast.dart';
import 'package:berisheba/tools/others/handle_dio_error.dart';
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

  Map<int, Map<int, dynamic>> _listeUstensileDispoByIdReservation = {};

  Map<int, Map<int, dynamic>> get listeUstensileDispoByIdReservation =>
      _listeUstensileDispoByIdReservation;

  Map<int, Map<int,Emprunter>> _ustensilesEmprunteByIdReservation = {};
  Map<int, Map<int, Emprunter>> get ustensilesEmprunteByIdReservation =>
      _ustensilesEmprunteByIdReservation;

  Future<void> fetchData(int idReservation) async {
    try {
      _isLoading = idReservation;
      Dio _dio = await RestRequest().getDioInstance();
      try {
        var response = await _dio.get("/reservations/$idReservation/ustensiles");
        var response2 = await _dio.get("/ustensiles/$idReservation");
        var data = response?.data;
        var data2 = response2?.data;
        _ustensilesEmprunteByIdReservation[idReservation] = Cast.stringToIntMap(
            data["data"],
            (ustensile) => Emprunter(
                ustensile: Ustensile(
                idUstensile: ustensile["idUstensile"],
                nomUstensile: ustensile["nomUstensile"],
                nbTotal: ustensile["nbTotal"]),
                idReservation: idReservation,
                nbEmprunte: ustensile["nbEmprunte"])).cast<int, Emprunter>();

        _listeUstensileDispoByIdReservation[idReservation] = Cast.stringToIntMap(
            data2["data"],
            (ustensile) => Ustensile(
                idUstensile: ustensile["idUstensile"],
                nomUstensile: ustensile["nomUstensile"],
                nbTotal: ustensile["nbTotal"])).cast<int, Ustensile>();
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
      {@required int idReservation, @required int idUstensile}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      Response response = await _dio
          .delete("/reservations/$idReservation/ustensiles/$idUstensile");
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
      await _dio.post("/reservations/$idReservation/ustensiles", data: {"data" : data});
      GlobalState().channel.sink.add("emprunter $idReservation");
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
      Map<String, int> dataEncodable = (data as Map<int, int>).map<String,int>((key,value) => MapEntry(key.toString(), value));
      await _dio.put("/reservations/$idReservation/ustensiles", data: {"data" : json.encode(dataEncodable)});
      GlobalState().channel.sink.add("emprunter $idReservation");
      return true;
    } catch (error) {
      HandleDioError(error);
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
    GlobalState().internalStreamController.stream.listen((msg) async {
      if (msg == "refresh" || msg == "ustensile delete") {
        _listeUstensileDispoByIdReservation.keys.forEach((idReservation) async {
          await fetchData(idReservation);
        });
      }
    });
  }
}

class Emprunter {
  Emprunter({@required this.ustensile, @required this.idReservation, @required this.nbEmprunte});
  final int idReservation;
  final Ustensile ustensile;
  int nbEmprunte;
  @override
  operator ==(emprunter) =>
      ustensile is Emprunter && emprunter.idReservation == idReservation && emprunter.ustensile == ustensile;

  int get hashCode => idReservation.hashCode ^ ustensile.hashCode;
}