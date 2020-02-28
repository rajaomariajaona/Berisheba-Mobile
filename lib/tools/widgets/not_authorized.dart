import 'package:berisheba/tools/formatters/case_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotAuthorized extends StatelessWidget {
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: NotAuthorized._scaffoldKey,
      body: SafeArea(child: _NotAuthorizedBody()),
    );
  }
}

class _NotAuthorizedBody extends StatefulWidget {
  const _NotAuthorizedBody({
    Key key,
  }) : super(key: key);

  @override
  __NotAuthorizedBodyState createState() => __NotAuthorizedBodyState();
}

class __NotAuthorizedBodyState extends State<_NotAuthorizedBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String utilisateur;
  String email;
  String description;
  final Map<String, FormFieldValidator> validators = {
    "utilisateur": (value) {
      if (value.isEmpty) return "Champ vide";
      return null;
    },
    "email": (value) {
      if (!RegExp("^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}\$")
              .hasMatch((value as String).toLowerCase()))
        return "Email incorrect";
      return null;
    },
    "adresse": (value) {
      if (value.isEmpty) return "Champ vide";
      return null;
    }
  };

  final Map<String, List<TextInputFormatter>> inputFormatters = {
    "utilisateur": <TextInputFormatter>[
      WhitelistingTextInputFormatter(RegExp("[A-Za-z ]")),
      LengthLimitingTextInputFormatter(50),
      CapitalizeWordsInputFormatter()
    ],
    "email": <TextInputFormatter>[
      LengthLimitingTextInputFormatter(50),
    ],
    "description": <TextInputFormatter>[LengthLimitingTextInputFormatter(256)],
  };
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/logo.png"),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      validator: validators["utilisateur"],
                      inputFormatters: inputFormatters["utilisateur"],
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: "Utilisateur *",
                      ),
                      onSaved: (value) {
                        utilisateur = value;
                      },
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      textCapitalization: TextCapitalization.none,
                      inputFormatters: inputFormatters["email"],
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: "Email",
                        helperText: "Pour suivre les changements"
                      ),
                      onSaved: (value) {
                        email = value;
                      },
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: inputFormatters["description"],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Description",
                        alignLabelWithHint: true,
                        hintText: "Decrivez pourquoi vous voulez avoir acces à l'application",
                      
                      ),
                      maxLines: 4,
                      onSaved: (value) {
                        description = value;
                      },
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(onPressed: () async {
              var res = await showDialog(context: context,builder: (ctx) {
                return AlertDialog(
                  content: Padding(padding: EdgeInsets.all(15),child: Text(
                    "Voulez vous vraiment quitter?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      
                    ),
                  ),),
                  actions: <Widget>[
                    FlatButton(onPressed: (){
                      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
                    }, child: Text("Quitter")),
                    FlatButton(onPressed: (){
                      Navigator.of(ctx).pop();
                    }, child: Text("Annuler")),
                  ],
                );
              });
               
            }, child: Text("Annuler")),
            FlatButton(onPressed: () {
              NotAuthorized._scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Ces données ont été transmis\nDuree de réponse: Entre 24h et 7jrs")));
            }, child: Text("Confirmer"))
          ],
        )
      ],
    );
  }
}
