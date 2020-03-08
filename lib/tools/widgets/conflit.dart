import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/widgets/conflit/conflit_materiel.dart';
import 'package:berisheba/tools/widgets/conflit/conflit_payer.dart';
import 'package:berisheba/tools/widgets/conflit/conflit_salle.dart';
import 'package:berisheba/tools/widgets/conflit/conflit_ustensile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConflitResolver extends StatelessWidget {
  final int idReservation;
  ConflitResolver({@required this.idReservation});
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ConflitMaterielState(),
          ),
          ChangeNotifierProvider(
            create: (_) => ConflitUstensileState(),
          ),
          ChangeNotifierProvider(
            create: (_) => ConflitPayerState(),
          ),
        ],
        child: Scaffold(
          body: SafeArea(child: ConflitBody(idReservation: idReservation)),
        ),
      ),
    );
  }
}

class ConflitBody extends StatefulWidget {
  const ConflitBody({
    Key key,
    @required this.idReservation,
  }) : super(key: key);

  final int idReservation;

  @override
  State<StatefulWidget> createState() => _ConflitBodyState();
}

class _ConflitBodyState extends State<ConflitBody> {
  Map<int, Choice> choix = {};
  Map<int, dynamic> _salle;
  Map<int, dynamic> _materiel;
  Map<int, dynamic> _ustensile;
  Map<String, dynamic> _payer;
  int idReservation;
  @override
  void initState() {
    idReservation = widget.idReservation;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var temp = Provider.of<ConflitState>(context, listen: false)
        .conflictByIdReservation[idReservation];
    if (temp != null) {
      _salle = temp["salle"];
      if (_salle != null)
        for (int idSalle in _salle.keys) choix[idSalle] = Choice.change;
      _materiel = temp["materiel"];
      _ustensile = temp["ustensile"];
      print(temp["payer"]);
      _payer = temp["payer"];
    } else {
      Navigator.of(context).pop(null);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: Column(
                children: <Widget>[
                  if (_salle != null)
                    ConflitSalle(
                      idReservation: idReservation,
                      choix: choix,
                      conflit: _salle,
                      callback: (int idSalle, Choice val) {
                        setState(() {
                          choix[idSalle] = val;
                        });
                      },
                    ),
                  if (_materiel != null) ConflitMateriel(conflit: _materiel),
                  if (_ustensile != null) ConflitUstensile(conflit: _ustensile),
                  if (_payer != null) ConflitPayer(conflit: _payer)
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2.0)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Consumer3<ConflitMaterielState, ConflitUstensileState,
                  ConflitPayerState>(
                builder: (ctx, conflitMaterielState, conflitUstensileState,
                        conflitPayerState, _) =>
                    FlatButton(
                  child: const Text("Enregistrer"),
                  onPressed: !conflitMaterielState.canSave ||
                          !conflitUstensileState.canSave ||
                          !conflitPayerState.canSave
                      ? null
                      : () async {
                          if (conflitMaterielState.values.isNotEmpty) {
                            await fixMateriel(conflitMaterielState);
                          }
                          if (conflitUstensileState.values.isNotEmpty) {
                            await fixUstensile(conflitUstensileState);
                          }
                          if (conflitPayerState.values.isNotEmpty) {
                            await fixPayer(conflitPayerState);
                          }
                          if (choix.isNotEmpty) await fixSalle();
                          Provider.of<ConflitState>(context, listen: false)
                              .conflictByIdReservation[widget.idReservation]
                              .clear();
                          Navigator.of(context).pop(null);
                        },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future fixPayer(ConflitPayerState conflitPayerState) async {
    await ConflitState.fixPayer(conflitPayerState.values,idReservation);
    GlobalState().channel.sink.add("payer $idReservation");
  }

  Future fixMateriel(ConflitMaterielState conflitMaterielState) async {
    ConflitState.fixMateriel(conflitMaterielState.values).then((v) {
      if (v) {
        List<int> toRefresh = [];
        conflitMaterielState.values
            .forEach((int idMateriel, Map<int, int> value) {
          toRefresh.insertAll(0, value.keys);
        });

        toRefresh.toSet().toList().forEach((int idReservation) {
          GlobalState().channel.sink.add("louer $idReservation");
        });
        //To set to List delete duplicate entries
      }
    });
  }

  Future fixUstensile(ConflitUstensileState conflitUstensileState) async {
    ConflitState.fixUstensile(conflitUstensileState.values).then((v) {
      if (v) {
        List<int> toRefresh = [];
        conflitUstensileState.values
            .forEach((int idUstensile, Map<int, int> value) {
          toRefresh.insertAll(0, value.keys);
        });

        toRefresh.toSet().toList().forEach((int idReservation) {
          GlobalState().channel.sink.add("emprunter $idReservation");
        });
        //To set to List delete duplicate entries
      }
    });
  }

  Future fixSalle() async {
    List<Map<String, String>> data = [];
    List<int> listReservation = [];
    choix.forEach((int idSalle, Choice chx) {
      if (chx == Choice.change) {
        for (var val in _salle[idSalle]["old"]) {
          data.add({idSalle.toString(): val["idReservation"].toString()});
          listReservation.add(val["idReservation"]);
        }
        listReservation.add(_salle[idSalle]["new"]["idReservation"]);
      } else {
        data.add({
          idSalle.toString(): _salle[idSalle]["new"]["idReservation"].toString()
        });
        listReservation.add(_salle[idSalle]["new"]["idReservation"]);
      }
    });
    await ConflitState.fixSalle(data);
    listReservation.forEach((reser) {
      GlobalState().channel.sink.add("concerner $reser");
    });
  }
}
