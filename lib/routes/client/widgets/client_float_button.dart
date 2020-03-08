import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/routes/client/widgets/client_formulaire.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientFloatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider
        .of<ClientState>(context)
        .isDeletingClient
        ? Container()
        : FloatingActionButton(
            child: Icon(Icons.group_add),
            onPressed: () async {
              var t = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ClientFormulaire(),
              ));
              print(t);
            },
          );
  }
}
