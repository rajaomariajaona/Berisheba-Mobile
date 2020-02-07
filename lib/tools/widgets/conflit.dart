
import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/states/global_state.dart';
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
      child: Scaffold(
        body: SafeArea(child: ConflitBody(idReservation: idReservation)),
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

class _ConflitBodyState extends State<ConflitBody>{
  Map<int, Choice> choix = {};
  Map<int, dynamic> _conflit;
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
      _conflit = temp["salle"];
      idReservation = _conflit.values.elementAt(0)["new"]["idReservation"];
      for (int idSalle in _conflit.keys) choix[idSalle] = Choice.change;
    }else{
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
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: Column(
                children: <Widget>[
                  ConflitSalle(
                    idReservation: idReservation,
                    choix: choix,
                    conflit: _conflit,
                    callback: (int idSalle, Choice val){
                      setState(() {
                        choix[idSalle] = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  List<Map<String, String>> data = [];
                  List<int> listReservation = [];
                  choix.forEach((int idSalle, Choice chx) {
                    if (chx == Choice.change) {
                      for (var val in _conflit[idSalle]["old"]) {
                        data.add({
                          idSalle.toString():
                              val["idReservation"].toString()
                        });
                        listReservation.add(val["idReservation"]);
                      }
                      listReservation
                          .add(_conflit[idSalle]["new"]["idReservation"]);
                    } else {
                      data.add({
                        idSalle.toString(): _conflit[idSalle]["new"]
                                ["idReservation"]
                            .toString()
                      });
                      listReservation.add(_conflit[idSalle]["new"]
                                ["idReservation"]);
                    }
                  });
                  await ConflitState.fixSalle(data);
                  listReservation.forEach((reser) {
                    GlobalState().channel.sink.add("concerner $reser");
                  });
                  Navigator.of(context).pop(null);
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
