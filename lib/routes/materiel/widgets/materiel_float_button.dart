import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/routes/materiel/widgets/materiel_formulaire.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaterielFloatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider
        .of<MaterielState>(context)
        .isDeletingMateriel
        ? Container()
        : FloatingActionButton(
            child: Icon(Icons.dashboard),
            onPressed: () async {
              var t = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MaterielFormulaire(),
              ));
              //TODO Handle Navigator after changes
              print(t);
            },
          );
  }
}
