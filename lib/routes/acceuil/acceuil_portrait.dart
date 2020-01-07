import 'package:berisheba/routes/acceuil/acceuil_widgets.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

class AcceuilPortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = Provider.of<TabState>(context);
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NavigationItem(context, "Clients", Config.navIcons["client"], () {
                tabState.changePage(1);
              }).item,
              SizedBox(
                width: 20,
              ),
              NavigationItem(
                  context, "Reservation", Config.navIcons["reservation"], () {
                tabState.changePage(2);
              }).item
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NavigationItem(context, "Salle", Config.navIcons["salle"], () {
                tabState.changePage(3);
              }).item,
              SizedBox(
                width: 20,
              ),
              NavigationItem(context, "Materiel", Config.navIcons["materiel"],
                  () {
                tabState.changePage(4);
              }).item
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NavigationItem(context, "Ustensile", Config.navIcons["ustensile"],
                  () {
                tabState.changePage(5);
              }).item,
              SizedBox(
                width: 20,
              ),
              NavigationItem(
                  context, "Statistique", Config.navIcons["statistique"], () {
                tabState.changePage(6);
              }).item
            ],
          ),
        ),
      ],
    );
  }
}
