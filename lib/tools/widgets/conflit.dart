import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/widgets/conflit/conflit_materiel.dart';
import 'package:berisheba/tools/widgets/conflit/conflit_salle.dart';
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
      child: ChangeNotifierProvider(
        create: (_) => ConflitMaterielState(),
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
                  _salle != null
                      ? ConflitSalle(
                          idReservation: idReservation,
                          choix: choix,
                          conflit: _salle,
                          callback: (int idSalle, Choice val) {
                            setState(() {
                              choix[idSalle] = val;
                            });
                          },
                        )
                      : Container(),
                  _materiel != null
                      ? ConflitMateriel(conflit: _materiel)
                      : Container(),
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
              Consumer<ConflitMaterielState>(
                builder: (ctx, conflitMaterielState, _) => FlatButton(
                  child: const Text("Enregistrer"),
                  onPressed: !conflitMaterielState.canSave
                      ? null
                      : () async {
                          if (conflitMaterielState.values.isNotEmpty) {
                            await fixMateriel(conflitMaterielState);
                          }
                          if (choix.isNotEmpty) await fixSalle();
                          Provider.of<ConflitState>(context)
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
