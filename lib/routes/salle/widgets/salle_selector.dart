import 'package:berisheba/routes/salle/salle_portrait.dart';
import 'package:berisheba/routes/salle/widgets/salle_float_button.dart';
import 'package:flutter/material.dart';

class SalleSelectorBody extends StatelessWidget {
  const SalleSelectorBody({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SallePortrait(),
      floatingActionButton: SalleFloatButton(),
    );
  }
}