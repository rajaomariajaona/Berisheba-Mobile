import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Choice { keep, change }

class ConflitSalle extends StatefulWidget {
  final int idReservation;
  ConflitSalle({@required this.idReservation});
  @override
  _ConflitSalleState createState() => _ConflitSalleState();
}

class _ConflitSalleState extends State<ConflitSalle> {
  Map<int, dynamic> _conflit;
  int idReservation;
  Map<int, Choice> choix = {};
  @override
  void didChangeDependencies() {
    _conflit = Provider.of<ConflitState>(context, listen: false)
            .conflictByIdReservation[idReservation] ??
        ["salle"];
    if (_conflit != null) {
      idReservation = _conflit.values.elementAt(0)["new"]["idReservation"];
      for (int idSalle in _conflit.keys) choix[idSalle] = Choice.change;
    }else{
      Navigator.of(context).pop(null);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          for (int idSalle in _conflit.keys) ...[
            conflictCard(_conflit[idSalle]),
            SizedBox(
              height: 10,
            )
          ]
        ],
      ),
    );
  }

  Widget conflictCard(Map<String, dynamic> details) {
    return Card(
      elevation: 3.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              "Salle : ${details["new"]["nomSalle"]}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  dense: true,
                  title: Text("${details["new"]["nomReservation"]}"),
                  trailing: Radio(
                    value: Choice.change,
                    groupValue: choix[details["new"]["idSalle"]],
                    onChanged: (Choice val) {
                      setState(() {
                        choix[details["new"]["idSalle"]] = val;
                      });
                    },
                  ),
                ),
                const Divider(),
                for (dynamic val in details["old"]) ...[
                  ListTile(
                    dense: true,
                    title: Text("${val["nomReservation"]}"),
                    trailing: Radio(
                      value: Choice.keep,
                      groupValue: choix[details["new"]["idSalle"]],
                      onChanged: (Choice val) {
                        setState(() {
                          choix[details["new"]["idSalle"]] = val;
                        });
                      },
                    ),
                  ),
                  const Divider()
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
