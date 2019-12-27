//Mila
import 'package:berisheba/config.dart';
import 'package:berisheba/states/client_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum PopupMenuChoix { appel, reservation, autre }

class ClientListe extends StatefulWidget {
  final Map<String, dynamic> _client;
  const ClientListe(
    this._client, {
    Key key,
  }) : super(key: key);
  @override
  State createState() => _ClientListeState();
}

class _ClientListeState extends State<ClientListe> {
  @override
  Widget build(BuildContext context) {
    final ClientState clientState = Provider.of<ClientState>(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        leading: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          color: Config.primaryBlue,
                          style: BorderStyle.solid,
                          width: 1))),
              padding: EdgeInsets.symmetric(horizontal: 17, vertical: 3),
              child: Icon(
                Icons.contact_phone,
                size: 30,
              ),
            )
          ],
        ),
        contentPadding: EdgeInsets.fromLTRB(0, 5, 10, 5),
        title: Text(
            "${widget._client["nomClient"]} ${widget._client["prenomClient"]}",
            style: TextStyle(fontSize: 16)),
        onTap: () {
          if (clientState.isDeleting) {
            setState(() {
              if (clientState.isSelected(widget._client["idClient"]))
                clientState.deleteSelected(widget._client["idClient"]);
              else
                clientState.addSelected(widget._client["idClient"]);
            });
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ClientDetail(widget._client);
            }));
          }
        },
        onLongPress: () {
          clientState.isDeleting = true;
          setState(() {
            clientState.addSelected(widget._client["idClient"]);
          });
        },
        trailing: clientState.isDeleting
            ? Checkbox(
                value: clientState.isSelected(widget._client["idClient"]),
                onChanged: (val) {
                  setState(() {
                    if (val)
                      clientState.addSelected(widget._client["idClient"]);
                    else
                      clientState.deleteSelected(widget._client["idClient"]);
                  });
                },
              )
            : null,
      ),
    );
  }
}

class ClientDetail extends StatelessWidget {
  final Map<String, dynamic> _client;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Config.appBarBgColor,
        centerTitle: true,
        title: Text(
          "${_client["nomClient"]}",
          style: TextStyle(color: Config.appBarTextColor),
        ),
        iconTheme: IconThemeData(color: Config.primaryBlue),
      ),
      body: SafeArea(
        bottom: true,
        maintainBottomViewPadding: true,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.contact_phone),
                          onPressed: () {},
                        ),
                        title: Text(
                            "${_client["nomClient"]} ${_client["prenomClient"]}"),
                      ),
                      ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.smartphone),
                          onPressed: () {},
                        ),
                        title: Text("${_client["numTelClient"]} "),
                        onTap: () {
                          if (canLaunch("tel:${_client["numTelClient"]}") !=
                              null) launch("tel:${_client["numTelClient"]}");
                        },
                      ),
                      ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () {},
                        ),
                        title: Text("${_client["adresseClient"]} "),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Flexible(
                        flex: 5,
                        child: LayoutBuilder(
                            builder: (BuildContext ctx, BoxConstraints box) {
                          return AspectRatio(
                            aspectRatio: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.call,
                                  color: Colors.white,
                                  size: box.maxWidth / 3,
                                ),
                                onPressed: () {
                                  if (canLaunch(
                                          "tel:${_client["numTelClient"]}") !=
                                      null)
                                    launch("tel:${_client["numTelClient"]}");
                                },
                              ),
                              width: box.maxWidth,
                            ),
                          );
                        }),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Flexible(
                        flex: 5,
                        child: LayoutBuilder(
                            builder: (BuildContext ctx, BoxConstraints box) {
                          return AspectRatio(
                            aspectRatio: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: box.maxWidth / 3,
                                ),
                                onPressed: () {},
                              ),
                              width: box.maxWidth,
                            ),
                          );
                        }),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Flexible(
                        flex: 5,
                        child: LayoutBuilder(
                            builder: (BuildContext ctx, BoxConstraints box) {
                          return AspectRatio(
                            aspectRatio: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: box.maxWidth / 3,
                                ),
                                onPressed: () async {
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                    builder: (context) => ClientFormulaire(
                                      client: _client,
                                    ),
                                  ));
                                },
                              ),
                              width: box.maxWidth,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ClientDetail(this._client, {Key key}) : super(key: key);
}

class ClientFormulaire extends StatefulWidget {
  ClientFormulaire({Key key, this.client}) : super(key: key);
  final Map<String, dynamic> client;
  @override
  State createState() => _ClientFormulaireState();
}

class _ClientFormulaireState extends State<ClientFormulaire> {
  String nom;
  String prenom;
  String adresse;
  String num;

  @override
  void initState() {
    // TODO: implement initState
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
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Form(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Nom",
                  ),
                  initialValue: modifier ? widget.client["nomClient"] : "",
                  onSaved: (val) {
                    setState(() {
                      nom = val;
                    });
                  },
                ),
                TextFormField(
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
                  keyboardType: TextInputType.phone,
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

class ClientFloatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider.of<ClientState>(context).isDeleting
        ? Container()
        : FloatingActionButton(
            child: Icon(Icons.group_add),
            onPressed: () async {
              var t = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ClientFormulaire(),
              ));
              print(t);
            },
          );
  }
}

class ClientAppBar {
  final BuildContext _context;
  ClientAppBar(this._context);

  AppBar get appbar {
    TabState _tabState = Provider.of<TabState>(_context);
    ClientState _clientState = Provider.of<ClientState>(_context);
    return _clientState.isDeleting
        ? AppBar(
            backgroundColor: Colors.grey,
            actionsIconTheme: const IconThemeData(
              color: Colors.white,
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _clientState.isDeleting = false;
              },
            ),
            actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    http.post(Config.apiURI + "clients",
                        body: {"deleteList": _clientState.selected.toString()});
                  },
                )
              ])
        : AppBar(
            centerTitle: true,
            title: Text(
              _tabState.titleAppBar,
            ),
            actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.sort_by_alpha),
                  onPressed: () async {
                    await _clientState.setIsReverse(!_clientState.isNotReverse);
                  },
                )
              ]);
  }
}
