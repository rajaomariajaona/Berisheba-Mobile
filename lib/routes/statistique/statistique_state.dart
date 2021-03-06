import 'dart:async';
import 'dart:core';

import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/handle_dio_error.dart';
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
    } catch (err) {
      HandleDioError(err);
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
    } catch (err) {
      HandleDioError(err);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  StatistiqueState() {
    fetchData();
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg == "statistique") {
        await this.fetchData();
      } else if (msg.contains("statistique")) {
        int annee = int.tryParse(msg.split(" ")[1]);
        if (annee != null) await this.fetchDataByAnnee(annee);
      } else if (msg.contains("payer") ||
          msg.contains("jirama") ||
          msg.contains("autres") ||
          msg.contains("constituer") ||
          msg.contains("reservation")) {
        this.fetchData();
      }
    });
    GlobalState().internalStreamController.stream.listen((msg) async {
      if (msg == "refresh") {
        await fetchData();
      }
    });
  }
}
