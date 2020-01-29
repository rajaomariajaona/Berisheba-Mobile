import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaterielAppBar {
  final BuildContext _context;

  MaterielAppBar(this._context);

  AppBar get appbar {
    TabState _tabState = Provider.of<TabState>(_context);
    MaterielState _materielState = Provider.of<MaterielState>(_context);
    return _materielState.isSearching
        ? AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: (){
                _materielState.isSearching = false;
              },
            ),
            centerTitle: true,
            title: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Recherche...",
                
              )
            ),
          )
        : AppBar(
            centerTitle: true,
            title: Text(
              _tabState.titleAppBar,
            ),
            actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _materielState.isSearching = true;
                  },
                )
              ]);
  }
}
