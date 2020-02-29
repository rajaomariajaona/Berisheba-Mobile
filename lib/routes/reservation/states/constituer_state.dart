import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/handle_dio_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

enum TypeDemiJournee { jour, nuit }

class ConstituerState extends ChangeNotifier {
  int __isLoading = 0;
  int get isLoading => __isLoading;
  set _isLoading(int val) {
    __isLoading = val;
  }

  Map<int, Map<String, dynamic>> get statsByIdReservation => _stats;
  Map<int, Map<String, dynamic>> _stats = {};
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
      Dio _dio = await RestRequest().getDioInstance();
      try {
        Response response =
            await _dio.get("/reservations/$idReservation/demijournee");
        var _data = response.data;

        _demiJournees[idReservation] = (_data["data"] as List<dynamic>)
            .asMap()
            .map<DemiJournee, int>((int index, dynamic value) {
          return MapEntry<DemiJournee, int>(
              DemiJournee(
                  date: value["demiJournee"]["date"],
                  typeDemiJournee:
                      value["demiJournee"]["typeDemiJournee"] == 'Jour'
                          ? TypeDemiJournee.jour
                          : TypeDemiJournee.nuit),
              value["nbPersonne"]);
        });
        _stats[idReservation] = _data["stat"];
        notifyListeners();
        _isLoading = 0;
        return true;
      } catch (error) {

        if (error?.response?.data["error"] == "This Reservation not found") {
          ReservationState().reservationsById[idReservation] = null;
        } 
        HandleDioError(error);
        _isLoading = 0;
        return false;
      }
    } catch (err) {
      _isLoading = 0;
      print(err);
    }
  }

  static Future<bool> modifyData(dynamic data,
      {@required idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.put("/reservations/$idReservation/demijournee", data: data);
      return true;
    } catch (error) {
      HandleDioError(error);
      return false;
    }
  }

  ConstituerState() {
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg.contains("constituer") &&
          _demiJournees.containsKey(int.parse(msg.split(" ")[1]))) {
        await this.fetchData(int.parse(msg.split(" ")[1]));
      }
    });
    GlobalState().internalStreamController.stream.listen((msg) async {
      if (msg == "refresh") {
        _demiJournees.keys.forEach((idReservation) async {
          await fetchData(idReservation);
        });
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
