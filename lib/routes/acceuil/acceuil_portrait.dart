import 'package:berisheba/config.dart';
import 'package:berisheba/routes/acceuil/acceuil_widgets.dart';
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
                tabState.changeIndex(1);
              }).item,
              SizedBox(
                width: 20,
              ),
              NavigationItem(
                  context, "Reservation", Config.navIcons["reservation"], () {
                tabState.changeIndex(2);
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
                tabState.changeIndex(3);
              }).item,
              SizedBox(
                width: 20,
              ),
              NavigationItem(context, "Materiel", Config.navIcons["materiel"],
                  () {
                tabState.changeIndex(4);
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
                tabState.changeIndex(5);
              }).item,
              SizedBox(
                width: 20,
              ),
              NavigationItem(
                  context, "Statistique", Config.navIcons["statistique"], () {
                tabState.changeIndex(6);
              }).item
            ],
          ),
        ),
      ],
    );
  }
}
