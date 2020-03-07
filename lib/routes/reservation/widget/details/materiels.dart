import 'dart:convert';

import 'package:berisheba/routes/reservation/states/louer_state.dart';
import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:berisheba/tools/widgets/number_selector.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationMateriel extends StatefulWidget {
  final int idReservation;
  final bool readOnly;
  const ReservationMateriel(this.idReservation, {this.readOnly, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReservationMaterielState();
}

class _ReservationMaterielState extends State<ReservationMateriel> {
  bool _editMode = false;
  Map<int, int> values = {};
  set editMode(bool v) {
    if (_editMode != v) {
      if (!v) {
        values.clear();
      } else {
        (Provider.of<LouerState>(context, listen: false)
                    .materielsLoueeByIdReservation[widget.idReservation] ??
                {})
            .forEach((int idMateriel, Louer louer) {
          values[idMateriel] = louer.nbLouee;
        });
      }
      _editMode = v;
    }
  }

  bool get editMode => _editMode;
  @override
  Widget build(BuildContext context) {
    final LouerState louerState = Provider.of<LouerState>(context);
    List<Widget> _listMateriel = [];
    (louerState.materielsLoueeByIdReservation[widget.idReservation] ?? {})
        .forEach((int idMateriel, Louer louer) {
      _listMateriel.add(_MaterielItem(
        readOnly: widget.readOnly,
        louer: louer,
        value: values[idMateriel] ?? 0,
        idReservation: widget.idReservation,
        editMode: editMode,
        setValue: (int val) {
          setState(() {
            values[idMateriel] = val;
          });
        },
      ));
      _listMateriel.add(const Divider());
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
                        "Materiels",
                        style: Theme.of(context).textTheme.body2,
                      ),
                    )),
                collapsed: louerState.isLoading == widget.idReservation
                    ? const Loading()
                    : Container(
                        child: Text(
                            "Materiels occupées: ${louerState.materielsLoueeByIdReservation[widget.idReservation]?.length ?? ""}"),
                      ),
                expanded: Container(
                  height: louerState.materielsLoueeByIdReservation[
                                  widget.idReservation] !=
                              null &&
                          louerState
                                  .materielsLoueeByIdReservation[
                                      widget.idReservation]
                                  .length >
                              0
                      ? 250
                      : 50,
                  child: louerState.isLoading == widget.idReservation
                      ? const Loading()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _listMateriel,
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
                                          LouerState.modifyData(values,
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
                                  Selector<LouerState, bool>(
                                    selector: (_, _louerState) =>
                                        _louerState
                                            .listeMaterielDispoByIdReservation[
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
                                                        MaterielDialog(
                                                  idReservation:
                                                      widget.idReservation,
                                                ),
                                              );
                                              if (res != null) {
                                                await LouerState.saveData(
                                                        {"idMateriel": res},
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

class _MaterielItem extends StatelessWidget {
  const _MaterielItem(
      {Key key,
      @required this.louer,
      @required this.idReservation,
      @required this.editMode,
      @required this.setValue,
      @required this.readOnly,
      @required this.value})
      : super(key: key);
  final bool readOnly;
  final int value;
  final Louer louer;
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
            "${louer.materiel.nomMateriel} ${editMode ? "" : "\n Louee: ${louer.nbLouee}"}",
            overflow: TextOverflow.clip,
          ),
          if (readOnly)
            Container()
          else ...[
            if (!editMode)
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    LouerState.removeData(
                        idReservation: idReservation,
                        idMateriel: louer.materiel.idMateriel);
                  })
            else
              GestureDetector(
                onTap: () {},
                child: NumberSelector(
                  min: 0,
                  max: louer.materiel.nbStock,
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

class MaterielDialog extends StatefulWidget {
  MaterielDialog({@required this.idReservation, Key key}) : super(key: key);
  final int idReservation;
  @override
  State<StatefulWidget> createState() => _MaterielDialogState();
}

class _MaterielDialogState extends State<MaterielDialog> {
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
              child: Consumer<LouerState>(
                builder: (ctx, louerState, __) {
                  var liste = [
                    for (Materiel s in louerState
                        .listeMaterielDispoByIdReservation[widget.idReservation]
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
                                  selected.contains(s.idMateriel)
                                      ? Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(Icons.check_circle),
                                        )
                                      : Container(),
                                  Expanded(
                                      child: Text(
                                    s.nomMateriel,
                                    overflow: TextOverflow.clip,
                                  )),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: selected.contains(s.idMateriel)
                                  ? NumberSelector(
                                      min: 0,
                                      max: s.nbStock,
                                      value: value[s.idMateriel] ?? 0,
                                      setValue: (int val) {
                                        setState(() {
                                          value[s.idMateriel] = val;
                                        });
                                      },
                                    )
                                  : Container(),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (selected.contains(s.idMateriel)) {
                            selected.remove(s.idMateriel);
                          } else {
                            selected.add(s.idMateriel);
                            if (!value.containsKey(s.idMateriel)) {
                              value[s.idMateriel] = 0;
                            }
                          }
                          setState(() {});
                        },
                        selected: selected.contains(s.idMateriel),
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
        Selector<LouerState, bool>(
          selector: (_, _louerState) =>
              _louerState
                  .listeMaterielDispoByIdReservation[widget.idReservation]
                  .length >
              0,
          builder: (ctx, isNotEmpty, __) => IconButton(
            icon: Icon(Icons.check),
            onPressed: !isNotEmpty? null: () async {
              await LouerState.saveData(
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
