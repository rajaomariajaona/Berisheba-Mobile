import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/formatters/CaseInputFormatter.dart';
import 'package:berisheba/tools/formatters/NumTelInputFormatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SalleFormulaire extends StatefulWidget {
  SalleFormulaire({Key key, this.salle}) : super(key: key);
  final Map<String, dynamic> salle;

  @override
  State createState() => _SalleFormulaireState();
}

class _SalleFormulaireState extends State<SalleFormulaire> {
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
    final bool modifier = widget.salle != null;
    nom = modifier ? widget.salle["nomSalle"] : "";
    prenom = modifier ? widget.salle["prenomSalle"] : "";
    adresse = modifier ? widget.salle["adresseSalle"] : "";
    num = modifier ? widget.salle["numTelSalle"] : "";
  }

  @override
  Widget build(BuildContext context) {
    final bool modifier = widget.salle != null;
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
          modifier ? "Modifier salle" : "Ajouter salle",
          style: TextStyle(color: Config.appBarTextColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: Config.primaryBlue,
            ),
            onPressed: () async {
              _formKey.currentState.save();
              if (_formKey.currentState.validate()) {
                dynamic result = modifier
                    ? await http.put(
                  Config.apiURI + "salles/${widget.salle["idSalle"]}",
                  body: {
                    "nomSalle": nom,
                    "prenomSalle": prenom,
                    "adresseSalle": adresse,
                    "numTelSalle": num
                  },
                )
                    : await http.post(
                  Config.apiURI + "salles",
                  body: {
                    "nomSalle": nom,
                    "prenomSalle": prenom,
                    "adresseSalle": adresse,
                    "numTelSalle": num
                  },
                );
                print(result);
                GlobalState().channel.sink.add("salle");
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
                  initialValue: modifier ? widget.salle["nomSalle"] : "",
                  onSaved: (val) {
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
                  initialValue: modifier ? widget.salle["prenomSalle"] : "",
                  onSaved: (val) {
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
                  initialValue: modifier ? widget.salle["numTelSalle"] : "",
                  onSaved: (val) {
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
                  initialValue: modifier ? widget.salle["adresseSalle"] : "",
                  onSaved: (val) {
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
