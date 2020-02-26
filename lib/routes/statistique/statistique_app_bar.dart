
import 'package:berisheba/routes/statistique/statistique_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatistiqueAppBar {
  final BuildContext _context;

  StatistiqueAppBar(this._context);
  AppBar get appbar {
    return AppBar(
        centerTitle: true,
        title: Text("Statistiques"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await Provider.of<StatistiqueState>(_context,listen: false).fetchData();
            },
          )
        ]);
  }
}
