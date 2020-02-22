import 'package:berisheba/routes/statistique/statistique_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatistiquePortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Card(
          child: Consumer<StatistiqueState>(
            builder: (ctx, _statistiqueState, __) => BezierChart(
              bezierChartScale: BezierChartScale.MONTHLY,
              fromDate: DateTime.parse("2020-01-01"),
              toDate: DateTime.parse("2020-12-31"),
              selectedDate: DateTime.parse("2020-01-01"),
              series: [
                BezierLine(
                  label: "Revenu",
                  onMissingValue: (dateTime) {
                    return 0.0;
                  },
                  data: [
                    for (var i in Iterable.generate(_statistiqueState
                        .revenuMensuelleByYear[2020]["data"].length))
                      DataPoint<DateTime>(
                        value: _statistiqueState.revenuMensuelleByYear[2020]
                                ["data"][i]["y"]
                            .toDouble(),
                        xAxis: DateTime.parse(
                            "2020-${_statistiqueState.revenuMensuelleByYear[2020]["data"][i]["x"] < 10 ? "0${_statistiqueState.revenuMensuelleByYear[2020]["data"][i]["x"]}" : _statistiqueState.revenuMensuelleByYear[2020]["data"][i]["x"]}-01"),
                      ),
                  ],
                ),
              ],
              bubbleLabelDateTimeBuilder:
                  (DateTime dateTime, BezierChartScale bezierChartScale) {
                return "${DateFormat.MMM("fr_FR").format(dateTime)} ${DateFormat.y("fr_FR").format(dateTime)}\n";
              },
              bubbleLabelValueBuilder: (double value) {
                return "$value ar";
              },
              footerDateTimeBuilder:
                  (DateTime dateTime, BezierChartScale bezierChartScale) {
                return "${DateFormat.MMM("fr_FR").format(dateTime).replaceAll(".", "")}\n'${DateFormat.y("fr_FR").format(dateTime).substring(2)}";
              },
              config: BezierChartConfig(
                verticalIndicatorStrokeWidth: 3.0,
                verticalIndicatorColor: Colors.black26,
                showVerticalIndicator: true,
                verticalIndicatorFixedPosition: false,
                backgroundColor: Config.primaryBlue,
                footerHeight: 30.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
