import 'package:berisheba/tools/widgets/number_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConflitMaterielState extends ChangeNotifier{
  bool _canSave = true;
  set canSave(bool val){
    if(_canSave != val){
      _canSave = val;
      notifyListeners();
    }
  }
  bool get canSave => _canSave;
  Map<int, Map<int, int>> values = {};
}

class ConflitMateriel extends StatefulWidget {
  const ConflitMateriel({@required this.conflit});
  final Map<int, dynamic> conflit;
  @override
  _ConflitMaterielState createState() => _ConflitMaterielState();
}

class _ConflitMaterielState extends State<ConflitMateriel> {
  Map<int, dynamic> _conflit;
  Map<int, Map<int, int>> nbLouee;
  int val;
  ConflitMaterielState _conflitMaterielState;
  bool canSave;
  @override
  void initState() {
    _conflit = widget.conflit;
    val = 10;
    super.initState();
  }
  @override
  void didChangeDependencies() {
    _conflitMaterielState = Provider.of<ConflitMaterielState>(context);
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    canSave = true;
    WidgetsBinding.instance.addPostFrameCallback((_){
      _conflitMaterielState.canSave = canSave;
    });
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          for (int idMateriel in _conflit.keys) ...[
            conflictCard(_conflit[idMateriel]),
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
              "Materiel : ${details[0]["nomMateriel"]}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Max : ${details[0]["nbStock"]}",
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
    canSave = canSave && getTotal(details[0]["idMateriel"], detail["idReservations"]) <= details[0]["nbStock"];
    return Row(
          children: <Widget>[
            Text(
                "Total: ${getTotal(details[0]["idMateriel"], detail["idReservations"])} "),
  getTotal(details[0]["idMateriel"], detail["idReservations"]) > details[0]["nbStock"]
            ? Icon(Icons.warning,color: Colors.yellow, size: 20,): Container()
          ],
        );
  }

  Container container(detail, List details) {
    return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              for (var i
                  in Iterable.generate(detail["idReservations"].length))
                buildRow(detail, i, details[0]["nbStock"],
                    details[0]["idMateriel"])
            ],
          ),
        );
  }

  int getTotal(idMateriel, List listeReservation) {
    var total = 0;
    _conflitMaterielState.values[idMateriel].forEach((key, value) {
      if (listeReservation.contains(key)) total += value;
    });
    return total;
  }

  Row buildRow(detail, i, max, idMateriel) {
    if (!_conflitMaterielState.values.containsKey(idMateriel)) _conflitMaterielState.values[idMateriel] = {};
    _conflitMaterielState.values[idMateriel].putIfAbsent(detail["idReservations"][i],
        () => detail["nbLouees"][i] > max ? max : detail["nbLouees"][i]);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("${detail["nomReservations"][i]}"),
          NumberSelector(
              max: max,
              increment: () {
                setState(() {
                  _conflitMaterielState.values[idMateriel][detail["idReservations"][i]]++;
                });
              },
              decrement: () {
                setState(() {
                  _conflitMaterielState.values[idMateriel][detail["idReservations"][i]]--;
                });
              },
              value: _conflitMaterielState.values[idMateriel][detail["idReservations"][i]])
        ]);
  }
}
