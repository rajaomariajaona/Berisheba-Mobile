import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ClientAppBar {
  final BuildContext _context;

  ClientAppBar(this._context);

  AppBar get appbar {
    TabState _tabState = Provider.of<TabState>(_context);
    ClientState _clientState = Provider.of<ClientState>(_context);
    return _clientState.isDeleting
        ? AppBar(
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
                _clientState.isDeleting = false;
              },
            ),
            actions: <Widget>[
                IconButton(
                  icon: _clientState.emptySelected()
                      ? const Icon(Icons.check_box_outline_blank)
                      : _clientState.allSelected()
                          ? const Icon(Icons.check_box)
                          : const Icon(Icons.indeterminate_check_box),
                  onPressed: () async {
                    if (_clientState.emptySelected()) {
                      _clientState.addAllSelected();
                    } else if (_clientState.allSelected()) {
                      _clientState.deleteAllSelected();
                    } else {
                      _clientState.deleteAllSelected();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    try {
                      await http.post(Config.apiURI + "clients", body: {
                        "deleteList": _clientState.selected.toString()
                      });
                    } on Exception catch (_) {
                      print("error deleting client");
                    } finally {
                      GlobalState().channel.sink.add("client");
                      _clientState.isDeleting = false;
                    }
                  },
                )
              ])
        : AppBar(
            centerTitle: true,
            title: Text(
              _tabState.titleAppBar,
            ),
            actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.sort_by_alpha),
                  onPressed: () async {
                    await _clientState.setIsReverse(!_clientState.isNotReverse);
                  },
                )
              ]);
  }
}
