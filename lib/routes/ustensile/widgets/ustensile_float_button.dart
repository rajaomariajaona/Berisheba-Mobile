import 'package:berisheba/routes/ustensile/ustensile_state.dart';
import 'package:berisheba/routes/ustensile/widgets/ustensile_formulaire.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UstensileFloatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider
        .of<UstensileState>(context)
        .isDeletingUstensile
        ? Container()
        : FloatingActionButton(
            child: Icon(Icons.restaurant),
            onPressed: () async {
              var t = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UstensileFormulaire(),
              ));
              //TODO Handle Navigator after changes
              print(t);
            },
          );
  }
}
