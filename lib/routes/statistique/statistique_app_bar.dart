import 'dart:math';

import 'package:berisheba/main.dart';
import 'package:berisheba/routes/statistique/statistique_state.dart';
import 'package:berisheba/tools/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatistiqueAppBar {
  final BuildContext _context;

  StatistiqueAppBar(this._context);
  AppBar get appbar {
    return AppBar(
        centerTitle: true,
        title: Text("Statistiques"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.explore),
            onPressed: () async {
              var scheduledNotificationDateTime = DateTime.parse(
                  "${generateDateString(DateTime.now().add(Duration(seconds: 5)))} 08:00:00");
              var androidPlatformChannelSpecifics =
                  new AndroidNotificationDetails(
                      'your other channel id',
                      'your other channel name',
                      'your other channel description');
              var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
              NotificationDetails platformChannelSpecifics =
                  new NotificationDetails(androidPlatformChannelSpecifics,
                      iOSPlatformChannelSpecifics);
              await MyApp.flutterLocalNotificationsPlugin.schedule(
                  Random().nextInt(15),
                  'Reservation du ${DateFormat.yMMMd("fr_FR").format(DateTime.now().add(Duration(days: 1)))}',
                  'Client: Rajaomaria Jaona',
                  scheduledNotificationDateTime,
                  platformChannelSpecifics,
                  payload: "reservation 1");
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await Provider.of<StatistiqueState>(_context, listen: false)
                  .fetchData();
            },
          )
        ]);
  }
}
