import 'package:berisheba/formatters/CaseInputFormatter.dart';
import 'package:berisheba/formatters/NumTelInputFormatter.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ClientFormulaire extends StatefulWidget {
  ClientFormulaire({Key key, this.client}) : super(key: key);
  final Map<String, dynamic> client;

  @override
  State createState() => _ClientFormulaireState();
}

class _ClientFormulaireState extends State<ClientFormulaire> {
  final _formKey = GlobalKey<FormState>();

  String nom;
  String prenom;
  String adresse;
  String num;

  final Map<String, FormFieldValidator> validators = {
    "nom": (value) {
      if (value.isEmpty) return "Champ vide";
      return null;
    },
    "prenom": (value) {
      if (value.isEmpty) return "Champ vide";
      return null;
    },
    "num": (value) {
      if (value.isEmpty) return "Champ vide";
      if (!RegExp("^03[2-4,9]\ [0-9]{2}\ [0-9]{3}\ [0-9]{2}\$")
              .hasMatch(value) &&
          !RegExp("^020\ [0-9]{2}\ [0-9]{3}\ [0-9]{2}\$").hasMatch(value))
        return "Numero telephone incorrect";
      return null;
    },
    "adresse": (value) {
      if (value.isEmpty) return "Champ vide";
      return null;
    }
  };

  final Map<String, List<TextInputFormatter>> inputFormatters = {
    "nom": <TextInputFormatter>[
      WhitelistingTextInputFormatter(RegExp("[A-Za-z ]")),
      LengthLimitingTextInputFormatter(50),
      ToUpperCaseInputFormatter(),
    ],
    "prenom": <TextInputFormatter>[
      WhitelistingTextInputFormatter(RegExp("[A-Za-z ]")),
      LengthLimitingTextInputFormatter(50),
      CapitalizeWordsInputFormatter()
    ],
    "num": <TextInputFormatter>[
      WhitelistingTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(10),
      NumTelInputFormatter(),
    ],
    "adresse": <TextInputFormatter>[LengthLimitingTextInputFormatter(100)],
  };

  @override
  void initState() {
    super.initState();
    final bool modifier = widget.client != null;
    nom = modifier ? widget.client["nomClient"] : "";
    prenom = modifier ? widget.client["prenomClient"] : "";
    adresse = modifier ? widget.client["adresseClient"] : "";
    num = modifier ? widget.client["numTelClient"] : "";
  }

  @override
  Widget build(BuildContext context) {
    final bool modifier = widget.client != null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Config.primaryBlue,
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        title: Text(
          modifier ? "Modifier client" : "Ajouter client",
          style: TextStyle(color: Config.appBarTextColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: Config.primaryBlue,
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                modifier
                    ? await http.put(
                        Config.apiURI + "clients/${widget.client["idClient"]}",
                        body: {
                          "nomClient": nom,
                          "prenomClient": prenom,
                          "adresseClient": adresse,
                          "numTelClient": num
                        },
                      )
                    : await http.post(
                        Config.apiURI + "clients",
                        body: {
                          "nomClient": nom,
                          "prenomClient": prenom,
                          "adresseClient": adresse,
                          "numTelClient": num
                        },
                      );
                modifier
                    ? GlobalState().channel.sink.add("clientWOindicator")
                    : GlobalState().channel.sink.add("clientWindicator");
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Column(
              children: <Widget>[
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  validator: validators["nom"],
                  inputFormatters: inputFormatters["nom"],
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Nom",
                  ),
                  initialValue: modifier ? widget.client["nomClient"] : "",
                  onChanged: (val) {
                    setState(() {
                      nom = val;
                    });
                  },
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  validator: validators["prenom"],
                  inputFormatters: inputFormatters["prenom"],
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Prenom",
                  ),
                  initialValue: modifier ? widget.client["prenomClient"] : "",
                  onChanged: (val) {
                    setState(() {
                      prenom = val;
                    });
                  },
                ),
                TextFormField(
                  validator: validators["num"],
                  inputFormatters: inputFormatters["num"],
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Num telephone",
                  ),
                  initialValue: modifier ? widget.client["numTelClient"] : "",
                  onChanged: (val) {
                    setState(() {
                      num = val;
                    });
                  },
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  validator: validators["adresse"],
                  inputFormatters: inputFormatters["adresse"],
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Adresse",
                  ),
                  initialValue: modifier ? widget.client["adresseClient"] : "",
                  onChanged: (val) {
                    setState(() {
                      adresse = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
