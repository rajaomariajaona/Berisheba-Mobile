import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/routes/salle/widgets/salle_liste.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
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
        return true;
      },
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              style: TextStyle(color: Config.primaryBlue),
              cursorColor: Config.primaryBlue,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Config.primaryBlue,
                          width: 2,
                          style: BorderStyle.solid)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Config.secondaryBlue,
                          width: 1,
                          style: BorderStyle.solid)),
                  suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Config.primaryBlue,
                      ),
                      onPressed: () {})),
              onChanged: (newValue) {
                salleState.searchData(newValue);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              key: salleState.refreshIndicatorStateSalle,
              onRefresh: () async {
                salleState.fetchData();
              },
              child: Scrollbar(
                  child: ListView.builder(
                    itemBuilder: (BuildContext ctx, int item) {
                      return SalleItem(salleState.liste[item]["idSalle"]);
                    },
                    itemCount: salleState.liste.length,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
