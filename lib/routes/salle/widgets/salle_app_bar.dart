import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalleAppBar {
  final BuildContext _context;

  SalleAppBar(this._context);
  AppBar get appbar {
    SalleState _salleState = Provider.of<SalleState>(_context);
    if (_salleState.isDeletingSalle) {
      return AppBar(
          backgroundColor: Colors.grey,
          actionsIconTheme: const IconThemeData(
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _salleState.isDeletingSalle = false;
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: _salleState.emptySelected()
                  ? const Icon(Icons.check_box_outline_blank)
                  : _salleState.allSelected()
                      ? const Icon(Icons.check_box)
                      : const Icon(Icons.indeterminate_check_box),
              onPressed: () async {
                if (_salleState.emptySelected()) {
                  _salleState.addAllSelected();
                } else if (_salleState.allSelected()) {
                  _salleState.deleteAllSelected();
                } else {
                  _salleState.deleteAllSelected();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  if (!(await _salleState.removeDatas()))
                    throw Exception("Salle not deleted");
                } on Exception catch (_) {
                  print("error deleting salle");
                }
              },
            )
          ]);
    } else if (_salleState.isSearchingSalle) {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _salleState.isSearchingSalle = false;
          },
        ),
        centerTitle: true,
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
              hintText: "Recherche...",
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.close,
                ),
                onPressed: () {
                  _salleState.isSearchingSalle = false;
                },
              )),
          onChanged: (newValue) {
            _salleState.searchData(newValue);
          },
        ),
      );
    } else {
      return AppBar(
          centerTitle: true,
          title: Consumer<TabState>(
            builder: (_, _tabState, __) {
              return Text(
                _tabState.titleAppBar,
              );
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.sort_by_alpha),
              onPressed: () async {
                await _salleState.setIsReverse(!_salleState.isNotReverse);
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _salleState.isSearchingSalle = true;
              },
            ),
          ]);
    }
  }
}
