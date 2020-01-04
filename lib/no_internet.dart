import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: RaisedButton(
            child: Text("Refresh"),
            onPressed: () {
              GlobalState().connect();
            },
          ),
        ),
      ),
    );
  }
}
