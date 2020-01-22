import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationAppBar {
  final BuildContext _context;

  ReservationAppBar(this._context);
  AppBar get appbar {
    TabState _tabState = Provider.of<TabState>(_context);
    return AppBar(
      centerTitle: true,
      title: Text(
        _tabState.titleAppBar,
      ),
    );
  }
}
