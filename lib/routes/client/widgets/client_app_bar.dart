import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:berisheba/tools/widgets/confirm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientAppBar {
  final BuildContext _context;

  ClientAppBar(this._context);
  AppBar get appbar {
    ClientState _clientState = Provider.of<ClientState>(_context);
    if (_clientState.isDeletingClient) {
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
              _clientState.isDeletingClient = false;
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
                  if (await Confirm.showDeleteConfirm(
                      context:
                          _context)) if (!(await _clientState.removeDatas()))
                    throw Exception("Client not deleted");
                  _clientState.isDeletingClient = false;
                } on Exception catch (_) {
                  print("error deleting client");
                }
              },
            )
          ]);
    } else if (_clientState.isSearchingClient) {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _clientState.isSearchingClient = false;
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
                  _clientState.isSearchingClient = false;
                },
              )),
          onChanged: (newValue) {
            _clientState.searchData(newValue);
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
                await _clientState.setIsReverse(!_clientState.isNotReverse);
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _clientState.isSearchingClient = true;
              },
            ),
          ]);
    }
  }
}
