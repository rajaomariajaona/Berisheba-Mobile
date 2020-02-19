import 'package:berisheba/routes/reservation/states/concerner_state.dart';
import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationSalle extends StatelessWidget {
  final int _idReservation;
  final bool readOnly;
  const ReservationSalle(this._idReservation, {this.readOnly, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConcernerState concernerState = Provider.of<ConcernerState>(context);
    List<Widget> _listSalle = [];
    (concernerState.sallesByIdReservation[_idReservation] ?? {})
        .forEach((int idSalle, Salle salle) {
      _listSalle.add(_SalleItem(
          readOnly: readOnly, salle: salle, idReservation: _idReservation));
      _listSalle.add(const Divider());
    });
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
                    child: Consumer<ReservationState>(
                      builder: (ctx, reservationState, _) => Text(
                        "Salles",
                        style: Theme.of(context).textTheme.body2,
                      ),
                    )),
                collapsed: concernerState.isLoading == _idReservation
                    ? const Loading()
                    : Container(
                        child: Text(
                            "Salles occupées: ${concernerState.sallesByIdReservation[_idReservation]?.length ?? ""}"),
                      ),
                expanded: Container(
                  height:
                      concernerState.sallesByIdReservation[_idReservation] !=
                                  null &&
                              concernerState
                                      .sallesByIdReservation[_idReservation]
                                      .length >
                                  0
                          ? 250
                          : 50,
                  child: concernerState.isLoading == _idReservation
                      ? const Loading()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _listSalle,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Selector<ConcernerState, bool>(
                                  selector: (_, _concernerState) =>
                                      _concernerState
                                          .listeSalleDispoByIdReservation[
                                              _idReservation]
                                          .length >
                                      0,
                                  builder: (ctx, isNotEmpty, __) => readOnly
                                      ? Container()
                                      : isNotEmpty
                                          ? IconButton(
                                              icon: Icon(Icons.add),
                                              onPressed: () async {
                                                var res = await showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          SalleDialog(
                                                    idReservation:
                                                        _idReservation,
                                                  ),
                                                );
                                                if (res != null) {
                                                  await ConcernerState.saveData(
                                                          {"idSalle": res},
                                                          idReservation:
                                                              _idReservation)
                                                      .whenComplete(() {
                                                    Provider.of<ConflitState>(
                                                            context,
                                                            listen: false)
                                                        .fetchConflit(
                                                            _idReservation)
                                                        .then((bool
                                                            containConflit) {
                                                      if (containConflit) {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                "conflit/:$_idReservation");
                                                      }
                                                    });
                                                  });
                                                }
                                              },
                                            )
                                          : Container(),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Expandable(
                      collapsed: collapsed,
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
}

class _SalleItem extends StatelessWidget {
  const _SalleItem(
      {Key key,
      @required this.salle,
      @required this.idReservation,
      @required this.readOnly})
      : super(key: key);
  final bool readOnly;
  final Salle salle;
  final int idReservation;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        "${salle.nomSalle} ",
        overflow: TextOverflow.ellipsis,
      ),
      trailing: readOnly
          ? null
          : IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await ConcernerState.removeData(
                    idReservation: idReservation, idSalle: salle.idSalle);
              },
            ),
    );
  }
}

class SalleDialog extends StatefulWidget {
  SalleDialog({@required this.idReservation, Key key}) : super(key: key);
  final int idReservation;
  @override
  State<StatefulWidget> createState() => _SalleDialogState();
}

class _SalleDialogState extends State<SalleDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      // actions: <Widget>[
      //   IconButton(
      //     icon: Icon(
      //       Icons.close,
      //     ),
      //     onPressed: () => Navigator.of(context).pop(null),
      //   ),
      //   IconButton(
      //     icon: Icon(Icons.check),
      //     onPressed: () {},
      //   ),
      // ],
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Consumer<ConcernerState>(
                builder: (ctx, concernerState, __) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (Salle s in concernerState
                        .listeSalleDispoByIdReservation[widget.idReservation]
                        .values) ...[
                      ListTile(
                        title: Text(s.nomSalle),
                        onTap: () {
                          Navigator.of(context).pop(s.idSalle);
                        },
                      ),
                      Divider()
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
