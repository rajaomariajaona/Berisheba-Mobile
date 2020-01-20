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
        return true;
      },
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              style: TextStyle(color: Config.primaryBlue),
              cursorColor: Config.primaryBlue,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Config.primaryBlue,
                          width: 2,
                          style: BorderStyle.solid)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Config.secondaryBlue,
                          width: 1,
                          style: BorderStyle.solid)),
                  suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Config.primaryBlue,
                      ),
                      onPressed: () {})),
              onChanged: (newValue) {
                clientState.searchData(newValue);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              key: clientState.refreshIndicatorStateClient,
              onRefresh: () async {
                clientState.fetchData();
              },
              child: Scrollbar(
                  key: Provider.of<GlobalState>(context).client,
                  child: ListView.builder(
                    itemBuilder: (BuildContext ctx, int item) {
                      return ClientItem(clientState.liste[item]["idClient"]);
                    },
                    itemCount: clientState.liste.length,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
