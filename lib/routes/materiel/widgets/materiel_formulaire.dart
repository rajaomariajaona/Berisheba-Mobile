import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/formatters/case_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class MaterielFormulaire extends StatefulWidget {
  MaterielFormulaire({Key key, this.materiel}) : super(key: key);
  final Map<String, dynamic> materiel;

  @override
  State createState() => _MaterielFormulaireState();
}

class _MaterielFormulaireState extends State<MaterielFormulaire> {
  final _formKey = GlobalKey<FormState>();
  bool isPostingData = false;
  String nom;
  int nbStock;

  final Map<String, FormFieldValidator> validators = {
    "nom": (value) {
      if (value.isEmpty) return "Champ vide";
      return null;
    },
    "nbStock": (value) {
      if (value.isEmpty) return "Champ vide";
      return null;
    }
  };

  final Map<String, List<TextInputFormatter>> inputFormatters = {
    "nom": <TextInputFormatter>[
      WhitelistingTextInputFormatter(RegExp("[A-zÀ-ú ]")),
      LengthLimitingTextInputFormatter(50),
      CapitalizeWordsInputFormatter()
    ],
    "nbStock": <TextInputFormatter>[
      WhitelistingTextInputFormatter(RegExp("[0-9]")),
      LengthLimitingTextInputFormatter(4),
    ]
  };

  @override
  void initState() {
    super.initState();
    final bool modifier = widget.materiel != null;
    nom = modifier ? widget.materiel["nomMateriel"] : "";
  }

  @override
  Widget build(BuildContext context) {
    final bool modifier = widget.materiel != null;
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
          modifier ? "Modifier materiel" : "Ajouter materiel",
          style: TextStyle(color: Config.appBarTextColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: Config.primaryBlue,
            ),
            onPressed: isPostingData
                ? null
                : () async {
                    setState(() {
                      isPostingData = true;
                    });
                    _formKey.currentState.save();
                    if (_formKey.currentState.validate()) {
                      dynamic result = modifier
                          ? await MaterielState.modifyData({
                              "nomMateriel": nom,
                              "nbStock" : nbStock
                            },idMateriel: widget.materiel["idMateriel"])
                          : await MaterielState.saveData({
                              "nomMateriel": nom,
                              "nbStock" : nbStock
                            });
                      print(result);
                      GlobalState().channel.sink.add("materiel");
                      Navigator.of(context).pop(true);
                    } else {
                      setState(() {
                        isPostingData = false;
                      });
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
                    labelText: "Nom du materiel",
                  ),
                  initialValue: modifier ? widget.materiel["nomMateriel"] : "",
                  onSaved: (val) {
                    setState(() {
                      nom = val;
                    });
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: validators["nbStock"],
                  inputFormatters: inputFormatters["nbStock"],
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Nombre en Stock",
                  ),
                  initialValue: modifier ? "${widget.materiel["nbStock"]}" : "",
                  onSaved: (val) {
                    setState(() {
                      nbStock = int.parse(val);
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
