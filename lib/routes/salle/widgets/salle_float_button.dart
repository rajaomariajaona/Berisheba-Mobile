import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/routes/salle/widgets/salle_formulaire.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalleFloatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider
        .of<SalleState>(context)
        .isDeletingSalle
        ? Container()
        : FloatingActionButton(
            child: Icon(Icons.group_add),
            onPressed: () async {
              var t = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SalleFormulaire(),
              ));
              //TODO Handle Navigator after changes
              print(t);
            },
          );
  }
}
