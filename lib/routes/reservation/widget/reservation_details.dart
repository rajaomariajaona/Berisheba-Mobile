import 'package:berisheba/routes/reservation/constituer_state.dart';
import 'package:berisheba/routes/reservation/reservation_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ReservationDetails extends StatelessWidget {
  final int _idReservation;
  ConstituerState _constituerState;
  ReservationDetails(this._idReservation, {Key key}) {
    _constituerState = ConstituerState();
    _constituerState.fetchData(_idReservation);
  }

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
                  Navigator.of(context).pop(true);
                  GlobalState()
                      .externalStreamController
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
            _ReservationGlobalDetails(_idReservation),
            ChangeNotifierProvider.value(
              value: _constituerState,
              child: _ReservationDemiJournee(_idReservation),
            )
          ],
        ),
      ),
    );
  }
}

class _ReservationGlobalDetails extends StatefulWidget {
  final int _idReservation;
  _ReservationGlobalDetails(this._idReservation, {Key key}) : super(key: key);
  @override
  _ReservationGlobalDetailsState createState() =>
      _ReservationGlobalDetailsState();
}

class _ReservationGlobalDetailsState extends State<_ReservationGlobalDetails> {
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

class _ReservationDemiJournee extends StatefulWidget {
  final int _idReservation;
  _ReservationDemiJournee(this._idReservation, {Key key}) : super(key: key);
  @override
  _ReservationDemiJourneeState createState() => _ReservationDemiJourneeState();
}

class _ReservationDemiJourneeState extends State<_ReservationDemiJournee> {
  ExpandableNotifier _body(BuildContext context) {
    final ReservationState reservationState =
        Provider.of<ReservationState>(context);
    final Map<String, dynamic> reservation =
        reservationState.reservationsById["${widget._idReservation}"];
    final ConstituerState constituerState =
        Provider.of<ConstituerState>(context);
    final List<dynamic> data = constituerState.data["data"];
    final Map<String, dynamic> stat = constituerState.data["stat"];
    return ExpandableNotifier(
        child: ScrollOnExpand(
      scrollOnExpand: false,
      scrollOnCollapse: true,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: ScrollOnExpand(
            scrollOnExpand: true,
            scrollOnCollapse: false,
            child: ExpandableNotifier(
              initialExpanded: false,
              child: ExpandablePanel(
                tapHeaderToExpand: true,
                tapBodyToCollapse: false,
                theme: ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                ),
                header: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Dates et nombres de personne",
                      style: Theme.of(context).textTheme.body2,
                    )),
                collapsed: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Date Entree : ${reservation["DateEntree"]} ${reservation["TypeDemiJourneeEntree"]}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Date Sortie : ${reservation["DateSortie"]} ${reservation["TypeDemiJourneeSortie"]}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Nombre de jours : ${stat != null ? stat["nbJours"] : ""}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Nombre de personne en moyenne : ${stat != null ? stat["nbMoyennePersonne"] : ""}",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                expanded: Container(
                  height: 250,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (data != null)
                                for (var _
                                    in Iterable.generate(data.length * 2))
                                  _ % 2 == 0
                                      ? ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Flexible(
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                        "${data[(_ / 2).floor()]["demiJournee"]["date"]}"),
                                                    Flexible(
                                                      child: Icon(
                                                          Icons.wb_sunny,
                                                          color: data[(_ / 2).floor()]["demiJournee"]["TypeDemiJournee"] == 'Jour'
                                                              ? Colors.yellow
                                                              : Colors.grey),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Text("${data[(_ / 2).floor()]["nbPersonne"]} personnes")
                                            ],
                                          ),
                                        )
                                      : Divider()
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext ctx) {
                                return Scaffold(body: Container());
                              }));
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }
}
