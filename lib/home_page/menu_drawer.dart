import 'package:berisheba/home_page/parametres.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';

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
