import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/routes/client/widgets/client_liste.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ClientPortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ClientState clientState = Provider.of<ClientState>(context);

    return WillPopScope(
      onWillPop: () async {
        if (clientState.isDeletingClient) {
          clientState.isDeletingClient = false;
          return false;
        }
        if(clientState.isSearchingClient){
              clientState.isSearchingClient = false;
              return false;
        }
        return true;
      },
      child: RefreshIndicator(
        key: clientState.refreshIndicatorStateClient,
        onRefresh: () async {
          clientState.fetchData();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Scrollbar(
              child: ListView.builder(
                itemBuilder: (BuildContext ctx, int item) {
                  return ClientItem(clientState.liste[item]["idClient"]);
                },
                itemCount: clientState.liste.length,
              )),
        ),
      ),
    );
  }
}
