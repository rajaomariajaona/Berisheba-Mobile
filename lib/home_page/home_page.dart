import 'package:berisheba/home_page/menu_drawer.dart';
import 'package:berisheba/routes/acceuil/acceuil_app_bar.dart';
import 'package:berisheba/routes/acceuil/acceuil_landscape.dart';
import 'package:berisheba/routes/acceuil/acceuil_portrait.dart';
import 'package:berisheba/routes/client/client_portrait.dart';
import 'package:berisheba/routes/client/widgets/client_app_bar.dart';
import 'package:berisheba/routes/client/widgets/client_float_button.dart';
import 'package:berisheba/routes/clients.dart';
import 'package:berisheba/routes/materiel/materiel_portrait.dart';
import 'package:berisheba/routes/materiel/widgets/materiel_app_bar.dart';
import 'package:berisheba/routes/materiel/widgets/materiel_float_button.dart';
import 'package:berisheba/routes/reservation/reservation_portrait.dart';
import 'package:berisheba/routes/reservation/widget/reservation_app_bar.dart';
import 'package:berisheba/routes/reservation/widget/reservation_float_button.dart';
import 'package:berisheba/routes/salle/salle_portrait.dart';
import 'package:berisheba/routes/salle/widgets/salle_app_bar.dart';
import 'package:berisheba/routes/salle/widgets/salle_float_button.dart';
import 'package:berisheba/routes/statistique/statistique_app_bar.dart';
import 'package:berisheba/routes/statistique/statistique_portrait.dart';
import 'package:berisheba/routes/ustensile/ustensile_portrait.dart';
import 'package:berisheba/routes/ustensile/widgets/ustensile_float_button.dart';
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
  @override
  void initState() {
    GlobalState().internalStreamController.stream.listen((String payload) {
      if (payload.contains("reservation")) {
        int idReservation = int.tryParse(payload.split(" ")[1]);
        if (idReservation != null) {
          GlobalState().navigatorState.currentState.pushNamed("reservation:$idReservation");
        }
      }
    });
    super.initState();
    //Connect the app to the websocket
    GlobalState().connect();
  }

  @override
  void dispose() {
    super.dispose();
  }

  BottomNavigationBarItem _bottomNavigationItem(
      String title, IconData iconData) {
    return BottomNavigationBarItem(
      icon: Icon(
        iconData,
        color: Config.bottomNavIconsColor,
      ),
      title: Text(
        title,
        style: TextStyle(color: Config.bottomNavTextColor, fontSize: 11),
      ),
    );
  }

  final List<Widget> routesPortrait = [
    AcceuilPortrait(),
    ClientPortrait(),
    ReservationPortrait(),
    SallePortrait(),
    MaterielPortrait(),
    UstensilePortrait(),
    StatistiquePortrait(),
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

  final List<Widget> floatButtons = [
    null,
    ClientFloatButton(),
    ReservationFloatButton(),
    SalleFloatButton(),
    MaterielFloatButton(),
    UstensileFloatButton(),
    null,
  ];

  @override
  Widget build(BuildContext context) {
    final tabState = Provider.of<TabState>(context);
    final globalState = Provider.of<GlobalState>(context);
    final BottomNavigationBar _bottomNavBar = BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        _bottomNavigationItem("Acceuil", Config.navIcons["acceuil"]),
        _bottomNavigationItem("Client", Config.navIcons["client"]),
        _bottomNavigationItem("Reservation", Config.navIcons["reservation"]),
        _bottomNavigationItem("Salle", Config.navIcons["salle"]),
        _bottomNavigationItem("Materiel", Config.navIcons["materiel"]),
        _bottomNavigationItem("Ustensile", Config.navIcons["ustensile"]),
        _bottomNavigationItem("Statistique", Config.navIcons["statistique"]),
      ],
      type: BottomNavigationBarType.shifting,
      currentIndex: TabState.index,
      onTap: (index) {
        tabState.changePage(index);
      },
    );

    //App bar
    final List<PreferredSizeWidget> appBar = [
      //TODO: APP BARS
      AcceuilAppBar(context).appbar,
      ClientAppBar(context).appbar,
      ReservationAppBar().appbar,
      SalleAppBar(context).appbar,
      MaterielAppBar(context).appbar,
      ClientAppBar(context).appbar,
      StatistiqueAppBar(context).appbar,
    ];

    //Verify if Items are enough
    assert(_bottomNavBar.items.length == routesPortrait.length);
    assert(_bottomNavBar.items.length == routesLandscape.length);
    assert(_bottomNavBar.items.length == appBar.length);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      //fix render flex
      appBar: appBar[TabState.index],
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
      drawer: const MenuDrawer(),
      bottomNavigationBar: globalState.hideBottomNavBar ? null : _bottomNavBar,
      floatingActionButton: floatButtons[TabState.index],
    );
  }
}
