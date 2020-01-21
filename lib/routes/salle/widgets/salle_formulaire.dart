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
  };

  final Map<String, List<TextInputFormatter>> inputFormatters = {
    "nom": <TextInputFormatter>[
      WhitelistingTextInputFormatter(RegExp("[A-Za-z ]")),
      LengthLimitingTextInputFormatter(50),
      CapitalizeWordsInputFormatter()
    ],
  };

  @override
  void initState() {
    super.initState();
    final bool modifier = widget.salle != null;
    nom = modifier ? widget.salle["nomSalle"] : "";
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
                  },
                )
                    : await http.post(
                  Config.apiURI + "salles",
                  body: {
                    "nomSalle": nom,
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
                  textCapitalization: TextCapitalization.words,
                  validator: validators["nom"],
                  inputFormatters: inputFormatters["nom"],
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Nom de la salle",
                  ),
                  initialValue: modifier ? widget.salle["nomSalle"] : "",
                  onSaved: (val) {
                    setState(() {
                      nom = val;
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
