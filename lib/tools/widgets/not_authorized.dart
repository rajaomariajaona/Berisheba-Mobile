import 'package:berisheba/main.dart';
import 'package:berisheba/states/authorization_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/formatters/case_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NotAuthorized extends StatelessWidget {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: NotAuthorized._scaffoldKey,
      body: WillPopScope(
          onWillPop: () => Future.value(false),
          child: SafeArea(child: _NotAuthorizedBody())),
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
          .hasMatch((value as String).toLowerCase())) return "Email incorrect";
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
  void initState() {
    AuthorizationState().fetchData();
    super.initState();
  }

  final TextEditingController utilisateurController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthorizationState state = Provider.of<AuthorizationState>(context);
    utilisateurController.text = state.details["utilisateur"];
    emailController.text = state.details["email"];
    descriptionController.text = state.details["description"];
    // utilisateurController.selection = TextSelection.collapsed(
    //     offset: (state.details["utilisateur"] as String).length);
    // emailController.selection = TextSelection.collapsed(
    //     offset: (state.details["email"] as String).length);
    // descriptionController.selection = TextSelection.collapsed(
    //     offset: (state.details["description"] as String).length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.details["authorized"] ?? false) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          if ((MyApp.splashScreen != null) ? MyApp.splashScreen.isCurrent : false) {
            GlobalState().navigatorState.currentState.pushNamed("/");
          }
        }
      }
    });
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
                      controller: utilisateurController,
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
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: emailController,
                      textCapitalization: TextCapitalization.none,
                      inputFormatters: inputFormatters["email"],
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Email",
                          helperText: "Pour suivre les changements"),
                      onSaved: (value) {
                        email = value;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: inputFormatters["description"],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Description",
                        alignLabelWithHint: true,
                        hintText:
                            "Decrivez pourquoi vous voulez avoir acces à l'application",
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
        Selector<AuthorizationState, String>(
            selector: (ctx, _authorizationState) =>
                _authorizationState.details["authorized"]?.toString() ?? "",
            shouldRebuild: (a, b) => a != b,
            builder: (ctx, status, _) {
              String statusText = "";
              switch (status) {
                case "true":
                  statusText = "Autorisé";
                  break;
                case "false":
                  statusText = "Non Autorisé";
                  break;
                case "null":
                  statusText = "En attente";
                  break;
                default:
                  break;
              }
              return statusText == ""
                  ? Container()
                  : Text("Status: $statusText");
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          content: Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              "Voulez vous vraiment quitter?",
                              textAlign: TextAlign.center,
                              style: TextStyle(),
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  SystemChannels.platform
                                      .invokeMethod("SystemNavigator.pop");
                                },
                                child: Text("Quitter")),
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text("Annuler")),
                          ],
                        );
                      });
                },
                child: Text("Annuler")),
            FlatButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    await AuthorizationState.saveData({
                      "utilisateur": utilisateur,
                      "email": email,
                      "description": description
                    }).then((_) async {
                      await AuthorizationState().fetchData();
                    }).catchError((err) {});
                  }
                  NotAuthorized._scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(
                          "Ces données ont été transmis\nDuree de réponse: Entre 24h et 7jrs")));
                },
                child: Text("Confirmer")),
            FlatButton(
                onPressed: () async {
                  await AuthorizationState().fetchData();
                },
                child: Text("Actualiser")),
          ],
        )
      ],
    );
  }
}
