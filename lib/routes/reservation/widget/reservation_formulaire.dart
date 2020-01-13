import 'package:flutter/material.dart';

class ReservationFormulaire extends StatefulWidget {
  ReservationFormulaire({Key key}) : super(key: key);

  @override
  _ReservationFormulaireState createState() => _ReservationFormulaireState();
}

class _ReservationFormulaireState extends State<ReservationFormulaire> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String nomReservation = "";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              onChanged: (value) {
                setState(() {
                  nomReservation = value;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
