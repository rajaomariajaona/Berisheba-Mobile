import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/routes/client/widgets/client_detail.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientListe extends StatefulWidget {
  final int _idClient;

  const ClientListe(
    this._idClient, {
    Key key,
  }) : super(key: key);

  @override
  State createState() => _ClientListeState();
}

class _ClientListeState extends State<ClientListe> {
  @override
  Widget build(BuildContext context) {
    final ClientState clientState = Provider.of<ClientState>(context);
    Map<String, dynamic> _client =
        clientState.clientsById["${widget._idClient}"];
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        leading: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          color: Config.primaryBlue,
                          style: BorderStyle.solid,
                          width: 1))),
              padding: EdgeInsets.symmetric(horizontal: 17, vertical: 3),
              child: Icon(
                Icons.contact_phone,
                size: 30,
              ),
            )
          ],
        ),
        contentPadding: EdgeInsets.fromLTRB(0, 5, 10, 5),
        title: Text("${_client["nomClient"]} ${_client["prenomClient"]}",
            style: TextStyle(fontSize: 16)),
        onTap: () {
          if (clientState.isDeleting) {
            setState(() {
              if (clientState.isSelected(_client["idClient"]))
                clientState.deleteSelected(_client["idClient"]);
              else
                clientState.addSelected(_client["idClient"]);
            });
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ClientDetail(widget._idClient);
            }));
          }
        },
        onLongPress: () {
          clientState.isDeleting = true;
          setState(() {
            clientState.addSelected(_client["idClient"]);
          });
        },
        trailing: clientState.isDeleting
            ? Checkbox(
                value: clientState.isSelected(_client["idClient"]),
                onChanged: (val) {
                  setState(() {
                    if (val)
                      clientState.addSelected(_client["idClient"]);
                    else
                      clientState.deleteSelected(_client["idClient"]);
                  });
                },
              )
            : null,
      ),
    );
  }
}
