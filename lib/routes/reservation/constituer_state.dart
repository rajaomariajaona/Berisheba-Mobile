import 'dart:convert';

import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

enum TypeDemiJournee { jour, nuit }

class ConstituerState extends ChangeNotifier {
  int __isLoading = 0;
  int get isLoading => __isLoading;
  set _isLoading(int val) {
    __isLoading = val;
    notifyListeners();
  }

  Map<String, dynamic> get stats => _stats;
  Map<String, dynamic> _stats = {};
  Map<int, Map<DemiJournee, int>> _demiJournees = {};
  Map<int, Map<DemiJournee, int>> get demiJourneesByReservation =>
      _demiJournees;

  Map<DemiJournee, TextEditingController> _controllers = {};
  Map<DemiJournee, TextEditingController> get controllers => _controllers;

  List<DemiJournee> _listDemiJourneeSelected = [];

  List<DemiJournee> get demiJourneeSelected => _listDemiJourneeSelected;

  //Add Id Client to Selected List
  void addSelected(DemiJournee demiJournee) {
    if (!_listDemiJourneeSelected.contains(demiJournee))
      _listDemiJourneeSelected.add(demiJournee);
    notifyListeners();
  }

  //TODO : clean search

  void deleteSelected(DemiJournee demiJournee) {
    if (_listDemiJourneeSelected.contains(demiJournee))
      _listDemiJourneeSelected.remove(demiJournee);
    notifyListeners();
  }

  void deleteAllSelected() {
    _listDemiJourneeSelected.clear();
    notifyListeners();
  }

  void addAllSelected() {
    _listDemiJourneeSelected.clear();
    this._controllers.keys.forEach((v) {
      _listDemiJourneeSelected.add(v);
    });
    notifyListeners();
  }

  bool allSelected() =>
      this._controllers.length == _listDemiJourneeSelected.length;

  bool emptySelected() => _listDemiJourneeSelected.isEmpty;

  bool isSelected(DemiJournee demiJournee) =>
      _listDemiJourneeSelected.contains(demiJournee);

  fetchData(int idReservation) async {
    try {
      _isLoading = idReservation;
      _demiJournees[idReservation] = {};
      http.get("${Config.apiURI}/constituers/$idReservation").then((result) {
        print(result.toString());
        if (result.statusCode == 200) {
          Map<String, dynamic> _data = json.decode(result.body);

          _demiJournees[idReservation] = (_data["data"] as List<dynamic>).asMap().map<DemiJournee, int>((int index,dynamic value) {
                return MapEntry<DemiJournee, int>(DemiJournee(
                    date: value["demiJournee"]["date"],
                    typeDemiJournee:
                        value["demiJournee"]["typeDemiJournee"] == 'Jour'
                            ? TypeDemiJournee.jour
                            : TypeDemiJournee.nuit),
                value["nbPersonne"]);
          });

          //TODO: Send This to server to add performance to app
          _stats = _data["stat"];
          notifyListeners();
        } else {
          print(result.statusCode);
          print(result.body);
        }
      }).then((_){
      _isLoading = 0;
      });
    } catch (err) {
      print(err);
    }
  }

  ConstituerState() {
    GlobalState().externalStreamController.stream.listen((msg) {
      if (msg.contains("constituer") &&
          _demiJournees.containsKey(int.parse(msg.split(" ")[1]))) {
        this.fetchData(int.parse(msg.split(" ")[1]));
      }
    });
  }
}

class DemiJournee {
  final String date;
  final TypeDemiJournee typeDemiJournee;
  const DemiJournee({@required this.date, @required this.typeDemiJournee});

  bool operator ==(demiJournee) =>
      demiJournee is DemiJournee &&
      demiJournee.date == date &&
      demiJournee.typeDemiJournee == typeDemiJournee;
  int get hashCode => date.hashCode ^ typeDemiJournee.hashCode;
}
