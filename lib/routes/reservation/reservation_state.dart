import 'dart:convert';

import 'package:berisheba/states/config.dart';
import 'package:berisheba/tools/date.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReservationState extends ChangeNotifier {
  DateTime _selectedDay = DateTime.parse(generateDateString(DateTime.now()));

  DateTime get selectedDay => _selectedDay;

  set selectedDay(DateTime value) {
    _selectedDay = value;
    notifyListeners();
  }

  //Global key for Indicator state use for refresh data

  final _refreshIndicatorStateReservation = GlobalKey<RefreshIndicatorState>();

  get refreshIndicatorStateReservation => _refreshIndicatorStateReservation;

  bool _isDeletingReservation = false;

  bool get isDeletingReservation => _isDeletingReservation;

  set isDeletingReservation(bool value) {
    _isDeletingReservation = value;
  }

  Map<String, dynamic> _reservationsById = {};

  Map<String, dynamic> get reservationsById => _reservationsById;

  void fetchData(String weekRange) async {
    http.Response response = await http
        .get("${Config.apiURI}/reservations", headers: {"range": weekRange});
    if (response.statusCode == 200) {
      _reservationsById = jsonDecode(response.body)["data"];
      this.generateEvents();
    } else {
      throw Exception("Error while fetching data");
    }
  }

  void generateEvents() {
    _reservationsById.forEach((String idReservation, dynamic reservation) {
      DateTime currentDate = DateTime.parse(reservation["DateEntree"]);
      do {
        if (!_events.containsKey(currentDate)) {
          _events[currentDate] = [];
        }
        if (!_events[currentDate].contains(idReservation)) {
          _events[currentDate].add(idReservation);
        }
        currentDate = currentDate.add(Duration(days: 1));
      } while (!currentDate.isAfter(DateTime.parse(reservation["DateSortie"])));
    });
    notifyListeners();
  }

  Map<DateTime, List<dynamic>> _events = {};

  Map<DateTime, List<dynamic>> get events => _events;
}
