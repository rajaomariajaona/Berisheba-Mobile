import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:berisheba/tools/widgets/confirm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaterielAppBar {
  final BuildContext _context;

  MaterielAppBar(this._context);
  AppBar get appbar {
    MaterielState _materielState = Provider.of<MaterielState>(_context);
    if (_materielState.isDeletingMateriel) {
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
              _materielState.isDeletingMateriel = false;
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: _materielState.emptySelected()
                  ? const Icon(Icons.check_box_outline_blank)
                  : _materielState.allSelected()
                      ? const Icon(Icons.check_box)
                      : const Icon(Icons.indeterminate_check_box),
              onPressed: () async {
                if (_materielState.emptySelected()) {
                  _materielState.addAllSelected();
                } else if (_materielState.allSelected()) {
                  _materielState.deleteAllSelected();
                } else {
                  _materielState.deleteAllSelected();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                if (await Confirm.showDeleteConfirm(context: _context)) {
                  try {
                    if (!(await _materielState.removeDatas()))
                      throw Exception("Materiel not deleted");
                  } on Exception catch (_) {
                    print("error deleting materiel");
                  }
                }
              },
            )
          ]);
    } else if (_materielState.isSearchingMateriel) {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _materielState.isSearchingMateriel = false;
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
                  _materielState.isSearchingMateriel = false;
                },
              )),
          onChanged: (newValue) {
            _materielState.searchData(newValue);
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
                await _materielState.setIsReverse(!_materielState.isNotReverse);
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _materielState.isSearchingMateriel = true;
              },
            ),
          ]);
    }
  }
}
