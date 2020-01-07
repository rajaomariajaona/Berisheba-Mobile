import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: Center(
          child: Container(
            child: RaisedButton(
              child: Text("Refresh"),
              onPressed: () {
                GlobalState().connect();
                if (GlobalState().isConnected) Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}
