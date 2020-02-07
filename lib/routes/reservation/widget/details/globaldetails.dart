import 'package:berisheba/routes/client/client_portrait.dart';
import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/routes/client/widgets/client_float_button.dart';
import 'package:berisheba/routes/client/widgets/client_selector.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/formatters/CaseInputFormatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:provider/provider.dart';

class ReservationGlobalDetails extends StatefulWidget {
  final int _idReservation;
  ReservationGlobalDetails(this._idReservation, {Key key}) : super(key: key);
  @override
  _ReservationGlobalDetailsState createState() =>
      _ReservationGlobalDetailsState();
}

class _ReservationGlobalDetailsState extends State<ReservationGlobalDetails> {
  Map<String, dynamic> _modifiedGlobalDetails = {};
  bool _editMode = false;
  bool _isPosting = false;
  bool get editMode => _editMode;
  void setEditMode(bool v, {Map<String, dynamic> currentGlobalDetails}) {
    setState(() {
      _editMode = v;
    });

    if (currentGlobalDetails != null && v) {
      _modifiedGlobalDetails = currentGlobalDetails;
    }
    if (v) {
      _client.text =
          "${_modifiedGlobalDetails["nomClient"]} ${_modifiedGlobalDetails["prenomClient"]}";
      idClient = _modifiedGlobalDetails["idClient"];
      setState(() {
        couleur = Color(int.parse(_modifiedGlobalDetails["couleur"]));
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int idClient;
  TextEditingController _client = TextEditingController();
  Color couleur;
  String nomReservation;
  double prixPersonne;

  Widget _globalDetails(String item, String itemDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[Text("$item: "), Text(itemDetails)],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  editMode
                      ? Container()
                      : GestureDetector(
                          child: const Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: const Icon(Icons.edit),
                          ),
                          onTap: () {
                            setEditMode(true,
                                currentGlobalDetails: Provider.of<
                                        ReservationState>(context)
                                    .reservationsById[widget._idReservation]);
                          },
                        ),
                ],
              ),
              editMode
                  ? Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(child: _nomReservation()),
                              _colorPicker(context),
                            ],
                          ),
                          _clientSelector(context),
                          _prixPersonne(),
                        ],
                      ),
                    )
                  : Consumer<ReservationState>(
                      builder: (ctx, _reservationState, _) {
                        final Map<String, dynamic> _reservation =
                            _reservationState
                                .reservationsById[widget._idReservation];
                        return Column(
                          children: <Widget>[
                            _globalDetails("Client",
                                "${_reservation["nomClient"]} ${_reservation["prenomClient"]}"),
                            _globalDetails("Prix par personne",
                                "${_reservation["prixPersonne"]}"),
                          ],
                        );
                      },
                    ),
              editMode
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setEditMode(false);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () async {
                            _formKey.currentState.save();
                            if (_formKey.currentState.validate()) {
                              Map<String, String> data = {
                                "nomReservation": nomReservation,
                                "prixPersonne": prixPersonne.toString(),
                                "idClient": idClient.toString(),
                                "couleur": couleur.value.toString(),
                              };

                              try {
                                await ReservationState.modifyData(data,
                                        idReservation: widget._idReservation)
                                    .whenComplete(() {
                                  setEditMode(false);
                                  GlobalState().channel.sink.add(
                                      "reservation ${widget._idReservation}");
                                });
                              } catch (error) {
                                print(error?.response?.data);
                              }
                            }
                          },
                        ),
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  IconButton _colorPicker(BuildContext context) {
    return IconButton(
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
    );
  }

  TextFormField _prixPersonne() {
    return TextFormField(
      initialValue: _modifiedGlobalDetails["prixPersonne"].toString(),
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

  TextFormField _nomReservation() {
    return TextFormField(
      initialValue: _modifiedGlobalDetails["nomReservation"],
      validator: _isValidNomReservation,
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

  String _isValidNomReservation(String value) {
    if (value == "") {
      return "Champ vide";
    }
    return null;
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
              validator: _isOneClientSelected,
              controller: _client,
              readOnly: true,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Client",
              ),
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
      return ClientSelectorBody();
    }));
    if (result != null && int.tryParse("$result") != null) {
      idClient = int.parse("$result");
      var client =
          Provider.of<ClientState>(context).listClientByIdClient["$result"];
      _client.text = "${client["nomClient"]} ${client["prenomClient"]}";
    }
  }

  String _isOneClientSelected(String value) {
    if (value == "") {
      return "Veuillez selectionner un client";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }
}
