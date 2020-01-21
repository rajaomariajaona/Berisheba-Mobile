import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaterielPortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MaterielState materielState = Provider.of<MaterielState>(context);
    return WillPopScope(
      onWillPop: () async {
            if(materielState.isSearching){
              materielState.isSearching = false;
              return false;
            }else{
              return true;
            }
          },
          child: Container(
        child: Text("HERE"),
      ),
    );
  }
}