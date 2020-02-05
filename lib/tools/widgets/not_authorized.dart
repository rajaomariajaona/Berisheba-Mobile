import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:berisheba/states/global_state.dart';

class NotAuthorized extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: RaisedButton(
          child: const Text("NOT AUTHORIZED"),
          onPressed: () {
            GlobalState().isAuthorized = true;
          },
        ),
      ),
    );
  }
}
