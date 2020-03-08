import 'package:berisheba/routes/statistique/statistique_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatistiquePortrait extends StatefulWidget {
  @override
  _StatistiquePortraitState createState() => _StatistiquePortraitState();
}

class _StatistiquePortraitState extends State<StatistiquePortrait> {
  int anneeSelected;
  @override
  void initState() {
    anneeSelected = DateTime.now().year;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Consumer<StatistiqueState>(
                builder: (ctx, _statistiqueState, __) => 
                _statistiqueState.isLoading || _statistiqueState.revenuMensuelleByYear.isEmpty ? Container() :
                DropdownButton(
                    value: anneeSelected,
                    items: <DropdownMenuItem>[
                      for (var annee in _statistiqueState.revenuMensuelleByYear.keys.toList())
                        DropdownMenuItem(
                          child: Text("$annee"),
                          value: annee,
                        )
                    ],
                    onChanged: (value) {
                      setState(() {
                        anneeSelected = value;
                      });
                    })),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Card(
                child: Column(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Consumer<StatistiqueState>(
                        builder: (ctx, _statistiqueState, __) =>
                            _statistiqueState.isLoading
                                ? const Loading()
                                : _statistiqueState.revenuMensuelleByYear[
                                            anneeSelected] ==
                                        null
                                    ? Container(child: Center(
                                      child: Text("Aucune donnée existant"),
                                    ),)
                                    : BezierChart(
                                        bezierChartScale:
                                            BezierChartScale.MONTHLY,
                                        fromDate: DateTime.parse(
                                            "$anneeSelected-01-01"),
                                        toDate: DateTime.parse(
                                            "$anneeSelected-12-31"),
                                        selectedDate: DateTime.parse(
                                            "$anneeSelected-01-01"),
                                        series: [
                                          BezierLine(
                                            label: "Revenu",
                                            onMissingValue: (dateTime) {
                                              return 0.0;
                                            },
                                            data: [
                                              for (var i in Iterable.generate(
                                                  _statistiqueState
                                                      .revenuMensuelleByYear[
                                                          anneeSelected]["data"]
                                                      .length))
                                                DataPoint<DateTime>(
                                                  value: _statistiqueState
                                                      .revenuMensuelleByYear[
                                                          anneeSelected]["data"]
                                                          [i]["y"]
                                                      .toDouble(),
                                                  xAxis: DateTime.parse(
                                                      "$anneeSelected-${_statistiqueState.revenuMensuelleByYear[anneeSelected]["data"][i]["x"] < 10 ? "0${_statistiqueState.revenuMensuelleByYear[anneeSelected]["data"][i]["x"]}" : _statistiqueState.revenuMensuelleByYear[anneeSelected]["data"][i]["x"]}-01"),
                                                ),
                                            ],
                                          ),
                                        ],
                                        bubbleLabelDateTimeBuilder: (DateTime
                                                dateTime,
                                            BezierChartScale bezierChartScale) {
                                          return "${DateFormat.MMM("fr_FR").format(dateTime)} ${DateFormat.y("fr_FR").format(dateTime)}\n";
                                        },
                                        bubbleLabelValueBuilder:
                                            (double value) {
                                          return "$value ar";
                                        },
                                        footerDateTimeBuilder: (DateTime
                                                dateTime,
                                            BezierChartScale bezierChartScale) {
                                          return "${DateFormat.MMM("fr_FR").format(dateTime).replaceAll(".", "")}\n'${DateFormat.y("fr_FR").format(dateTime).substring(2)}";
                                        },
                                        config: BezierChartConfig(
                                          startYAxisFromNonZeroValue: false,
                                          verticalIndicatorStrokeWidth: 3.0,
                                          verticalIndicatorColor:
                                              Colors.black26,
                                          showVerticalIndicator: true,
                                          verticalIndicatorFixedPosition: false,
                                          backgroundColor: Config.primaryBlue,
                                          footerHeight: 40.0,
                                        ),
                                      ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Revenu par mois"),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
