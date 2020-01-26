import 'dart:convert';

import 'package:berisheba/states/config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ConstituerState extends ChangeNotifier {
  Map<String, dynamic> _data = {};
  Map<String, dynamic> get data => _data;
  fetchData(int idReservation) async {
    try {
      _data = json.decode(
          (await http.get("${Config.apiURI}/constituers/$idReservation")).body);
      print(_data);
      notifyListeners();
    } catch (err) {}
  }
}
