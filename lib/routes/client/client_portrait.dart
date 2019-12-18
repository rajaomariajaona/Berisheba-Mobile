import 'package:berisheba/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ClientPortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            style: TextStyle(color: Config.primaryBlue),
            cursorColor: Config.primaryBlue,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Config.primaryBlue,
                        width: 2,
                        style: BorderStyle.solid)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Config.secondaryBlue,
                        width: 1,
                        style: BorderStyle.solid)),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Config.primaryBlue,
                  ),
                )),
          ),
        ),
        Expanded(
          child: ListView(
            children: <Widget>[
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: ListTile(
//                  leading: Center(
//                    child: Icon(Icons.contact_phone),
//                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  title: Text("Nom Client", style: TextStyle(fontSize: 20)),
                  subtitle: Text("Tel : 033 xx xxx xx"),
                  trailing: PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(child: Text('Appeler')),
                        PopupMenuItem(child: Text('Reserver')),
                        PopupMenuItem(child: Text('Reserver')),
                      ];
                    },
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
