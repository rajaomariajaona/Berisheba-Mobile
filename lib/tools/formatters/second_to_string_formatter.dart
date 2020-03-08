class SecondToStringFormatter{
  static String format(int seconds){
    Duration temp = Duration(seconds: seconds);
    int days = temp.inDays;
    int hours = temp.inHours % 24;
    int minutes = temp.inMinutes % 60;
    
    return "${days > 0 ? "$days\j ": ""}${(days == 0 && hours == 0) ? "":hours < 10 ? "0$hours\h ": "$hours\h "}${minutes < 10 ? "0$minutes": "$minutes"}mn";
  }
}