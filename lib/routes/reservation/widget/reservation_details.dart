import 'package:berisheba/routes/reservation/reservation_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ReservationDetails extends StatelessWidget {
  final int _idReservation;
  ReservationDetails(this._idReservation, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final ReservationState reservationState =
        Provider.of<ReservationState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${reservationState.reservationsById["$_idReservation"]["nomReservation"]}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              http.Response result;
              http
                  .delete("${Config.apiURI}reservations/$_idReservation")
                  .then((response) {
                result = response;
              }).then((_) {
                if (result.statusCode == 204) {
                  Navigator.of(context).pop();
                } else {
                  //TODO: Handle error deleting
                  print(result.statusCode);
                  print(result.body);
                }
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ReservationGlobalDetails(_idReservation),
          ],
        ),
      ),
    );
  }
}

class ReservationGlobalDetails extends StatefulWidget {
  final int _idReservation;
  ReservationGlobalDetails(this._idReservation, {Key key}) : super(key: key);
  @override
  _ReservationGlobalDetailsState createState() =>
      _ReservationGlobalDetailsState();
}

class _ReservationGlobalDetailsState extends State<ReservationGlobalDetails> {
  bool _editMode = false;
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
            _globalDetails("Date Entree", "${_reservation["DateEntree"]} ${_reservation["TypeDemiJourneeEntree"]}"),
            _globalDetails("Date Sortie", "${_reservation["DateSortie"]} ${_reservation["TypeDemiJourneeSortie"]}"),
            _globalDetails("Prix par personne", "${_reservation["prixPersonne"]}"),
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
