import 'dart:async';
import 'dart:core';

import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class StatistiqueState extends ChangeNotifier {
  bool __isLoading = false;
  bool get isLoading => __isLoading;
  set _isLoading(bool val) {
    if (val != __isLoading) {
      __isLoading = val;
      notifyListeners();
    }
  }

  Map<int, Map<String, dynamic>> _revenuMensuelleByYear = {};
  Map<int, Map<String, dynamic>> get revenuMensuelleByYear =>
      _revenuMensuelleByYear;
  Future<void> fetchDataByAnnee(int annee) async {
    try {
      _isLoading = true;
      Dio _dio = await RestRequest().getDioInstance();
      var result = (await _dio.get("statistique/$annee")).data;
      _revenuMensuelleByYear[annee] = {
        ...result,
        ...{"annee": annee}
      };
    } catch (_) {
      print(_.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchData() async {
    try {
      _isLoading = true;
      Dio _dio = await RestRequest().getDioInstance();
      var result = (await _dio.get("statistique")).data;
      result["data"].forEach((dynamic data) {
        _revenuMensuelleByYear[data["annee"]] = data;
      });
    } catch (_) {
      print(_.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  StatistiqueState() {
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg == "statistique") {
        await this.fetchData();
      } else if (msg.contains("statistique")) {
        await this.fetchDataByAnnee(int.parse(msg.split(" ")[1]));
      }
    });
  }
}
