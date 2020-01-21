import 'package:berisheba/routes/client/client_portrait.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/date.dart';
import 'package:berisheba/tools/formatters/CaseInputFormatter.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ReservationFormulaire extends StatefulWidget {
  ReservationFormulaire({Key key}) : super(key: key);

  @override
  _ReservationFormulaireState createState() => _ReservationFormulaireState();
}

enum TypeDemiJournee { jour, nuit }

class _ReservationFormulaireState extends State<ReservationFormulaire> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String nomReservation;
  String dateEntree = generateDateString(DateTime.now());
  var _dateEntree = TextEditingController();
  String dateSortie = generateDateString(DateTime.now());
  var _dateSortie = TextEditingController();
  TypeDemiJournee typeDemiJourneeEntree = TypeDemiJournee.jour;

  TypeDemiJournee typeDemiJourneeSortie = TypeDemiJournee.jour;

  int idClient;
  var _client = TextEditingController();
  Color couleur = Color(4294198070);
  double prixPersonne;
  final bool etatReservation = false;
  int nbPersonne;

  @override
  void initState() {
    _dateEntree.text = dateEntree;
    _dateSortie.text = dateSortie;
    _client.text = "";
    super.initState();
  }

  Future<void> _saveToDatabase() async {
    Map<String, dynamic> data = {
      "nomReservation": nomReservation,
      "dateEntree": dateEntree,
      "typeDemiJourneeEntree":
          typeDemiJourneeEntree == TypeDemiJournee.jour ? "Jour" : "Nuit",
      "dateSortie": dateSortie,
      "typeDemiJourneeSortie":
          typeDemiJourneeSortie == TypeDemiJournee.jour ? "Jour" : "Nuit",
      "prixPersonne": prixPersonne.toString(),
      "nbPersonne": nbPersonne.toString(),
      "idClient": idClient.toString(),
      "couleur": couleur.value.toString(),
      //TODO: ADD Color picker
      "etatReservation": etatReservation.toString(),
    };
    print(data);
    var result = await http.post(
      Config.apiURI + "reservations",
      body: data,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        bottom: true,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(child: _nomReservation()),
                    IconButton(
                      padding: EdgeInsets.all(0),
                      color: couleur,
                      icon: Icon(Icons.color_lens),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              titlePadding: const EdgeInsets.all(0.0),
                              contentPadding: const EdgeInsets.all(0.0),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: couleur,
                                  onColorChanged: (newCouleur) {
                                    print(newCouleur.value.toString());
                                    setState(() {
                                      couleur = newCouleur;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                _clientSelector(context),
                _date(context),
                _nombrePersonne(),
                _prixPersonne(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RaisedButton(
                        color: Config.primaryBlue,
                        child: const Text(
                          "Enregistrer",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          _formKey.currentState.save();
                          if (_formKey.currentState.validate()) {
                            _saveToDatabase().then((_){
                              GlobalState().streamController.sink.add("reservation");
                              Navigator.of(context).pop(true);
                            });
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
      ),
    );
  }

  TextFormField _prixPersonne() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        labelText: "Prix par Personne",
      ),
      onSaved: (val) {
        setState(() {
          prixPersonne = double.tryParse(val) ?? 0;
        });
      },
    );
  }

  TextFormField _nombrePersonne() {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        labelText: "Nombre de Personne",
      ),
      onSaved: (val) {
        setState(() {
          nbPersonne = int.tryParse(val) ?? 0;
        });
      },
    );
  }

  Row _clientSelector(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: FocusScope(
            canRequestFocus: false,
            child: TextFormField(
              controller: _client,
              readOnly: true,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Client",
              ),
              onSaved: (val) {
                setState(() {
                  dateEntree = val;
                });
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.supervised_user_circle),
          onPressed: () async => await _showClientSelector(context),
        ),
      ],
    );
  }

  Future<void> _showClientSelector(BuildContext context) async {
    var result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return Scaffold(
        appBar: AppBar(),
        body: ClientPortrait(),
      );
    }));
    if (result != null && int.tryParse("$result") != null) {
      idClient = int.parse("$result");
      var client =
          Provider.of<ClientState>(context).listClientByIdClient["$result"];
      _client.text = "${client["nomClient"]} ${client["prenomClient"]}";
    }
  }

  TextFormField _nomReservation() {
    return TextFormField(
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        CapitalizeWordsInputFormatter(),
      ],
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        labelText: "Reservation",
      ),
      onSaved: (val) {
        setState(() {
          nomReservation = val;
        });
      },
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
                        dateEntree = val;
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
                      firstDate:
                          DateTime.parse(generateDateString(DateTime.now())),
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
