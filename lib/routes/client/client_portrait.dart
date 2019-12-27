import 'package:berisheba/config.dart';
import 'package:berisheba/routes/client/client_widgets.dart';
import 'package:berisheba/states/client_state.dart';
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
        if (clientState.isDeleting) {
          clientState.isDeleting = false;
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
              onRefresh: () async {
                return clientState.getData();
              },
              child: Scrollbar(
                  child: ListView.builder(
                itemBuilder: (BuildContext ctx, int item) =>
                    ClientListe(clientState.liste.elementAt(item)),
                itemCount: clientState.liste.length,
              )),
            ),
          )
        ],
      ),
    );
  }
}
