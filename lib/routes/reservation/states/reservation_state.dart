import 'dart:convert';

import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/date.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';

//TODO: Lazy loading (ByReservation de alaina amnin xD) Contrainte (Semaine xD) {PAR ID + PAR SEMAINE}
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

  Map<int, dynamic> _reservationsById = {};

  Map<int, dynamic> get reservationsById => _reservationsById;

  Future fetchDataByWeekRange(String weekRange) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      _isLoading = true;
      _dio.options.headers["range"] = weekRange;
      var response = await _dio.get("/reservations");
      _reservationsById = (response.data["data"]).map<int, dynamic>(
          (key, value) => MapEntry<int, dynamic>(int.parse(key), value));
      notifyListeners();
      this.generateEvents();
    } catch (err) {
      print(err);
      print(err?.response?.data);
    } finally {
      _isLoading = false;
    }
  }

  Future fetchDataByIdReservation(int idReservation) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      _isLoading = true;
      var response = await _dio.get("/reservations/$idReservation");
      var data = response?.data;
      if (data != null) {
        _reservationsById[idReservation] = response.data["data"];
        notifyListeners();
        this.generateEvents();
      }else{
        throw "No data";
      }
    } catch (err) {
      if(err?.response?.statusCode != 404){
        print(err);
      }
    } finally {
      _isLoading = false;
    }
  }

  static Future<bool> saveData(dynamic data) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.post("/reservations", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> modifyData(dynamic data,
      {@required int idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.put("/reservations/$idReservation", data: data);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> removeData({@required int idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.delete("/reservations/$idReservation");
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  void generateEvents() {
    _events.clear();
    _reservationsById.forEach((int idReservation, dynamic reservation) {
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
  static final ReservationState _singleton = ReservationState._internal();

  factory ReservationState() {
    _singleton._calendarController = CalendarController();
    _singleton.fetchDataByWeekRange("1-53");
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg == "reservation")
        await _singleton.fetchDataByWeekRange("1-53");
      else if (msg.contains("reservation"))
        await _singleton.fetchDataByIdReservation(int.parse(msg.split(" ")[1]));
      if (msg.split(" ")[0] == "constituer")
        await _singleton.fetchDataByIdReservation(int.parse(msg.split(" ")[1]));
    });
    GlobalState().internalStreamController.stream.listen((msg) async {
      if (msg == "refresh") await _singleton.fetchDataByWeekRange("1-53");
    });
    return _singleton;
  }

  ReservationState._internal();
}
