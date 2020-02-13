import 'package:berisheba/routes/ustensile/ustensile_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:berisheba/tools/widgets/confirm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UstensileAppBar {
  final BuildContext _context;

  UstensileAppBar(this._context);
  AppBar get appbar {
    UstensileState _ustensileState = Provider.of<UstensileState>(_context);
    if (_ustensileState.isDeletingUstensile) {
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
              _ustensileState.isDeletingUstensile = false;
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: _ustensileState.emptySelected()
                  ? const Icon(Icons.check_box_outline_blank)
                  : _ustensileState.allSelected()
                      ? const Icon(Icons.check_box)
                      : const Icon(Icons.indeterminate_check_box),
              onPressed: () async {
                if (_ustensileState.emptySelected()) {
                  _ustensileState.addAllSelected();
                } else if (_ustensileState.allSelected()) {
                  _ustensileState.deleteAllSelected();
                } else {
                  _ustensileState.deleteAllSelected();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                if (await Confirm.showDeleteConfirm(context: _context)) {
                  try {
                    if (!(await _ustensileState.removeDatas()))
                      throw Exception("Ustensile not deleted");
                  } on Exception catch (_) {
                    print("error deleting ustensile");
                  }
                }
              },
            )
          ]);
    } else if (_ustensileState.isSearchingUstensile) {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _ustensileState.isSearchingUstensile = false;
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
                  _ustensileState.isSearchingUstensile = false;
                },
              )),
          onChanged: (newValue) {
            _ustensileState.searchData(newValue);
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
                await _ustensileState.setIsReverse(!_ustensileState.isNotReverse);
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _ustensileState.isSearchingUstensile = true;
              },
            ),
          ]);
    }
  }
}
