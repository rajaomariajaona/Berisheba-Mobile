import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/routes/salle/widgets/salle_liste.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SallePortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SalleState salleState = Provider.of<SalleState>(context);

    return WillPopScope(
      onWillPop: () async {
        if (salleState.isDeletingSalle) {
          salleState.isDeletingSalle = false;
          return false;
        }
        if(salleState.isSearchingSalle){
              salleState.isSearchingSalle = false;
              return false;
        }
        return true;
      },
      child: salleState.isLoading? const Loading() : RefreshIndicator(
        key: salleState.refreshIndicatorStateSalle,
        onRefresh: () async {
          salleState.fetchData();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Scrollbar(
              child: ListView.builder(
                itemBuilder: (BuildContext ctx, int item) {
                  return SalleItem(salleState.liste[item]["idSalle"]);
                },
                itemCount: salleState.liste.length,
              )),
        ),
      ),
    );
  }
}
