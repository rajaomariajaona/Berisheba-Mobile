
import 'package:berisheba/routes/reservation/reservation_state.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:expandable/expandable.dart';
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
        reservationState.reservationsById[widget._idReservation];
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




class ReservationDemiJournee2 extends StatefulWidget {
  final int _idReservation;
  ReservationDemiJournee2(this._idReservation, {Key key}) : super(key: key);
  @override
  _ReservationDemiJourneeState createState() => _ReservationDemiJourneeState();
}

class _ReservationDemiJourneeState extends State<ReservationDemiJournee2> {
  Map<String, int> _modifiedDemijournee = {};
  bool _editMode = false;
    bool _isPosting = false;
  bool get editMode => _editMode;
  void setEditMode(bool v, {Map<String, int> currentDemiJournees}) {
    _editMode = v;
    if (currentDemiJournees != null && v) {
      _modifiedDemijournee = currentDemiJournees;
    }
  }

  Widget _body(BuildContext context) {
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
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Dates et nombres de personne",
                      style: Theme.of(context).textTheme.body2,
                    )),
                collapsed: Container(),
                expanded: Container(),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Expandable(
                      collapsed:collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
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

