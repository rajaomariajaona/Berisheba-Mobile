
import 'package:berisheba/routes/reservation/constituer_state.dart';
import 'package:berisheba/routes/reservation/reservation_state.dart';
import 'package:berisheba/routes/reservation/widget/details/demi_journee.dart';
import 'package:berisheba/routes/reservation/widget/details/globaldetails.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ReservationDetails extends StatelessWidget {
  final int _idReservation;
  ConstituerState _constituerState;
  ReservationDetails(this._idReservation, {Key key}) {
    _constituerState = ConstituerState();
    if(!_constituerState.demiJourneesByReservation.containsKey(_idReservation))
      _constituerState.fetchData(_idReservation);
  }

  @override
  Widget build(BuildContext context) {
    final ReservationState reservationState =
        Provider.of<ReservationState>(context);
    return reservationState.reservationsById["$_idReservation"] == null ?
      Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text("La reservation a été supprimée"),
        ),
      )
     : Scaffold(
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
                  Navigator.of(context).pop(true);
                  GlobalState()
                      .channel
                      .sink
                      .add("reservation");
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
            ChangeNotifierProvider.value(
              value: _constituerState,
              child: ReservationDemiJournee(_idReservation),
            )
          ],
        ),
      ),
    );
  }
}
