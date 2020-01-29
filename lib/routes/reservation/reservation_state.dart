import 'dart:convert';

import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/date.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';


//Lazy loading (ByReservation de alaina amnin xD) Contrainte (Semaine xD) {PAR ID + PAR SEMAINE}
class ReservationState extends ChangeNotifier {

  bool __isLoading = false;
  bool get isLoading => __isLoading;
  set _isLoading(bool val) {
    if (val != __isLoading) {
      __isLoading = val;
      notifyListeners();
    }
  }

  CalendarController _calendarController;
  CalendarController get calendarController => _calendarController;

  DateTime _selectedDay = DateTime.parse(generateDateString(DateTime.now()));

  DateTime get selectedDay => _selectedDay;

  set selectedDay(DateTime value) {
    _selectedDay = value;
    _calendarController.setSelectedDay(value);
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
    try{
    _isLoading = true;
    http.Response response = await http
        .get("${Config.apiURI}/reservations", headers: {"range": weekRange});
    if (response.statusCode == 200) {
      _reservationsById = jsonDecode(response.body)["data"];
      notifyListeners();
      this.generateEvents();
    } else {
      throw Exception("Error while fetching data ${response.statusCode}");
    }
    }catch(err){
      GlobalState().isConnected = false;
    }finally{
      _isLoading = false;
    }
  }

  void generateEvents() {
    _events.clear();
    _reservationsById.forEach((String idReservation, dynamic reservation) {
      DateTime currentDate = DateTime.parse(reservation["dateEntree"]);
      do {
        if (!_events.containsKey(currentDate)) {
          _events[currentDate] = [];
        }
        if (!_events[currentDate].contains(idReservation)) {
          _events[currentDate].add(idReservation);
        }
        currentDate = currentDate.add(Duration(days: 1));
      } while (!currentDate.isAfter(DateTime.parse(reservation["dateSortie"])));
    });
    notifyListeners();
  }

  Map<DateTime, List<dynamic>> _events = {};

  Map<DateTime, List<dynamic>> get events => _events;
  ReservationState(){
    _calendarController = CalendarController();
    this.fetchData("1-53");
    GlobalState().externalStreamController.stream.listen((msg){
      if(msg == "reservation" || msg.split(" ")[0] == "constituer")
        this.fetchData("1-53");
    });
    GlobalState().internalStreamController.stream.listen((msg){
      if(msg == "refresh")
        this.fetchData("1-53");
    });
  }
}
