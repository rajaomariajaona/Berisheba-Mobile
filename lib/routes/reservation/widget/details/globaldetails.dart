
import 'package:berisheba/routes/reservation/reservation_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationGlobalDetails extends StatefulWidget {
  final int _idReservation;
  ReservationGlobalDetails(this._idReservation, {Key key}) : super(key: key);
  @override
  _ReservationGlobalDetailsState createState() =>
      _ReservationGlobalDetailsState();
}

class _ReservationGlobalDetailsState extends State<ReservationGlobalDetails> {
  bool editMode = false;

  @override
  Widget build(BuildContext context) {
    final ReservationState reservationState =
        Provider.of<ReservationState>(context);
    final Map<String, dynamic> _reservation =
        reservationState.reservationsById["${widget._idReservation}"];
    return Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            _globalDetails("Client",
                "${_reservation["nomClient"]} ${_reservation["prenomClient"]}"),
            _globalDetails(
                "Prix par personne", "${_reservation["prixPersonne"]}"),
          ],
        ),
      ),
    );
  }

  Widget _globalDetails(String item, String itemDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[Text("$item: "), Text(itemDetails)],
      ),
    );
  }
}

