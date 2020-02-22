
import 'package:flutter/material.dart';

class StatistiqueAppBar {
  final BuildContext _context;

  StatistiqueAppBar(this._context);
  AppBar get appbar {
    return AppBar(
        centerTitle: true,
        title: Text("Statistiques"),
        actions: <Widget>[]);
  }
}
