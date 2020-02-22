import 'dart:io';
import 'dart:math';

import 'package:berisheba/routes/statistique/line_chart_page.dart';
import 'package:berisheba/states/config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StatistiquePortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StatRevenuMensuel();
  }
}

class Lol extends StatelessWidget {

  String path;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AspectRatio(
          aspectRatio: 1.23,
          child: Container(
            child: LineChart(
              LineChartData(
                backgroundColor: Config.secondaryBlue.withOpacity(0.8),
                minX: 1,
                maxX: 12,
                minY: 0,
                  axisTitleData: FlAxisTitleData(
                    
                      bottomTitle: AxisTitle(
                          titleText: "Revenu par mois", showTitle: true)),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        switch (value.floor()) {
                          case 1:
                            return "Jan";
                          case 2:
                            return "Fev";
                          case 3:
                            return "Mar";
                          case 4:
                            return "Avr";
                          case 5:
                            return "Mai";
                          case 6:
                            return "Jun";
                          case 7:
                            return "Jul";
                          case 8:
                            return "Aug";
                          case 9:
                            return "Sep";
                          case 10:
                            return "Oct";
                          case 11:
                            return "Nov";
                          case 12:
                            return "Dec";
                          default:
                            return "error";
                        }
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      interval: 100000,
                      getTitles: (value){
                        if(value < 100000) return "";
                        return "${(value).floor()} ar";
                      },
                      margin: 8,
                      reservedSize: 50
                    )
                  ),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      barWidth: 4,
                      dotData: FlDotData(
                        dotColor: Colors.greenAccent
                      ),
                      colors: [
                        Config.primaryBlue
                      ],
                      preventCurveOverShooting: true,
                      isCurved: true,
                      spots: <FlSpot>[
                        for (var i in Iterable.generate(12))
                          if(i != 4 )
                          FlSpot(
                      
                              i.toDouble() + 1, (Random().nextDouble() * 1000000).floor().toDouble())
                      ],
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
