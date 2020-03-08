import 'package:berisheba/routes/ustensile/ustensile_state.dart';
import 'package:berisheba/routes/ustensile/widgets/ustensile_liste.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class UstensilePortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UstensileState ustensileState = Provider.of<UstensileState>(context);

    return WillPopScope(
      onWillPop: () async {
        if (ustensileState.isDeletingUstensile) {
          ustensileState.isDeletingUstensile = false;
          return false;
        }
        if(ustensileState.isSearchingUstensile){
              ustensileState.isSearchingUstensile = false;
              return false;
        }
        return true;
      },
      child: ustensileState.isLoading? const Loading() : RefreshIndicator(
        key: ustensileState.refreshIndicatorStateUstensile,
        onRefresh: () async {
          ustensileState.fetchData();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Scrollbar(
              child: ListView.builder(
                itemBuilder: (BuildContext ctx, int item) {
                  return UstensileItem(ustensileState.liste[item]["idUstensile"]);
                },
                itemCount: ustensileState.liste.length,
              )),
        ),
      ),
    );
  }
}
