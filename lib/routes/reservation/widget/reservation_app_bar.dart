import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationAppBar {
  AppBar get appbar {
    return AppBar(
      centerTitle: true,
          title: Consumer<TabState>(
            builder: (_, _tabState, __) {
              return Text(
                _tabState.titleAppBar,
              );
            },
          ),
    );
  }
}
