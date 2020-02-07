import 'dart:async';
import 'dart:convert';
import 'package:berisheba/tools/http/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ConflitState extends ChangeNotifier {
  int __isLoading = 0;
  int get isLoading => __isLoading;
  set _isLoading(int val) {
    if (val != __isLoading) {
      __isLoading = val;
    }
  }
  Map<int, Map<String, dynamic>> _conflit = {};

  Map<int, Map<String, dynamic>>  get conflictByIdReservation => _conflit;

  Future fetchConflit(int idReservation) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      var conflit = (await _dio.get("/conflit/$idReservation")).data;
      //TODO: AMPIANA Conflit materiel sy ustensile
      if(conflit["salle"] != null && (conflit["salle"] as Map<String,dynamic>).isNotEmpty)
        _conflit[idReservation] = conflit;
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

  static Future<bool> fixSalle(List<Map<String, String>> data) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.patch("/conflit/salles",
          data: {"deleteList": json.encode(data)});
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }
}
