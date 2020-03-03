import 'package:berisheba/home_page/parametres.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';

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
                  Flexible(
                    child: _NotificationSettigns(),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ));
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
  bool notificationOn = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionTile(
        leading: Icon(Icons.settings),
        title: const Text("Parametres"),
        children: <Widget>[
          ExpansionTile(
            leading: Switch(
              value: notificationOn,
              onChanged: (bool val) {
                setState(() {
                  notificationOn = val;
                });
              },
            ),
            trailing: notificationOn ? null: SizedBox(),
            title: ListTile(
              title: const Text("Notification"),
            ),
          ),
        ],
      ),
    );
  }
}
