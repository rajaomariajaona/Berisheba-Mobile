import 'dart:convert';

import 'package:berisheba/routes/reservation/states/emprunter_state.dart';
import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/ustensile/ustensile_state.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:berisheba/tools/widgets/number_selector.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationUstensile extends StatefulWidget {
  final int idReservation;
  final bool readOnly;
  const ReservationUstensile(this.idReservation, {this.readOnly, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReservationUstensileState();
}

class _ReservationUstensileState extends State<ReservationUstensile> {
  bool _editMode = false;
  Map<int, int> values = {};
  set editMode(bool v) {
    if (_editMode != v) {
      if (!v) {
        values.clear();
      } else {
        (Provider.of<EmprunterState>(context, listen: false)
                    .ustensilesEmprunteByIdReservation[widget.idReservation] ??
                {})
            .forEach((int idUstensile, Emprunter emprunter) {
          values[idUstensile] = emprunter.nbEmprunte;
        });
      }
      _editMode = v;
    }
  }

  bool get editMode => _editMode;
  @override
  Widget build(BuildContext context) {
    final EmprunterState emprunterState = Provider.of<EmprunterState>(context);
    List<Widget> _listUstensile = [];
    (emprunterState.ustensilesEmprunteByIdReservation[widget.idReservation] ??
            {})
        .forEach((int idUstensile, Emprunter emprunter) {
      _listUstensile.add(_UstensileItem(
        readOnly: widget.readOnly,
        emprunter: emprunter,
        value: values[idUstensile] ?? 0,
        idReservation: widget.idReservation,
        editMode: editMode,
        setValue: (int val) {
          setState(() {
            values[idUstensile] = val;
          });
        },
      ));
      _listUstensile.add(const Divider());
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
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Consumer<ReservationState>(
                      builder: (ctx, reservationState, _) => Text(
                        "Ustensiles",
                        style: Theme.of(context).textTheme.body2,
                      ),
                    )),
                collapsed: emprunterState.isLoading == widget.idReservation
                    ? const Loading()
                    : Container(),
                expanded: Container(
                  height: emprunterState.ustensilesEmprunteByIdReservation[
                                  widget.idReservation] !=
                              null &&
                          emprunterState
                                  .ustensilesEmprunteByIdReservation[
                                      widget.idReservation]
                                  .length >
                              0
                      ? 250
                      : 50,
                  child: emprunterState.isLoading == widget.idReservation
                      ? const Loading()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _listUstensile,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                if (widget.readOnly)
                                  Container()
                                else ...[
                                  if (editMode) ...[
                                    IconButton(
                                        icon: Icon(Icons.check),
                                        onPressed: () {
                                          EmprunterState.modifyData(values,
                                                  idReservation:
                                                      widget.idReservation)
                                              .then((bool isOk) {
                                            setState(() {
                                              editMode = false;
                                            });
                                            Provider.of<ConflitState>(context,
                                                    listen: false)
                                                .fetchConflit(
                                                    widget.idReservation)
                                                .then((bool containConflit) {
                                              if (containConflit) {
                                                Navigator.of(context).pushNamed(
                                                    "conflit/:${widget.idReservation}");
                                              }
                                            });
                                          });
                                        }),
                                    IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            editMode = false;
                                          });
                                        }),
                                  ] else
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        setState(() {
                                          editMode = true;
                                        });
                                      },
                                    ),
                                  Selector<EmprunterState, bool>(
                                    selector: (_, _emprunterState) =>
                                        _emprunterState
                                            .listeUstensileDispoByIdReservation[
                                                widget.idReservation]
                                            .length >
                                        0,
                                    builder: (ctx, isNotEmpty, __) => isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () async {
                                              var res = await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        UstensileDialog(
                                                  idReservation:
                                                      widget.idReservation,
                                                ),
                                              );
                                              if (res != null) {
                                                await EmprunterState.saveData(
                                                        {"idUstensile": res},
                                                        idReservation: widget
                                                            .idReservation)
                                                    .whenComplete(() {
                                                  Provider.of<ConflitState>(
                                                          context,
                                                          listen: false)
                                                      .fetchConflit(
                                                          widget.idReservation)
                                                      .then((bool
                                                          containConflit) {
                                                    if (containConflit) {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              "conflit/:${widget.idReservation}");
                                                    }
                                                  });
                                                });
                                              }
                                            },
                                          )
                                        : Container(),
                                  ),
                                ]
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

