import 'package:berisheba/routes/reservation/widget/reservation_item.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationSemaine extends StatefulWidget {
  @override
  State createState() => _ReservationSemaineState();
}

class _ReservationSemaineState extends State<ReservationSemaine> {
  CalendarController _calendarController;

  @override
  void initState() {
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'fr_FR',
      startDay: DateTime.now(),
      calendarController: _calendarController,
      availableCalendarFormats: {CalendarFormat.week: "Semaine"},
      initialCalendarFormat: CalendarFormat.week,
      events: {
        DateTime.now().add(Duration(days: 2)): [ReservationItem()]
      },
      onDaySelected: (DateTime dateTime, List<dynamic> list) {
        _calendarController.setSelectedDay(dateTime);
        print(list);
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
    );
  }
}
