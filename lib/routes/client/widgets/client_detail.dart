import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/routes/client/widgets/client_formulaire.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetail extends StatelessWidget {
  final int _idClient;

  const ClientDetail(this._idClient);

  @override
  Widget build(BuildContext context) {
    ClientState clientState = Provider.of<ClientState>(context);
    Map<String, dynamic> _client = clientState.clientsById["${_idClient}"];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Config.appBarBgColor,
        centerTitle: true,
        title: Text(
          "${_client["nomClient"]}",
          style: TextStyle(color: Config.appBarTextColor),
        ),
        iconTheme: IconThemeData(color: Config.primaryBlue),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              if (canLaunch("tel:${_client["numTelClient"]}") != null)
                launch("tel:${_client["numTelClient"]}");
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              var t = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ClientFormulaire(
                  client: _client,
                ),
              ));
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        maintainBottomViewPadding: true,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      ListTile(
                        leading: IconButton(
                          icon: const Icon(Icons.contact_phone),
                          onPressed: () {},
                        ),
                        title: Text(
                            "${_client["nomClient"]} ${_client["prenomClient"]}"),
                      ),
                      ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.smartphone),
                          onPressed: () {},
                        ),
                        title: Text("${_client["numTelClient"]} "),
                        onTap: () {
                          if (canLaunch("tel:${_client["numTelClient"]}") !=
                              null) launch("tel:${_client["numTelClient"]}");
                        },
                      ),
                      ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () {},
                        ),
                        title: Text("${_client["adresseClient"]} "),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}