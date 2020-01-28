import 'dart:convert';

import 'package:berisheba/routes/reservation/constituer_state.dart';
import 'package:berisheba/routes/reservation/reservation_state.dart';
import 'package:berisheba/routes/reservation/widget/details/change_dates_dialog.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ReservationDemiJournee extends StatefulWidget {
  final int _idReservation;
  ReservationDemiJournee(this._idReservation, {Key key}) : super(key: key);
  @override
  _ReservationDemiJourneeState createState() => _ReservationDemiJourneeState();
}

class _ReservationDemiJourneeState extends State<ReservationDemiJournee> {
  Map<DemiJournee, int> _modifiedDemijournee = {};
  bool _editMode = false;
    bool _isPosting = false;
  bool get editMode => _editMode;
  void setEditMode(bool v, {Map<DemiJournee, int> currentDemiJournees}) {
    _editMode = v;
    if (currentDemiJournees != null && v && _modifiedDemijournee.isEmpty) {
      _modifiedDemijournee = currentDemiJournees;
    }
  }

  Future generateDemiJourneesFromDateRangePicker(
      Map<String, dynamic> rangePickerData, BuildContext context) async {
    DateTime currentDate = DateTime.parse(rangePickerData["dateEntree"]);
    _modifiedDemijournee.clear();
    while (_isOnInterval(currentDate, rangePickerData)) {
      if (_isOnSortieAndNotEntree(currentDate, rangePickerData)) {
        _cursorOnDateSortie(currentDate, rangePickerData);
        break;
      } else {
        if (_isOnEntreeAndSortie(currentDate, rangePickerData)) {
          _cursorOnDateEntreeAndSortie(currentDate, rangePickerData);
        } else if (_isOnEntree(currentDate, rangePickerData)) {
          _cursorOnDateEntree(currentDate, rangePickerData);
        } else {
          _cursorOnDateMilieu(currentDate, rangePickerData);
        }
        currentDate = _incrementDateOneDay(currentDate);
      }
    }
    print(_modifiedDemijournee);
  }

  bool _isOnInterval(
      DateTime currentDate, Map<String, dynamic> rangePickerData) {
    return currentDate.isBefore(
        DateTime.parse(rangePickerData["dateSortie"]).add(Duration(days: 1)));
  }

  bool _isOnSortieAndNotEntree(
      DateTime currentDate, Map<String, dynamic> rangePickerData) {
    return currentDate
            .isAtSameMomentAs(DateTime.parse(rangePickerData["dateSortie"])) &&
        !DateTime.parse(rangePickerData["dateSortie"])
            .isAtSameMomentAs(DateTime.parse(rangePickerData["dateEntree"]));
  }

  bool _isOnEntree(DateTime currentDate, Map<String, dynamic> rangePickerData) {
    return currentDate
        .isAtSameMomentAs(DateTime.parse(rangePickerData["dateEntree"]));
  }

  bool _isOnEntreeAndSortie(
      DateTime currentDate, Map<String, dynamic> rangePickerData) {
    return (currentDate
            .isAtSameMomentAs(DateTime.parse(rangePickerData["dateEntree"]))) &&
        (currentDate
            .isAtSameMomentAs(DateTime.parse(rangePickerData["dateSortie"])));
  }

  void _cursorOnDateSortie(
      DateTime currentDate, Map<String, dynamic> rangePickerData) {
    _addNewDemiJournee(
        currentDate, TypeDemiJournee.jour, rangePickerData, context);
    if (rangePickerData["typeDemiJourneeSortie"] == TypeDemiJournee.jour)
      return;
    else {
      _addNewDemiJournee(
          currentDate, TypeDemiJournee.nuit, rangePickerData, context);
      return;
    }
  }

