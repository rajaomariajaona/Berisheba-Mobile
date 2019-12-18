import 'package:berisheba/config.dart';
import 'package:berisheba/routes/acceuil/acceuil_landscape.dart';
import 'package:berisheba/routes/acceuil/acceuil_portrait.dart';
import 'package:berisheba/routes/clients.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Squellete extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SquelleteState();
}

class _SquelleteState extends State<Squellete> {
  BottomNavigationBarItem bottomNav(String title, IconData iconData) {
    return BottomNavigationBarItem(
      icon: Icon(
        iconData,
        color: Config.bottomNavIconsColor,
      ),
      title: Text(
        title,
        style: TextStyle(color: Config.bottomNavTextColor, fontSize: 11),
      ),
      backgroundColor: Config.bottomNavBgColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabState = Provider.of<TabState>(context);
    final BottomNavigationBar _bottomNavBar = BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        bottomNav("Acceuil", Config.navIcons["acceuil"]),
        bottomNav("Client", Config.navIcons["client"]),
        bottomNav("Reservation", Config.navIcons["reservation"]),
        bottomNav("Salle", Config.navIcons["salle"]),
        bottomNav("Materiel", Config.navIcons["materiel"]),
        bottomNav("Ustensile", Config.navIcons["ustensile"]),
        bottomNav("Statistique", Config.navIcons["statistique"]),
      ],
      type: BottomNavigationBarType.shifting,
      currentIndex: tabState.index,
      onTap: (index) {
        tabState.changeIndex(index);
      },
    );
    final List<Widget> routesPortrait = [
      AcceuilPortrait(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
    ];
    final List<Widget> routesLandscape = [
      AcceuilLandscape(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
    ];
    assert(_bottomNavBar.items.length == routesPortrait.length);
    assert(_bottomNavBar.items.length == routesLandscape.length);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Config.appBarBgColor,
          centerTitle: true,
          title: Text(
            tabState.titleAppBar,
            style: TextStyle(color: Config.appBarTextColor),
          ),
          iconTheme: IconThemeData(color: Config.primaryBlue),
        ),
        body: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) =>
              orientation == Orientation.portrait
                  ? routesPortrait[tabState.index]
                  : routesLandscape[tabState.index],
        ),
        drawer: MenuDrawer(context).menu,
        bottomNavigationBar: _bottomNavBar);
  }
}

class MenuDrawer {
  final BuildContext _ctx;
  MenuDrawer(this._ctx);
  Drawer get menu => Drawer(
          child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Config.primaryBlue,
              child: SafeArea(
                top: true,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    Flexible(
                      child: ListTile(
                        trailing: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(_ctx).pop();
                            }),
                      ),
                      flex: 5,
                    ),
                    Divider(
                      color: Config.secondaryBlue,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ));
}
