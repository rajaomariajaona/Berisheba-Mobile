import 'package:flutter/material.dart';

class ReservationItem extends StatefulWidget {
  ReservationItem(this._reservation, {Key key}) : super(key: key);
  final Map<String, dynamic> _reservation;
  @override
  _ReservationItemState createState() => _ReservationItemState();
}

class _ReservationItemState extends State<ReservationItem> {
  void _watch() {
    print(widget._reservation["idReservation"]);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.2,
      child: ListTile(
        trailing: Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget._reservation["couleur"] != null &&
                int.tryParse(widget._reservation["couleur"]) != null
                ? Color(int.parse(widget._reservation["couleur"]))
                : Colors.green,
          ),
        ),
        onTap: _watch,
        contentPadding: EdgeInsets.fromLTRB(25, 10, 10, 10),
        title: Row(
          children: <Widget>[
            Text(widget._reservation["nomReservation"]),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text("Client: "),
                  Text(
                      "${widget._reservation["nomClient"]} ${widget
                          ._reservation["prenomClient"]}"),
                ],
              ),
              Row(
                children: <Widget>[
                  const Text("Date Entree: "),
                  Text("${widget._reservation["DateEntree"]}"),
                ],
              ),
              Row(
                children: <Widget>[
                  const Text("Date Sortie: "),
                  Text("${widget._reservation["DateSortie"]}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
