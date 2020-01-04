import 'package:berisheba/config.dart';
import 'package:berisheba/no_internet.dart';
import 'package:berisheba/routes/acceuil/acceuil_landscape.dart';
import 'package:berisheba/routes/acceuil/acceuil_portrait.dart';
import 'package:berisheba/routes/client/client_portrait.dart';
import 'package:berisheba/routes/client/client_widgets.dart';
import 'package:berisheba/routes/clients.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
//      backgroundColor: Config.bottomNavBgColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabState = Provider.of<TabState>(context);
    final globalState = Provider.of<GlobalState>(context);

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
    final List<Widget> routesPortrait = [
      ClientPortrait(),
      AcceuilPortrait(),
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
    final List<Widget> floatButtons = [
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
      ClientFloatButton(),
    ];
    final List<PreferredSizeWidget> appBar = [
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
      ClientAppBar(context).appbar,
    ];
    assert(_bottomNavBar.items.length == routesPortrait.length);
    assert(_bottomNavBar.items.length == routesLandscape.length);

    return Provider.of<GlobalState>(context).isConnected
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: appBar[tabState.index],
            body: OrientationBuilder(
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
            drawer: MenuDrawer(),
            bottomNavigationBar:
                globalState.hideBottomNavBar ? null : _bottomNavBar,
            floatingActionButton: floatButtons[tabState.index],
          )
        : NoInternet();
  }

  @override
  void initState() {
    GlobalState().connect();
  }
}

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                            Navigator.of(context).pop();
                          }),
                    ),
                    flex: 5,
                  ),
                  Divider(
                    color: Config.secondaryBlue,
                  ),
                  ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {},
                    ),
                    title: const Text("Parametres"),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return Parametres();
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }
}

class Parametres extends StatefulWidget {
  const Parametres({
    Key key,
  }) : super(key: key);

  @override
  State createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {
  String _apiUri;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiUri = Config.apiURI;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: TextFormField(
                initialValue: Config.apiURI,
                decoration: InputDecoration(
                  labelText: "API URI",
                ),
                onChanged: (val) {
                  setState(() {
                    _apiUri = val;
                  });
                },
              ),
            ),
            Flexible(
                flex: 2,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () {
                        Config.apiURI = _apiUri;
                        SharedPreferences.getInstance()
                            .then((sharedPreferences) {
                          sharedPreferences.setString("api", _apiUri);
                        });
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
