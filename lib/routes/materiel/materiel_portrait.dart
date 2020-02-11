import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/routes/materiel/widgets/materiel_liste.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MaterielPortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MaterielState materielState = Provider.of<MaterielState>(context);

    return WillPopScope(
      onWillPop: () async {
        if (materielState.isDeletingMateriel) {
          materielState.isDeletingMateriel = false;
          return false;
        }
        if(materielState.isSearchingMateriel){
              materielState.isSearchingMateriel = false;
              return false;
        }
        return true;
      },
      child: materielState.isLoading? const Loading() : RefreshIndicator(
        key: materielState.refreshIndicatorStateMateriel,
        onRefresh: () async {
          materielState.fetchData();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Scrollbar(
              child: ListView.builder(
                itemBuilder: (BuildContext ctx, int item) {
                  return MaterielItem(materielState.liste[item]["idMateriel"]);
                },
                itemCount: materielState.liste.length,
              )),
        ),
      ),
    );
  }
}
