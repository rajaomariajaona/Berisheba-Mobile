import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({Key key}): super(key : key);
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
                GlobalState globalState = GlobalState();
                globalState.connect();
                if (globalState.isConnected) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
