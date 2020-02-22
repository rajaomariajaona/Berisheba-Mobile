import 'package:berisheba/routes/statistique/samples/chart_revenu_mensuel.dart';
import 'package:flutter/material.dart';

class StatRevenuMensuel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(28),
            child: ChartRevenuMensuel(),
          ),
        ],
      ),
    );
  }
}
