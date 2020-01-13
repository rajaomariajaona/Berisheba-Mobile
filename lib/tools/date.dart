int isoWeekNumber(DateTime date) {
  int daysToAdd = DateTime.thursday - date.weekday;
  DateTime thursdayDate = daysToAdd > 0
      ? date.add(Duration(days: daysToAdd))
      : date.subtract(Duration(days: daysToAdd.abs()));
  int dayOfYearThursday = dayOfYear(thursdayDate);
  return 1 + ((dayOfYearThursday - 1) / 7).floor();
}

int dayOfYear(DateTime date) {
  return date.difference(DateTime(date.year, 1, 1)).inDays;
}

String generateDateString(DateTime dateTime) {
  return "${dateTime.year}-${dateTime.month > 9 ? "" : "0"}${dateTime.month}-${dateTime.day > 9 ? "" : "0"}${dateTime.day}";
}
