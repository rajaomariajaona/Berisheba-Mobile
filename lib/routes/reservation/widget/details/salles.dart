import 'package:berisheba/routes/reservation/states/concerner_state.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationSalle extends StatelessWidget {
  final int _idReservation;
  const ReservationSalle(this._idReservation, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConcernerState concernerState = Provider.of<ConcernerState>(context);
    List<Widget> _listSalle = [];
    (concernerState.sallesByIdReservation[_idReservation] ?? {})
        .forEach((int idSalle, Salle salle) {
      _listSalle.add(_SalleItem(salle: salle, idReservation: _idReservation));
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
                                IconButton(
                                  icon: const Icon(Icons.explore),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return ConflictSalleDialog();
                                        });
                                  },
                                ),
                                Selector<ConcernerState, bool>(
                                  selector: (_, _concernerState) =>
                                      _concernerState
                                          .listeSalleDispoByIdReservation[
                                              _idReservation]
                                          .length >
                                      0,
                                  builder: (ctx, isNotEmpty, __) => isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () async {
                                            var res = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  _SalleDialog(
                                                idReservation: _idReservation,
                                              ),
                                            );
                                            if (res != null) {
                                              await ConcernerState.saveData({
                                                "idSalle": res
                                              }, idReservation: _idReservation);
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
  const _SalleItem({
    Key key,
    @required this.salle,
    @required this.idReservation,
  }) : super(key: key);
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
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await ConcernerState.removeData(
              idReservation: idReservation, idSalle: salle.idSalle);
        },
      ),
    );
  }
}

class _SalleDialog extends StatefulWidget {
  _SalleDialog({@required this.idReservation, Key key}) : super(key: key);
  final int idReservation;
  @override
  State<StatefulWidget> createState() => _SalleDialogState();
}

class _SalleDialogState extends State<_SalleDialog> {
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

enum Choice { keep, change }

class ConflictSalleDialog extends StatefulWidget {
  @override
  _ConflictSalleDialogState createState() => _ConflictSalleDialogState();
}

class _ConflictSalleDialogState extends State<ConflictSalleDialog> {
  Map<int, dynamic> _conflict;
  int idReservation;
  Map<int, Choice> choix = {};
  @override
  void didChangeDependencies() {
    _conflict = ConcernerState.conflict;
    idReservation = _conflict.values.elementAt(0)["new"]["idResrvation"];
    for (int idSalle in _conflict.keys) choix[idSalle] = Choice.change;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (int idSalle in _conflict.keys) ...[
                conflictCard(_conflict[idSalle]),
                SizedBox(
                  height: 10,
                )
              ]
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              List<Map<String, String>> data = [];
              List<int> listReservation = [];
              choix.forEach((int idSalle, Choice chx) {
                if (chx == Choice.change) {
                  for (var val in _conflict[idSalle]["old"]) {
                    data.add(
                        {idSalle.toString(): val["idReservation"].toString()});
                    listReservation.add(val["idReservation"]);
                  }
                  listReservation
                      .add(_conflict[idSalle]["new"]["idReservation"]);
                } else {
                  data.add({
                    idSalle.toString():
                        _conflict[idSalle]["new"]["idReservation"].toString()
                  });
                }
              });
              await ConcernerState.fixConflict(data);
              Navigator.of(context).pop(null);
              listReservation.forEach((reser) {
                GlobalState().channel.sink.add("concerner $reser");
              });
            },
          ),
        ],
      ),
    );
  }

  Widget conflictCard(Map<String, dynamic> details) {
    return Card(
      elevation: 3.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              "Salle : ${details["new"]["nomSalle"]}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  dense: true,
                  title: Text("${details["new"]["nomReservation"]}"),
                  trailing: Radio(
                    value: Choice.change,
                    groupValue: choix[details["new"]["idSalle"]],
                    onChanged: (Choice val) {
                      setState(() {
                        choix[details["new"]["idSalle"]] = val;
                      });
                    },
                  ),
                ),
                const Divider(),
                for (dynamic val in details["old"]) ...[
                  ListTile(
                    dense: true,
                    title: Text("${val["nomReservation"]}"),
                    trailing: Radio(
                      value: Choice.keep,
                      groupValue: choix[details["new"]["idSalle"]],
                      onChanged: (Choice val) {
                        setState(() {
                          choix[details["new"]["idSalle"]] = val;
                        });
                      },
                    ),
                  ),
                  const Divider()
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
