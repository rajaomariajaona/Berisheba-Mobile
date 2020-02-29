import 'package:berisheba/main.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/date.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/cast.dart';
import 'package:berisheba/tools/others/handle_dio_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'package:table_calendar/table_calendar.dart';

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

  bool isDeletingReservation = false;


  Map<int, dynamic> _reservationsById = {};

  Map<int, dynamic> get reservationsById => _reservationsById;

  Future fetchDataByWeekRange(String weekRange) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      _isLoading = true;
      _dio.options.headers["range"] = weekRange;
      var response = await _dio.get("/reservations");
      _reservationsById =
          Cast.stringToIntMap(response.data["data"], (value) => value);
      notifyListeners();
      await this.generateEvents();
    } catch (err) {
      HandleDioError(err);
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
        await this.generateEvents();
      } else {
        throw "No data";
      }
    } catch (error) {
      HandleDioError(error);
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
      HandleDioError(error);
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
      HandleDioError(error);
      return false;
    }
  }

  static Future<bool> removeData({@required int idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.delete("/reservations/$idReservation");
      return true;
    } catch (error) {
      HandleDioError(error);
      return false;
    }
  }

  Future generateEvents() async {
    _events.clear();
    MyApp.flutterLocalNotificationsPlugin.cancelAll();
    int i = 0;
    _reservationsById.forEach((int idReservation, dynamic reservation) async {
      DateTime currentDate = DateTime.parse(reservation["dateEntree"]);
      if (currentDate.isAfter(DateTime.now())) {
        var scheduledNotificationDateTime = DateTime.parse(
            "${generateDateString(currentDate.subtract(Duration(days: 1)))} 08:00:00");
        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
            'your other channel id',
            'your other channel name',
            'your other channel description');
        var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
        NotificationDetails platformChannelSpecifics = new NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await MyApp.flutterLocalNotificationsPlugin.schedule(
            i++,
            'Reservation du ${DateFormat.yMMMd("fr_FR").format(currentDate)}',
            '${reservation["nomClient"]} ${reservation["prenomClient"]}',
            scheduledNotificationDateTime,
            platformChannelSpecifics,payload: "reservation $idReservation");
      }
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
