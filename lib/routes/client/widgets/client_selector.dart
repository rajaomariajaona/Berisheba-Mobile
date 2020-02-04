import 'package:berisheba/routes/client/client_portrait.dart';
import 'package:berisheba/routes/client/widgets/client_float_button.dart';
import 'package:flutter/material.dart';

class ClientSelectorBody extends StatelessWidget {
  const ClientSelectorBody({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ClientPortrait(),
      floatingActionButton: ClientFloatButton(),
    );
  }
}