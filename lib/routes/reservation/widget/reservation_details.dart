import 'package:berisheba/routes/reservation/constituer_state.dart';
import 'package:berisheba/routes/reservation/reservation_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/date.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

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
  bool editMode = false;
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
  Map<DemiJournee, int> _modifiedDemijournee = {};
  bool _editMode = false;
  bool get editMode => _editMode;
  void setEditMode(bool v, {Map<DemiJournee, int> currentDemiJournees}) {
    _editMode = v;
    if(!v)
      _modifiedDemijournee.clear();
    if(currentDemiJournees != null && v && _modifiedDemijournee.isEmpty){
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
      var demiJournees = Provider.of<ConstituerState>(context).demiJournees;
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
    final Map<DemiJournee, int> demiJournees = constituerState.demiJournees;
    final Map<String, dynamic> stat = constituerState.stats;
    List<Widget> listDemiJournees = [];
    if(editMode)
      constituerState.controllers.clear();
    editMode ?
    _modifiedDemijournee.forEach((DemiJournee demiJournee, int nbPersonne) {
      TextEditingController controller = TextEditingController();
      
      listDemiJournees.add(ListTile(
        leading:Checkbox(
                value: true,
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
                        color:
                            demiJournee.typeDemiJournee == TypeDemiJournee.jour
                                ? Colors.yellow
                                : Colors.grey),
                  )
                ],
              ),
            ),
            Flexible(
              child:TextField(
                controller: controller,
              )
            )
          ],
        ),
      ));
      listDemiJournees.add(Divider());
      controller.text = "$nbPersonne";
      constituerState.controllers.putIfAbsent(demiJournee, () => controller);
    }) : demiJournees.forEach((DemiJournee demiJournee, int nbPersonne) {
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
                        color:
                            demiJournee.typeDemiJournee == TypeDemiJournee.jour
                                ? Colors.yellow
                                : Colors.grey),
                  )
                ],
              ),
            ),
            Flexible(
              child:
               Text("$nbPersonne personnes"),


              /**
               * 
               * Selected DemiJournee Selected
               * choix 1 : DemiJournee Map <Controller>
               * Choix 2 : DemiJournee
               * choix 3 : Hanamboarana Classe 1 TextField de a sa Creation manamboatra Controller izay afaka gettena... 
               */
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
                            children: listDemiJournees,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: !editMode
                            ? <Widget>[
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      setEditMode(true, currentDemiJournees: demiJournees);
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
                                                "${reservation["DateEntree"]}",
                                            typeDemiJourneeEntree: reservation[
                                                        "TypeDemiJourneeEntree"] ==
                                                    'Jour'
                                                ? TypeDemiJournee.jour
                                                : TypeDemiJournee.nuit,
                                            dateSortie:
                                                "${reservation["DateSortie"]}",
                                            typeDemiJourneeSortie: reservation[
                                                        "TypeDemiJourneeSortie"] ==
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
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      setEditMode(false);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: () {},
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

class ChangeDatesDialog extends StatefulWidget {
  const ChangeDatesDialog(
      {Key key,
      @required this.dateEntree,
      @required this.dateSortie,
      @required this.typeDemiJourneeEntree,
      @required this.typeDemiJourneeSortie,
      @required this.nbPersonne})
      : super(key: key);
  final int nbPersonne;
  final String dateEntree;
  final TypeDemiJournee typeDemiJourneeSortie;
  final String dateSortie;
  final TypeDemiJournee typeDemiJourneeEntree;

  @override
  State<StatefulWidget> createState() => _ChangeDatesDialogState();
}

class _ChangeDatesDialogState extends State<ChangeDatesDialog> {
  String dateEntree;
  TypeDemiJournee typeDemiJourneeSortie;
  String dateSortie;
  TypeDemiJournee typeDemiJourneeEntree;
  var _dateEntree = TextEditingController();
  var _dateSortie = TextEditingController();
  var _nbPersonne = TextEditingController();
  bool remplaceAll = false;
  int nbPersonne;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  void initState() {
    nbPersonne = widget.nbPersonne;
    dateEntree = widget.dateEntree;
    dateSortie = widget.dateSortie;
    typeDemiJourneeSortie = widget.typeDemiJourneeSortie;
    typeDemiJourneeEntree = widget.typeDemiJourneeEntree;
    _dateEntree.text = dateEntree;
    _dateSortie.text = dateSortie;
    _nbPersonne.text = nbPersonne.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Form(
          key: _formState,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(child: _date(context)),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Checkbox(
                      value: remplaceAll,
                      onChanged: (bool val) {
                        setState(() {
                          remplaceAll = val;
                        });
                      },
                    ),
                    const Text("Tout remplacer"),
                  ],
                ),
              ),
              Flexible(
                child: TextFormField(
                  controller: _nbPersonne,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Nombre de Personne",
                  ),
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: const Text("Annuler"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: const Text("Enregistrer"),
                      onPressed: () {
                        if (_formState.currentState.validate()) {
                          _formState.currentState.save();
                          Map<String, dynamic> data = {
                            "dateEntree": dateEntree,
                            "typeDemiJourneeEntree": typeDemiJourneeEntree,
                            "dateSortie": dateSortie,
                            "typeDemiJourneeSortie": typeDemiJourneeSortie,
                            "nbPersonne": nbPersonne,
                            "remplaceAll": remplaceAll
                          };
                          Navigator.of(context).pop(data);
                        }
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row _date(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
          flex: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: FocusScope(
                  canRequestFocus: false,
                  child: TextFormField(
                    controller: _dateEntree,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Date Entree",
                    ),
                    onSaved: (val) {
                      setState(() {
                        dateEntree = val;
                      });
                    },
                  ),
                ),
              ),
              _radioButtonTypeDemiJourneeEntree(),
            ],
          ),
        ),
        Flexible(
          flex: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: FocusScope(
                  canRequestFocus: false,
                  child: TextFormField(
                    controller: _dateSortie,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Date Sortie",
                    ),
                    onSaved: (val) {
                      setState(() {
                        dateSortie = val;
                      });
                    },
                  ),
                ),
              ),
              _radioButtonTypeDemiJourneeSortie(),
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            icon: Icon(Icons.today),
            onPressed: () async {
              final List<DateTime> picked =
                  await DateRangePicker.showDatePicker(
                      context: context,
                      initialFirstDate: DateTime.parse(_dateEntree.text),
                      initialLastDate: DateTime.parse(_dateSortie.text),
                      firstDate: DateTime.parse(_dateEntree.text)
                          .subtract(new Duration(days: 10)),
                      lastDate: DateTime(2040));
              if (picked != null) {
                if (picked.length == 2) {
                  _dateEntree.text = generateDateString(picked[0]);
                  _dateSortie.text = generateDateString(picked[1]);
                } else {
                  _dateEntree.text = generateDateString(picked[0]);
                  _dateSortie.text = generateDateString(picked[0]);
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Flexible _radioButtonTypeDemiJourneeEntree() {
    return Flexible(
      flex: 1,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Radio(
                    onChanged: (val) {
                      setState(() {
                        typeDemiJourneeEntree = val;
                      });
                    },
                    value: TypeDemiJournee.jour,
                    groupValue: typeDemiJourneeEntree,
                  ),
                ),
                Expanded(flex: 1, child: const Text("Jour")),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Radio(
                    onChanged: (val) {
                      setState(() {
                        typeDemiJourneeEntree = val;
                      });
                    },
                    value: TypeDemiJournee.nuit,
                    groupValue: typeDemiJourneeEntree,
                  ),
                ),
                Expanded(flex: 1, child: const Text("Nuit")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Flexible _radioButtonTypeDemiJourneeSortie() {
    return Flexible(
      flex: 1,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Radio(
                    onChanged: (val) {
                      setState(() {
                        typeDemiJourneeSortie = val;
                      });
                    },
                    value: TypeDemiJournee.jour,
                    groupValue: typeDemiJourneeSortie,
                  ),
                ),
                Expanded(flex: 1, child: const Text("Jour")),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Radio(
                    onChanged: (val) {
                      setState(() {
                        typeDemiJourneeSortie = val;
                      });
                    },
                    value: TypeDemiJournee.nuit,
                    groupValue: typeDemiJourneeSortie,
                  ),
                ),
                Expanded(flex: 1, child: const Text("Nuit")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