  void _cursorOnDateEntreeAndSortie(
      DateTime currentDate, Map<String, dynamic> rangePickerData) {
    _addNewDemiJournee(currentDate, rangePickerData["typeDemiJourneeEntree"],
        rangePickerData, context);
    if (rangePickerData["typeDemiJourneeEntree"] !=
        rangePickerData["typeDemiJourneeSortie"])
      _addNewDemiJournee(currentDate, rangePickerData["typeDemiJourneeSortie"],
          rangePickerData, context);
    return;
  }

  void _cursorOnDateEntree(
      DateTime currentDate, Map<String, dynamic> rangePickerData) {
    _addNewDemiJournee(currentDate, rangePickerData["typeDemiJourneeEntree"],
        rangePickerData, context);
    if (rangePickerData["typeDemiJourneeEntree"] == TypeDemiJournee.jour) {
      _addNewDemiJournee(
          currentDate, TypeDemiJournee.nuit, rangePickerData, context);
    }
  }

  void _cursorOnDateMilieu(
      DateTime currentDate, Map<String, dynamic> rangePickerData) {
    _addNewDemiJournee(
        currentDate, TypeDemiJournee.jour, rangePickerData, context);
    _addNewDemiJournee(
        currentDate, TypeDemiJournee.nuit, rangePickerData, context);
  }

  void _addNewDemiJournee(DateTime dateToAdd, TypeDemiJournee type,
      Map<String, dynamic> rangePickerData, BuildContext context) {
    DemiJournee currentDemiJournee = DemiJournee(
      date: "${dateToAdd.toIso8601String().substring(0, 10)}",
      typeDemiJournee: type,
    );
    if (!rangePickerData["remplaceAll"]) {
      Map<DemiJournee,int> demiJournees = Provider.of<ConstituerState>(context).demiJourneesByReservation[widget._idReservation];
      if (demiJournees.containsKey(currentDemiJournee)) {
        _modifiedDemijournee.putIfAbsent(
            currentDemiJournee, () => demiJournees[currentDemiJournee]);
        return;
      }
    }
    _modifiedDemijournee.putIfAbsent(
        currentDemiJournee, () => rangePickerData["nbPersonne"]);
  }

  DateTime _incrementDateOneDay(DateTime currentDate) {
    return currentDate.add(Duration(days: 1));
  }

