import 'package:berisheba/tools/widgets/number_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConflitUstensileState extends ChangeNotifier {
  bool _canSave = true;
  set canSave(bool val) {
    if (_canSave != val) {
      _canSave = val;
      notifyListeners();
    }
  }

  bool get canSave => _canSave;
  Map<int, Map<int, int>> values = {};
}

class ConflitUstensile extends StatefulWidget {
  const ConflitUstensile({@required this.conflit});
  final Map<int, dynamic> conflit;
  @override
  _ConflitUstensileState createState() => _ConflitUstensileState();
}

class _ConflitUstensileState extends State<ConflitUstensile> {
  Map<int, dynamic> _conflit;
  Map<int, Map<int, int>> nbEmprunte;
  int val;
  ConflitUstensileState _conflitUstensileState;
  bool canSave;
  @override
  void initState() {
    _conflit = widget.conflit;
    val = 10;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _conflitUstensileState = Provider.of<ConflitUstensileState>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    canSave = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _conflitUstensileState.canSave = canSave;
    });
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          for (int idUstensile in _conflit.keys) ...[
            conflictCard(_conflit[idUstensile]),
            SizedBox(
              height: 10,
            )
          ]
        ],
      ),
    );
  }

  Widget conflictCard(List<dynamic> details) {
    var detailsWidget = detailsGenerator(details);
    return Card(
      elevation: 3.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: detailsWidget,
      ),
    );
  }

  List<Widget> detailsGenerator(List details) {
    var widgets = Column(
      children: <Widget>[
        for (var detail in details) ...[
          container(detail, details),
          row(details, detail),
          Divider()
        ]
      ]..removeLast(),
    );
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Ustensile : ${details[0]["nomUstensile"]}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Max : ${details[0]["nbTotal"]}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      const Divider(
        thickness: 2,
      ),
      widgets
    ];
  }

  Row row(List details, detail) {
    canSave = canSave &&
        getTotal(details[0]["idUstensile"], detail["idReservations"]) <=
            details[0]["nbTotal"];
    return Row(
      children: <Widget>[
        Text(
            "Total: ${getTotal(details[0]["idUstensile"], detail["idReservations"])} "),
        getTotal(details[0]["idUstensile"], detail["idReservations"]) >
                details[0]["nbTotal"]
            ? Icon(
                Icons.warning,
                color: Colors.yellow,
                size: 20,
              )
            : Container()
      ],
    );
  }

  Container container(detail, List details) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          for (var i in Iterable.generate(detail["idReservations"].length))
            buildRow(detail, i, details[0]["nbTotal"], details[0]["idUstensile"])
        ],
      ),
    );
  }

  int getTotal(idUstensile, List listeReservation) {
    var total = 0;
    _conflitUstensileState.values[idUstensile].forEach((key, value) {
      if (listeReservation.contains(key)) total += value;
    });
    return total;
  }

  Row buildRow(detail, i, max, idUstensile) {
    if (!_conflitUstensileState.values.containsKey(idUstensile))
      _conflitUstensileState.values[idUstensile] = {};
    _conflitUstensileState.values[idUstensile].putIfAbsent(
        detail["idReservations"][i],
        () => detail["nbEmpruntes"][i] > max ? max : detail["nbEmpruntes"][i]);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("${detail["nomReservations"][i]}"),
          NumberSelector(
              max: max,
              increment: () {
                setState(() {
                  _conflitUstensileState.values[idUstensile]
                      [detail["idReservations"][i]]++;
                });
              },
              setValue: (int val) {
                setState(() {
                  _conflitUstensileState.values[idUstensile]
                      [detail["idReservations"][i]] = val;
                });
              },
              value: _conflitUstensileState.values[idUstensile]
                  [detail["idReservations"][i]])
        ]);
  }
}
