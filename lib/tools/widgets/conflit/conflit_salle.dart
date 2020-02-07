import 'package:flutter/material.dart';

typedef ChoiceCallback = void Function(int idSalle, Choice chx);
enum Choice { keep, change }

class ConflitSalle extends StatefulWidget {
  final int idReservation;
  const ConflitSalle({@required this.idReservation, @required this.conflit, @required this.choix, @required this.callback});
  final ChoiceCallback callback;
  final Map<int, dynamic> conflit;
  final Map<int, Choice> choix;
  @override
  _ConflitSalleState createState() => _ConflitSalleState();
}

class _ConflitSalleState extends State<ConflitSalle> {
  int idReservation;
  Map<int, dynamic> _conflit;
  Map<int, Choice> choix;
  @override
  void initState() {
    idReservation = widget.idReservation;
    _conflit = widget.conflit;
    choix = widget.choix;
    super.initState();
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
            padding: const EdgeInsets.all(8.0),
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
                      widget.callback(details["new"]["idSalle"], val);
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
                        widget.callback(details["new"]["idSalle"], val);
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