  ExpandableNotifier _body(BuildContext context) {
    final ReservationState reservationState =
        Provider.of<ReservationState>(context);
    final Map<String, dynamic> reservation =
        reservationState.reservationsById["${widget._idReservation}"];
    final ConstituerState constituerState =
        Provider.of<ConstituerState>(context);
    final Map<DemiJournee, int> demiJournees = constituerState.demiJourneesByReservation[widget._idReservation];
    final Map<String, dynamic> stat = constituerState.stats;
    List<Widget> listDemiJournees = [];
    if (editMode) constituerState.controllers.clear();
    print(demiJournees);
    editMode
        ? _modifiedDemijournee
            .forEach((DemiJournee demiJournee, int nbPersonne) {
            TextEditingController controller = TextEditingController();
            listDemiJournees.add(ListTile(
              leading: Checkbox(
                value: constituerState.isSelected(demiJournee),
                onChanged: (val) {
                  setState(() {
                    if (val)
                      constituerState.addSelected(demiJournee);
                    else
                      constituerState.deleteSelected(demiJournee);
                  });
                },
              ),
              dense: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Row(
                      children: <Widget>[
                        Text("${demiJournee.date}"),
                        Flexible(
                          child: Icon(Icons.wb_sunny,
                              color: demiJournee.typeDemiJournee ==
                                      TypeDemiJournee.jour
                                  ? Colors.yellow
                                  : Colors.grey),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(
                        RegExp("[0-9]+")
                        )
                      ],
                    controller: controller,
                    onChanged: (value) {
                      if (constituerState.demiJourneeSelected.length > 1) {
                        constituerState.demiJourneeSelected.forEach((dj) {
                          _modifiedDemijournee[dj] = int.parse(value);
                        });
                      }
                      _modifiedDemijournee[demiJournee] = int.parse(value);
                      setState(() {});
                    },
                  ))
                ],
              ),
            ));
            listDemiJournees.add(Divider());
            controller.text = "$nbPersonne";
            controller.selection =
                TextSelection.collapsed(offset: controller.text.length);
            constituerState.controllers
                .putIfAbsent(demiJournee, () => controller);
          })
        : demiJournees.forEach((DemiJournee demiJournee, int nbPersonne) {
            listDemiJournees.add(ListTile(
              dense: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Row(
                      children: <Widget>[
                        Text("${demiJournee.date}"),
                        Flexible(
                          child: Icon(Icons.wb_sunny,
                              color: demiJournee.typeDemiJournee ==
                                      TypeDemiJournee.jour
                                  ? Colors.yellow
                                  : Colors.grey),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text("$nbPersonne personnes"),
                  )
                ],
              ),
            ));
            listDemiJournees.add(Divider());
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
                      "Date Entree : ${reservation["dateEntree"]} ${reservation["typeDemiJourneeEntree"]}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Date Sortie : ${reservation["dateSortie"]} ${reservation["typeDemiJourneeSortie"]}",
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
                            children: listDemiJournees,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: !_editMode
                            ? <Widget>[
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      setEditMode(true,
                                          currentDemiJournees: demiJournees);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.today),
                                  onPressed: () async {
                                    var res = await showDialog(
                                        context: context,
                                        builder: (BuildContext ctx) {
                                          return ChangeDatesDialog(
                                            nbPersonne: double.parse(
                                                    "${stat != null ? stat["nbMoyennePersonne"] : "0"}")
                                                .floor(),
                                            dateEntree:
                                                "${reservation["dateEntree"]}",
                                            typeDemiJourneeEntree: reservation[
                                                        "typeDemiJourneeEntree"] ==
                                                    'Jour'
                                                ? TypeDemiJournee.jour
                                                : TypeDemiJournee.nuit,
                                            dateSortie:
                                                "${reservation["dateSortie"]}",
                                            typeDemiJourneeSortie: reservation[
                                                        "typeDemiJourneeSortie"] ==
                                                    'Jour'
                                                ? TypeDemiJournee.jour
                                                : TypeDemiJournee.nuit,
                                          );
                                        });
                                    if (res != null) {
                                      print(res);
                                      await generateDemiJourneesFromDateRangePicker(
                                          res, context);
                                      setState(() {
                                        setEditMode(true);
                                      });
                                    }
                                  },
                                ),
                              ]
                            : <Widget>[
                                IconButton(
                                  icon: constituerState.emptySelected()
                                      ? const Icon(
                                          Icons.check_box_outline_blank)
                                      : constituerState.allSelected()
                                          ? const Icon(Icons.check_box)
                                          : const Icon(
                                              Icons.indeterminate_check_box),
                                  onPressed: () async {
                                    if (constituerState.emptySelected()) {
                                      constituerState.addAllSelected();
                                    } else if (constituerState.allSelected()) {
                                      constituerState.deleteAllSelected();
                                    } else {
                                      constituerState.deleteAllSelected();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      setEditMode(false);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: _isPosting? null  : () async {
                                    setState((){
                                      _isPosting = true;
                                    });
                                    List<Map<String, String>> datas = []; 
                                    constituerState.controllers.forEach((dj, ctrl){
                                      Map<String, String> data = {};
                                      data["nbPersonne"] = ctrl.text;
                                      data["date"] = dj.date;
                                      data["typeDemiJournee"] = dj.typeDemiJournee == TypeDemiJournee.jour ? "Jour" : "Nuit";
                                      datas.add(data);
                                    });
                                  http.Response result = await http.put("${Config.apiURI}constituers/${widget._idReservation}",body: {"data" : json.encode(datas)});
                                  if(result.statusCode == 200){
                                    GlobalState().channel.sink.add("constituer ${widget._idReservation}");
                                    setState((){
                                      _editMode = false;
                                    });
                                  }
                                  setState((){
                                    _isPosting = false;
                                  });
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

