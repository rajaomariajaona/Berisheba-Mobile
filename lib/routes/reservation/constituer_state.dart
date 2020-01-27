import 'dart:convert';

import 'package:berisheba/states/config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

enum TypeDemiJournee { jour, nuit }

class ConstituerState extends ChangeNotifier {
  Map<String, dynamic> get stats => _stats;
  Map<String, dynamic> _stats = {};
  Map<DemiJournee, int> _demiJournees = {};
  Map<DemiJournee, int> get demiJournees => _demiJournees;

  Map<DemiJournee, TextEditingController> _controllers = {};
  Map<DemiJournee, TextEditingController> get controllers => _controllers;
  // void addController(DemiJournee demiJournee, TextEditingController)

  fetchData(int idReservation) async {
    try {
      _demiJournees.clear();
      Map<String, dynamic> _data = json.decode(
          (await http.get("${Config.apiURI}/constituers/$idReservation")).body);
      (_data["data"] as List<dynamic>).forEach((value) {
        _demiJournees.putIfAbsent(
            DemiJournee(
                date: value["demiJournee"]["date"],
                typeDemiJournee:
                    value["demiJournee"]["TypeDemiJournee"] == 'Jour'
                        ? TypeDemiJournee.jour
                        : TypeDemiJournee.nuit),
            () => value["nbPersonne"]);
      });
      //TODO: Send This to server to add performance to app
      _stats = _data["stat"];
      notifyListeners();
    } catch (err) {
      print(err);
    }
  }
}

class DemiJournee {
  final String date;
  final TypeDemiJournee typeDemiJournee;
  DemiJournee({@required this.date, @required this.typeDemiJournee});

  bool operator ==(demiJournee) =>
      demiJournee is DemiJournee &&
      demiJournee.date == date &&
      demiJournee.typeDemiJournee == typeDemiJournee;
  int get hashCode => date.hashCode ^ typeDemiJournee.hashCode;
}
