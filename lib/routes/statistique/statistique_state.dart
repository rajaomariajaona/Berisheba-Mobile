import 'dart:async';
import 'dart:core';

import 'package:berisheba/tools/http/request.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
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
  Future<void> fetchData(int annee) async {
    try {
      _isLoading = true;
      Dio _dio = await RestRequest().getDioInstance();
      var result = (await _dio.get("statistique/$annee")).data;
      _revenuMensuelleByYear[annee] = result;
    } catch (_) {
      print(_.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  StatistiqueState(){
    this.fetchData(DateTime.now().year);
  }
}
