import 'package:berisheba/tools/widgets/conflit/conflit_salle.dart';
import 'package:flutter/material.dart';

class ConflitResolver extends StatelessWidget {
  final int idReservation;
  ConflitResolver({@required this.idReservation});
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ConflitSalle(idReservation: idReservation),
            ],
          ),
        ),
      ),
    );
  }
}

// PATCH CONFLICT SALLE

// onPressed: () async {
//             List<Map<String, String>> data = [];
//             List<int> listReservation = [];
//             choix.forEach((int idSalle, Choice chx) {
//               if (chx == Choice.change) {
//                 for (var val in _conflict[idSalle]["old"]) {
//                   data.add(
//                       {idSalle.toString(): val["idReservation"].toString()});
//                   listReservation.add(val["idReservation"]);
//                 }
//                 listReservation
//                     .add(_conflict[idSalle]["new"]["idReservation"]);
//               } else {
//                 data.add({
//                   idSalle.toString():
//                       _conflict[idSalle]["new"]["idReservation"].toString()
//                 });
//               }
//             });
//             await ConflitState.fixSalle(data);
//             Navigator.of(context).pop(null);
//             listReservation.forEach((reser) {
//               GlobalState().channel.sink.add("concerner $reser");
//             });
//           },
