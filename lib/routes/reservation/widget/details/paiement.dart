import 'package:berisheba/routes/reservation/states/payer_state.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ReservationPayer extends StatelessWidget {
  final int _idReservation;
  final bool readOnly;
  const ReservationPayer(this._idReservation, {this.readOnly, Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final PayerState payerState = Provider.of<PayerState>(context);
    List<Widget> _listPayer = [];
    (payerState.payerByIdReservation[_idReservation] ?? [])
        .forEach((Payer payer) {
      _listPayer.add(_PayerItem(
        readOnly: readOnly,
        prixPayer: payer.sommePayee,
        payer: payer,
        idReservation: _idReservation,
      ));
      _listPayer.add(const Divider());
    });
    var stats = payerState.statsByIdReservation[_idReservation];
    return ExpandableNotifier(
        child: ScrollOnExpand(
      scrollOnExpand: false,
      scrollOnCollapse: true,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: ScrollOnExpand(
            scrollOnExpand: true,
            scrollOnCollapse: false,
            child: ExpandableNotifier(
              initialExpanded: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Payer",
                      style: Theme.of(context).textTheme.body2,
                    )),
                collapsed: payerState.isLoading == _idReservation
                    ? const Loading()
                    : Container(
                        child: (stats != null &&
                                stats["remise"] != null &&
                                stats["prixTotal"] != null &&
                                stats["prixPayee"] != null)
                            ? Text(
                                "Remise: ${stats["remise"]}\nSomme restante: ${stats["prixTotal"] - (stats["prixPayee"] + stats["remise"]) ?? ""}\nPrix Total: ${stats["prixTotal"] ?? ""}")
                            : Container(),
                      ),
                expanded: Container(
                  height:
                      (payerState.payerByIdReservation[_idReservation] ?? [])
                                  .length >
                              0
                          ? 250
                          : 50,
                  child: payerState.isLoading == _idReservation
                      ? const Loading()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _listPayer,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                if (readOnly)
                                  Container()
                                else
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            PayerDialog(
                                          idReservation: _idReservation,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class _PayerItem extends StatelessWidget {
  const _PayerItem(
      {Key key,
      @required this.payer,
      @required this.prixPayer,
      @required this.idReservation,
      @required this.readOnly})
      : super(key: key);
  final int idReservation;
  final bool readOnly;
  final Payer payer;
  final double prixPayer;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        "${payer.typePaiement} ",
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "prixPayer: $prixPayer",
        overflow: TextOverflow.ellipsis,
      ),
      trailing: readOnly
          ? null
          : PopupMenuButton(
              padding: EdgeInsets.all(0),
              itemBuilder: (BuildContext context) {
                return [
                  if (payer.typePaiement != 'reste')
                    PopupMenuItem(
                      child: Text("modifier"),
                      value: "edit",
                    ),
                  PopupMenuItem(
                    child: Text("supprimer"),
                    value: "delete",
                  )
                ];
              },
              onSelected: (dynamic value) {
                if (value == "delete") {
                  PayerState.removeData(
                      typePaiement: payer.typePaiement,
                      idReservation: idReservation);
                } else if (value == "edit") {
                  showDialog(
                      builder: (BuildContext context) {
                        return PayerDialog(
                          payer: payer,
                          idReservation: idReservation,
                        );
                      },
                      context: context);
                }
              },
            ),
    );
  }
}

class PayerDialog extends StatefulWidget {
  PayerDialog({this.payer, @required this.idReservation, Key key}): super(key:key);
  final int idReservation;
  final Payer payer;
  
  @override
  State<StatefulWidget> createState() => _PayerDialogState();
}

class _PayerDialogState extends State<PayerDialog> {
  bool modifier = false;
  double _sommePayee;
  String _typePaiement;
  final List<String> typePaiements = ["avance", "reste", "remise"];
  List<DropdownMenuItem> _dropdownMenuItems;

  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  @override
  void initState() {
    modifier = widget.payer != null;
    this._dropdownMenuItems = typePaiements.map((String type) {
      return DropdownMenuItem(
        child: Text("$type"),
        value: type,
      );
    }).toList();
    this._typePaiement = widget.payer?.typePaiement ?? typePaiements[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formState,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DropdownButton(
                          value: _typePaiement,
                          items: this._dropdownMenuItems,
                          onChanged: (dynamic val) {
                            setState(() {
                              _typePaiement = val;
                            });
                          }),
                      _typePaiement != "reste"
                          ? TextFormField(
                              initialValue: modifier
                                  ? "${widget.payer.sommePayee}"
                                  : "",
                              validator: (String val) {
                                if (val.trim().isEmpty) {
                                  return "Champ vide";
                                }
                                if (double.tryParse(val) == null && double.parse(val) == 0) {
                                  return "Valeur incorrecte";
                                }
                                if (_typePaiement.compareTo("avance") == 0) {
                                  double value = double.parse(val);
                                  PayerState _payerState =
                                      Provider.of<PayerState>(context,
                                          listen: false);
                                  var stats = _payerState.statsByIdReservation[
                                      widget.idReservation];
                                  var data = _payerState.payerByIdReservation[
                                      widget.idReservation];
                                  double avance = 0;
                                  if (!modifier) {
                                    data.forEach((Payer payer) {
                                      if (payer.typePaiement == "avance") {
                                        avance += payer.sommePayee;
                                      }
                                    });
                                  }
                                  var prixDu =
                                      stats["prixTotal"] - stats["remise"] - avance;
                                  if (value > prixDu) {
                                    return "Valeur trop grande";
                                  }
                                }
                                if (_typePaiement.compareTo("remise") == 0) {
                                  double value = double.parse(val);
                                  PayerState _payerState =
                                      Provider.of<PayerState>(context,
                                          listen: false);
                                  var stats = _payerState.statsByIdReservation[
                                      widget.idReservation];
                                  var data = _payerState.payerByIdReservation[
                                      widget.idReservation];
                                  double remise = 0;
                                  if (!modifier) {
                                    data.forEach((Payer payer) {
                                      if (payer.typePaiement == "remise") {
                                        remise += payer.sommePayee;
                                      }
                                    });
                                  }
                                  var prixDu = stats["prixTotal"];
                                  if ((value + remise) > (prixDu / 2)) {
                                    return remise == 0 ? "Valeur superieur a 50%": "$remise + valeur superieur a 50%";
                                  }
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: "Somme payee",
                              ),
                              onSaved: (val) {
                                _sommePayee = double.parse(val);
                              },
                            )
                          : Container(),
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
                    icon: Icon(
                      Icons.close,
                    ),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      if (_formState.currentState.validate()) {
                        _formState.currentState.save();
                        modifier
                            ? PayerState.modifyData(
                                {"sommePayee": _sommePayee.toString()},
                                idReservation: widget.idReservation,
                                typePaiement: widget.payer.typePaiement)
                            : _typePaiement != 'reste'
                                ? PayerState.saveData({
                                    "typePaiement": _typePaiement,
                                    "sommePayee": _sommePayee.toString()
                                  }, idReservation: widget.idReservation)
                                : PayerState.saveData(
                                    {"typePaiement": _typePaiement},
                                    idReservation: widget.idReservation);
                        Navigator.of(context).pop(null);
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
