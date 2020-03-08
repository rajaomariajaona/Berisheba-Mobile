import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ConflitPayerState extends ChangeNotifier {
  bool _canSave = true;
  set canSave(bool val) {
    if (_canSave != val) {
      _canSave = val;
      notifyListeners();
    }
  }

  bool get canSave => _canSave;
  Map<String, double> _values = {};
  Map<String, double> get values => _values;
  set values(value) {
    _values = value;
    notifyListeners();
  }
}

class ConflitPayer extends StatefulWidget {
  const ConflitPayer({@required this.conflit});
  final Map<String, dynamic> conflit;
  @override
  _ConflitPayerState createState() => _ConflitPayerState();
}

class _ConflitPayerState extends State<ConflitPayer> {
  Map<String, dynamic> _conflit;
  int val;
  ConflitPayerState _conflitPayerState;

  bool canSave;
  List<TextEditingController> controllers = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _conflitPayerState.values = {
        "avance": 0.0,
        "remise": 0.0,
      };
      for (var payer in _conflit["payers"] as List<dynamic>) {
        String typePaiement = payer["paiementTypePaiement"]["typePaiement"];
        double sommePayee = payer["sommePayee"].toDouble();
        _conflitPayerState.values[typePaiement] = sommePayee;
      }
    });
    _conflit = widget.conflit;
    val = 10;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _conflitPayerState = Provider.of<ConflitPayerState>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    canSave = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double total = 0;
      _conflitPayerState.values.keys
          .forEach((key) => total += _conflitPayerState.values[key]);
      _conflitPayerState.canSave =
          _conflitPayerState.values.keys.contains("reste")
              ? total == _conflit["prixTotal"].toDouble()
              : total <= _conflit["prixTotal"].toDouble();
    });
    List<Widget> _paiement = [];
    for (var typePaiement in _conflitPayerState.values.keys) {
      _paiement.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("$typePaiement".toUpperCase()),
          Row(
            children: <Widget>[
              Text("${_conflitPayerState.values[typePaiement]} ar"),
              FlatButton(
                child: Text("ajuster"),
                onPressed: () async {
                  if (typePaiement == "reste") {
                    _conflitPayerState.values["reste"] = _conflit["prixTotal"] -
                        (_conflitPayerState.values["avance"] +
                            _conflitPayerState.values["remise"]);
                    if (_conflitPayerState.values["reste"] < 0)
                      _conflitPayerState.values["reste"] = 0;
                    setState(() {});
                  } else {
                    final TextEditingController controller =
                        TextEditingController();
                    controller.text = _conflitPayerState.values[typePaiement]
                        .toString()
                        .replaceFirst(".0", "");
                    var value = await showDialog(
                        context: context,
                        child: AlertDialog(
                          content: Container(
                            child: TextFormField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(RegExp("[0-9]+"))
                              ],
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: "Somme payee",
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () async {
                                  Navigator.of(context).pop(controller.text);
                                }),
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                }),
                          ],
                        ));
                    if (value != null) {
                      print(controller.text);
                      setState(() {
                        _conflitPayerState.values[typePaiement] =
                            double.parse(controller.text);
                      });
                    }
                  }
                },
              )
            ],
          ),
        ],
      ));
    }
    return SingleChildScrollView(
      child: Card(
        margin: EdgeInsets.all(15),
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Paiement : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(),
              ..._paiement,
              Divider(),
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          "Prix actuelle: ${_conflitPayerState.values.values.isNotEmpty ? _conflitPayerState.values.values.reduce((a, b) => a + b) : ""}"),
                      Text("Prix Total : ${_conflit["prixTotal"]}")
                    ],
                  ),
                  if (!_conflitPayerState.canSave)
                    Icon(
                      Icons.warning,
                      color: Colors.yellow,
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
