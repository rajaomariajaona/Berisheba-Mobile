import 'package:berisheba/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class MyHomePage extends StatelessWidget {
  final Client c = Client();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: <Widget>[
          Observer(
              builder: (context) {
                List<Widget> listeClient = [];
                if(c.clients != null)
                  c.clients["data"].forEach((v) {
                    listeClient.add(
                        ListTile(
                          title: Text("${v}"),
                        )
                    );
                  });
                return Column(
                  children: listeClient,
                );
              }),
          RaisedButton(
            child: Text("Click me"),
            onPressed: (){
              c.getClient();
            },
          )
        ],
      ),
    );
  }

}
