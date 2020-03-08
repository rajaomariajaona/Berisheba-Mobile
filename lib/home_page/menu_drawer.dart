import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/parametres.dart';
import 'package:berisheba/tools/formatters/second_to_string_formatter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Config.secondaryBlue,
            child: SafeArea(
              top: true,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color: Config.primaryBlue,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Container(
                        child: Image.asset("assets/logo.png"),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "'Dieu est avec toi dans tout ce que tu fais.'",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Genèse 21 : 22",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text("A propos"),
                    onTap: () async {
                      showAboutDialog(

                        context: context,
                        children: <Widget>[
                          Text("Adresse: Ambatofotsy-Gara PK21 RN7"),
                          Text("Contact: 034 11 641 54"),
                        ],
                        applicationVersion: "1.0",
                        applicationIcon: Image.asset("assets/logo.png",width: MediaQuery.of(context).size.width / 3,)
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

class ParametresFuture extends StatelessWidget {
  const ParametresFuture({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Config.secondaryBlue,
        child: SafeArea(
          top: true,
          child: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Config.primaryBlue,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    child: Image.asset("assets/logo.png"),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Flexible(
                child: _NotificationSettigns(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationSettigns extends StatefulWidget {
  const _NotificationSettigns({
    Key key,
  }) : super(key: key);

  @override
  __NotificationSettignsState createState() => __NotificationSettignsState();
}

class __NotificationSettignsState extends State<_NotificationSettigns> {
  SharedPreferences instance;
  bool notificationOn = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      instance = await SharedPreferences.getInstance();
      notificationOn = instance.getBool(Parametres.notification);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionTile(
        leading: Icon(Icons.settings),
        title: const Text("Parametres"),
        children: <Widget>[
          ListTile(
            leading: Switch(
              value: notificationOn,
              onChanged: (bool val) async {
                if (instance == null) {
                  instance = await SharedPreferences.getInstance();
                }
                await instance.setBool(Parametres.notification, val);
                setState(() {
                  notificationOn = val;
                });
              },
            ),
            trailing: notificationOn
                ? IconButton(icon: Icon(Icons.settings), onPressed: () async {})
                : SizedBox(),
            title: ListTile(
              title: const Text("Notification"),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationParametresDialog extends StatefulWidget {
  @override
  _NotificationParametresDialogState createState() =>
      _NotificationParametresDialogState();
}

class _NotificationParametresDialogState
    extends State<NotificationParametresDialog> {
  List<int> duration;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (var index = 0; index < duration.length; index++)
                ListTile(
                  title: Text(
                      "${SecondToStringFormatter.format(duration[index])}"),
                  trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        setState(() {
                          duration.removeAt(index);
                        });
                      }),
                )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              await SharedPreferences.getInstance().then((instance) {
                instance.setStringList(Parametres.notificationValues,
                    duration.map((duree) => duree.toString()));
              });
              Navigator.of(context).pop();
            }),
        IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              Navigator.of(context).pop();
            }),
      ],
    );
  }
}