class _UstensileItem extends StatelessWidget {
  const _UstensileItem(
      {Key key,
      @required this.emprunter,
      @required this.idReservation,
      @required this.editMode,
      @required this.setValue,
      @required this.readOnly,
      @required this.value})
      : super(key: key);
  final bool readOnly;
  final int value;
  final Emprunter emprunter;
  final bool editMode;
  final int idReservation;
  final SetValueCallback setValue;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "${emprunter.ustensile.nomUstensile} ${editMode ? "" : "\n Emprunte: ${emprunter.nbEmprunte}"}",
            overflow: TextOverflow.clip,
          ),
          if (readOnly)
            Container()
          else ...[
            if (!editMode)
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    EmprunterState.removeData(
                        idReservation: idReservation,
                        idUstensile: emprunter.ustensile.idUstensile);
                  })
            else
              GestureDetector(
                onTap: () {},
                child: NumberSelector(
                  min: 0,
                  max: emprunter.ustensile.nbTotal,
                  value: value,
                  setValue: setValue,
                ),
              )
          ]
        ],
      ),
    );
  }
}

class UstensileDialog extends StatefulWidget {
  UstensileDialog({@required this.idReservation, Key key}) : super(key: key);
  final int idReservation;
  @override
  State<StatefulWidget> createState() => _UstensileDialogState();
}

class _UstensileDialogState extends State<UstensileDialog> {
  List<int> selected = [];
  Map<int, int> value = {};
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Consumer<EmprunterState>(
                builder: (ctx, emprunterState, __) {
                  var liste = [
                    for (Ustensile s in emprunterState
                        .listeUstensileDispoByIdReservation[
                            widget.idReservation]
                        .values) ...[
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        dense: true,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Row(
                                children: <Widget>[
                                  selected.contains(s.idUstensile)
                                      ? Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(Icons.check_circle),
                                        )
                                      : Container(),
                                  Expanded(
                                      child: Text(
                                    s.nomUstensile,
                                    overflow: TextOverflow.clip,
                                  )),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: selected.contains(s.idUstensile)
                                  ? NumberSelector(
                                      min: 0,
                                      max: s.nbTotal,
                                      value: value[s.idUstensile] ?? 0,
                                      setValue: (int val) {
                                        setState(() {
                                          value[s.idUstensile] = val;
                                        });
                                      },
                                    )
                                  : Container(),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (selected.contains(s.idUstensile)) {
                            selected.remove(s.idUstensile);
                          } else {
                            selected.add(s.idUstensile);
                            if (!value.containsKey(s.idUstensile)) {
                              value[s.idUstensile] = 0;
                            }
                          }
                          setState(() {});
                        },
                        selected: selected.contains(s.idUstensile),
                      ),
                      Divider()
                    ]
                  ];
                  if (liste.isNotEmpty) {
                    liste.removeLast();
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: liste,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.check),
          onPressed: () async {
            await EmprunterState.saveData(
                    json.encode(value.map<String, int>(
                        (key, value) => MapEntry(key.toString(), value))),
                    idReservation: widget.idReservation)
                .then((res) {
              if (res) {
                Provider.of<ConflitState>(context, listen: false)
                    .fetchConflit(widget.idReservation)
                    .then((bool containConflit) {
                  if (containConflit) {
                    Navigator.of(context).pushReplacementNamed(
                        "conflit/:${widget.idReservation}");
                  } else {
                    Navigator.of(context).pop(null);
                  }
                });
              }
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
      ],
    );
  }
}
