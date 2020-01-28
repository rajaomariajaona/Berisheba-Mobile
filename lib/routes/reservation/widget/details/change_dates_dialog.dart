import 'package:berisheba/routes/reservation/constituer_state.dart';
import 'package:berisheba/tools/date.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

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
