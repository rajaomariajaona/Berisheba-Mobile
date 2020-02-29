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
                  for (var i in Iterable.generate(3)) ...[
                    ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          print(i);
                        },
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
                    ),
                    Divider(),
                  ]
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }
}
