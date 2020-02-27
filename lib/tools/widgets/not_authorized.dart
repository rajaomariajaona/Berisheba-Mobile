
import 'package:berisheba/states/authorization_state.dart';
import 'package:flutter/material.dart';

class NotAuthorized extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: RaisedButton(
          child: const Text("NOT AUTHORIZED"),
          onPressed: () {
            AuthorizationState().isAuthorized = true;
          },
        ),
      ),
    );
  }
}
