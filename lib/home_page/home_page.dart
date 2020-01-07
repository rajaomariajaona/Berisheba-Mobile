import 'package:berisheba/home_page/menu_drawer.dart';
import 'package:berisheba/routes/acceuil/acceuil_landscape.dart';
import 'package:berisheba/routes/acceuil/acceuil_portrait.dart';
import 'package:berisheba/routes/client/client_portrait.dart';
import 'package:berisheba/routes/client/widgets/client_app_bar.dart';
import 'package:berisheba/routes/client/widgets/client_float_button.dart';
import 'package:berisheba/routes/clients.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Squellete extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SquelleteState();
}

class _SquelleteState extends State<Squellete> {
  //Method for making Bottom Navigation Item
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
//      backgroundColor: Config.bottomNavBgColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabState = Provider.of<TabState>(context);
    final globalState = Provider.of<GlobalState>(context);

    //Navigation Bar
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
        tabState.changePage(index);
      },
    );

    //All routes for Portrait View
    final List<Widget> routesPortrait = [
      ClientPortrait(),
      AcceuilPortrait(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
    ];

    //TODO: Landscape
    //All routes for Landscape view
    final List<Widget> routesLandscape = [
      AcceuilLandscape(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
      Clients(),
    ];

    //Float Button For all Routes
    final List<Widget> floatButtons = [
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
    ];

    //App bar
    final List<PreferredSizeWidget> appBar = [
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
    ];

    //Verify if Items are enough
    assert(_bottomNavBar.items.length == routesPortrait.length);
    assert(_bottomNavBar.items.length == routesLandscape.length);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar[tabState.index],
      body:
          //Orientation Builder detect if Orientation Changes
          OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
//          return orientation == Orientation.portrait
//              ? routesPortrait[tabState.index]
//              : routesLandscape[tabState.index];

          return PageView(
            children: orientation == Orientation.portrait
                ? routesPortrait
                : routesLandscape,
            controller: TabState.controllerPage,
            onPageChanged: (int tabIndex) {
              tabState.changeIndex(tabIndex);
            },
          );
        },
      ),

      //Drawer is Menu on the Left side
      drawer: MenuDrawer(),
      bottomNavigationBar: globalState.hideBottomNavBar ? null : _bottomNavBar,
      floatingActionButton: floatButtons[tabState.index],
    );
  }

  @override
  void initState() {
    //Connect the app to the websocket
    GlobalState().connect();
  }
}
