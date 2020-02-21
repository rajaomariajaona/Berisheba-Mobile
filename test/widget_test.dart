import 'package:berisheba/tools/date.dart';
import 'package:berisheba/tools/printing/pdf_generator.dart';

void main() {
  PdfGenerator();
}

void testIsoWeekNumber() {
  print(isoWeekNumber(DateTime(2019, 12, 28)));
  print(isoWeekNumber(DateTime(2019, 12, 29)));
  print(isoWeekNumber(DateTime(2019, 12, 30)));
  print(isoWeekNumber(DateTime(2019, 12, 31)));
  print(isoWeekNumber(DateTime(2020, 01, 01)));
  print(isoWeekNumber(DateTime(2020, 01, 02)));
  print(isoWeekNumber(DateTime(2020, 01, 03)));
  print(isoWeekNumber(DateTime(2020, 01, 04)));
  print(isoWeekNumber(DateTime(2020, 01, 05)));
  print(isoWeekNumber(DateTime(2020, 01, 06)));
  print(isoWeekNumber(DateTime(2020, 01, 07)));
}
