import 'package:berisheba/routes/reservation/reservation_state.dart';
import 'package:berisheba/routes/reservation/widget/reservation_item.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/tools/date.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationSemaine extends StatefulWidget {
  @override
  State createState() => _ReservationSemaineState();
}

class _ReservationSemaineState extends State<ReservationSemaine> {
  @override
  Widget build(BuildContext context) {
    final ReservationState reservationState =
    Provider.of<ReservationState>(context);
    List<Widget> _reservationItems =
    reservationState.events[reservationState.selectedDay] != null
        ? reservationState.events[reservationState.selectedDay]
        .map((idReservation) {
      return ReservationItem(
          reservationState.reservationsById[idReservation]);
    }).toList()
        : [];
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Calendrier(),
        Expanded(
          child: reservationState.isLoading ? const Loading() : RefreshIndicator(
            key: reservationState.refreshIndicatorStateReservation,
            onRefresh: () async {
              reservationState.fetchData("1-53");
            },
            child: Scrollbar(
                child: ListView(
                  children: _reservationItems,
                )),
          ),
        ),
      ],
    );
  }
}

class Calendrier extends StatefulWidget {
  @override
  State createState() => _CalendrierState();
}

class _CalendrierState extends State<Calendrier> {
  

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReservationState reservationState =
    Provider.of<ReservationState>(context);
    return TableCalendar(
      calendarStyle: CalendarStyle(
          todayColor: Config.primaryBlue.withAlpha(128),
          selectedColor: Config.primaryBlue),
      builders: CalendarBuilders(
          markersBuilder: (context, dateTime, events, holiday) {
            List<Widget> _markers = events.take(4).map((idReservation) {
              return Container(
                decoration: BoxDecoration(
                    color: reservationState.reservationsById[idReservation] != null && reservationState.reservationsById[idReservation]
                    ["couleur"] !=
                        null &&
                        int.tryParse(reservationState
                            .reservationsById[idReservation]["couleur"]) !=
                            null
                        ? Color(int.parse(reservationState
                        .reservationsById[idReservation]["couleur"]))
                        : Colors.green,
                    shape: BoxShape.circle),
                height: 8,
                width: 8,
                margin: EdgeInsets.symmetric(horizontal: 0.3),
              );
            }).toList();
            return <Widget>[
              Positioned(
                  bottom: 5.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _markers,
                  ))
            ];
          }),
      locale: 'fr_FR',
      startDay: DateTime(2019),
      calendarController: reservationState.calendarController,
      availableCalendarFormats: {CalendarFormat.week: "Semaine"},
      initialCalendarFormat: CalendarFormat.week,
      events: reservationState.events,
      onDaySelected: (DateTime dateTime, List<dynamic> reservations) {
        reservationState.selectedDay =
            DateTime.parse(generateDateString(dateTime));
      },
      onVisibleDaysChanged: (DateTime first, DateTime last, calendarFormat) {
        if (isoWeekNumber(first) == isoWeekNumber(last)) {}
      },
      onHeaderTapped: (DateTime dateTime) async {
        DateTime result = await showMonthPicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2018),
          lastDate: DateTime(2040),
        );
        if (result != null) {
          setState(() {
            reservationState.selectedDay = result;
          });
        }
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
    );
  }
}
