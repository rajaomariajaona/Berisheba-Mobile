import 'package:berisheba/acceuil.dart';
import 'package:berisheba/clients.dart';
import 'package:berisheba/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:berisheba/tab_state.dart';

class Squellete extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SquelleteState();
}

class _SquelleteState extends State<Squellete> {
  BottomNavigationBarItem bottomNav(String title, IconData iconData){
    return BottomNavigationBarItem(
      icon: Icon(
        iconData,
        color: Config.bottomNavIconsColor,
      ),
      title: Text(title,
        style: TextStyle(
            color: Config.bottomNavTextColor
        ),
      ),
      backgroundColor: Config.bottomNavBgColor,
    );
  }


  @override
  Widget build(BuildContext context) {
    final tabState = Provider.of<TabState>(context);
    final BottomNavigationBar _bottomNavBar = BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        bottomNav("Acceuil", Icons.home),
        bottomNav("Clients", Icons.supervised_user_circle),
        bottomNav("Reservations", Icons.calendar_today),
        bottomNav("Salles", Icons.room),
        bottomNav("Materiels", Icons.local_dining),
        bottomNav("Statistiques", Icons.show_chart),
      ],
      type: BottomNavigationBarType.shifting,
      currentIndex: tabState.index,
      onTap: (index) {
        tabState.changeIndex(index);
      },
    );
    final List<Widget> routes = [
      Acceuil(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
    ];
    assert(_bottomNavBar.items.length == routes.length);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Config.appBarBgColor,
          centerTitle: true,
          title: Text("Berisheba",
            style: TextStyle(
                color: Config.appBarTextColor
            ),
          ),
        ),
        body: routes[tabState.index],
        bottomNavigationBar: _bottomNavBar
    );
  }

}
