import 'package:berisheba/routes/reservation/widget/reservation_mois.dart';
import 'package:berisheba/routes/reservation/widget/reservation_semaine.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class ReservationPortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(75),
          child: Container(
            color: Config.primaryBlue,
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(),
                  ),
                  TabBar(
                    indicatorColor: Config.secondaryBlue,
                    tabs: <Widget>[
                      Tab(
                        icon: Icon(Icons.calendar_view_day),
                        text: "Semaine",
                      ),
                      Tab(
                        icon: Icon(Icons.calendar_today),
                        text: "Mois",
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[ReservationSemaine(), ReservationMois()],
        ),
      ),
    );
  }
}
