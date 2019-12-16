import 'package:berisheba/config.dart';
import 'package:berisheba/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Acceuil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = Provider.of<TabState>(context);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      children: <Widget>[
        Row(
          children: <Widget>[
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: Config.primaryBlue
                ),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                height: 100,
                width: 100,
                child: Column(
                  children: <Widget>[
                    Icon(Icons.supervised_user_circle,
                      color: Colors.white,
                      size: 60,
                    ),
                    Text("Clients",
                      style: TextStyle(
                          color: Colors.white
                      ),
                    )
                  ],
                ),
              ),
              onTap: () {
                tabState.changeIndex(1);
              },
            ),
            Container(
              margin: EdgeInsets.all(10),
              height: 100,
              width: 100,
              color: Config.primaryBlue,
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              height: 100,
              width: 100,
              color: Config.primaryBlue,
            ),
            Container(
              margin: EdgeInsets.all(10),
              height: 100,
              width: 100,
              color: Config.primaryBlue,
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              height: 100,
              width: 220,
              color: Config.primaryBlue,
            )
          ],
        ),
      ],
    );
  }
}
