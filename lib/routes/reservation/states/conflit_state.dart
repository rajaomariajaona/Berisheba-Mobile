import 'dart:async';
import 'dart:convert';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/cast.dart';
import 'package:berisheba/tools/others/handle_dio_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ConflitState extends ChangeNotifier {
  int __isLoading = 0;
  int get isLoading => __isLoading;
  set _isLoading(int val) {
    if (val != __isLoading) {
      __isLoading = val;
      notifyListeners();
    }
  }

  Map<int, Map<String, dynamic>> _conflit = {};

  Map<int, Map<String, dynamic>> get conflictByIdReservation => _conflit;

  Future<bool> fetchConflit(int idReservation) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      _isLoading = idReservation;
      var res = false;
      var conflit = (await _dio.get("/conflits/$idReservation")).data;
      if (conflit["salle"] != null &&
          (conflit["salle"] as Map<String, dynamic>).isNotEmpty) {
        _conflit[idReservation] = {"salle": {}};
        _conflit[idReservation]["salle"] =
            Cast.stringToIntMap(conflit["salle"], (value) => value);
        res = true;
      } else if (conflit["materiel"] != null &&
          (conflit["materiel"] as Map<String, dynamic>).isNotEmpty) {
        _conflit[idReservation] = {"materiel": {}};
        _conflit[idReservation]["materiel"] =
            Cast.stringToIntMap(conflit["materiel"], (value) => value);
        res = true;
      } else if (conflit["ustensile"] != null &&
          (conflit["ustensile"] as Map<String, dynamic>).isNotEmpty) {
        _conflit[idReservation] = {"ustensile": {}};
        _conflit[idReservation]["ustensile"] =
            Cast.stringToIntMap(conflit["ustensile"], (value) => value);
        res = true;
      }
      _isLoading = 0;
      return res;
    } catch (error) {
      _isLoading = 0;
      HandleDioError(error);
      return false;
    }finally{
      _isLoading = 0;
    }
  }

  static Future<bool> modifyData(dynamic data, {@required int idSalle}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.put("/salles/$idSalle", data: data);
      return true;
    } catch (error) {
      HandleDioError(error);
      return false;
    }
  }


  static Future<bool> fixSalle(List<Map<String, String>> data) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio
          .patch("/conflits/salles", data: {"deleteList": json.encode(data)});
      return true;
    } catch (error) {
     HandleDioError(error);
      return false;
    }
  }

  static Future<bool> fixMateriel(dynamic data) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.patch("/conflits/materiels", data: {
        "changes": json.encode(data.map<String, dynamic>((key, value) =>
            MapEntry(
                key.toString(),
                value.map<String, dynamic>(
                    (k, val) => MapEntry(k.toString(), val)))))
      });
      return true;
    } catch (error) {
     HandleDioError(error);
      return false;
    }
  }

    static Future<bool> fixUstensile(dynamic data) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.patch("/conflits/ustensiles", data: {
        "changes": json.encode(data.map<String, dynamic>((key, value) =>
            MapEntry(
                key.toString(),
                value.map<String, dynamic>(
                    (k, val) => MapEntry(k.toString(), val)))))
      });
      return true;
    } catch (error) {
     HandleDioError(error);
      return false;
    }
  }
}
