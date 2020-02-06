import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/tools/formatters/CaseInputFormatter.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:berisheba/routes/reservation/states/jirama_state.dart';
import 'package:provider/provider.dart';

class ReservationJirama extends StatelessWidget {
  final int _idReservation;
  const ReservationJirama(this._idReservation, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final JiramaState jiramaState = Provider.of<JiramaState>(context);
    List<Widget> _listJirama = [];
    (jiramaState.jiramaByIdReservation[_idReservation])
        .forEach((Appareil appareil, int duree) {
      _listJirama.add(_JiramaItem(
        appareil: appareil,
        duree: duree,
        idReservation: _idReservation,
      ));
      _listJirama.add(const Divider());
    });
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
                tapHeaderToExpand: true,
                tapBodyToCollapse: false,
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Consumer<ReservationState>(
                      builder: (ctx, reservationState, _) => Text(
                        "JIRAMA (${reservationState.reservationsById[_idReservation]["prixKW"]} ar/kw)",
                        style: Theme.of(context).textTheme.body2,
                      ),
                    )),
                collapsed: jiramaState.isLoading == _idReservation
                    ? const Loading()
                    : Container(
                        child: Text(
                            "Consommation: ${jiramaState.statsByIdReservation[_idReservation]["consommation"] ?? 0} kw"),
                      ),
                expanded: Container(
                  height:
                      jiramaState.jiramaByIdReservation[_idReservation].length >
                              0
                          ? 250
                          : 50,
                  child: jiramaState.isLoading == _idReservation
                      ? const Loading()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _listJirama,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          _JiramaDialog(
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

class _JiramaItem extends StatelessWidget {
  const _JiramaItem({
    Key key,
    @required this.appareil,
    @required this.duree,
    @required this.idReservation,
  }) : super(key: key);
  final int idReservation;
  final Appareil appareil;
  final int duree;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        "${appareil.nom} ",
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text("Puissance: ${appareil.puissance} w",
                      overflow: TextOverflow.ellipsis),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "duree: $duree s",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton(
        padding: EdgeInsets.all(0),
        itemBuilder: (BuildContext context) {
          return [
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
            JiramaState.removeData(
                idAppareil: appareil.id, idReservation: idReservation);
          } else if (value == "edit") {
            showDialog(
                builder: (BuildContext context) {
                  return _JiramaDialog(
                    appareil: appareil,
                    duree: duree,
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

enum Puissance { watt, ampere }

class _JiramaDialog extends StatefulWidget {
  _JiramaDialog({this.appareil, this.duree, @required this.idReservation}) {
    modifier = appareil != null && duree != null;
  }
  final int idReservation;
  final Appareil appareil;
  final int duree;
  bool modifier;
  @override
  State<StatefulWidget> createState() => _JiramaDialogState();
}

class _JiramaDialogState extends State<_JiramaDialog> {
  Puissance _puissance = Puissance.watt;
  String _nom;
  double _puissanceValue;
  int _duree;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
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
                    children: <Widget>[
                      TextFormField(
                        initialValue:
                            widget.modifier ? "${widget.appareil.nom}" : "",
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter(RegExp("[A-Za-z ]")),
                          LengthLimitingTextInputFormatter(50),
                          CapitalizeWordsInputFormatter()
                        ],
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Nom de l'appareil",
                        ),
                        onSaved: (val) {
                          _nom = val;
                        },
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              initialValue: widget.modifier
                                  ? "${widget.appareil.puissance}"
                                  : "",
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: "Puissance",
                              ),
                              onSaved: (val) {
                                _puissanceValue = double.parse(val);
                              },
                            ),
                          ),
                          DropdownButton(
                            value: _puissance,
                            items: <DropdownMenuItem>[
                              DropdownMenuItem(
                                child: Text("Watt"),
                                value: Puissance.watt,
                              ),
                              DropdownMenuItem(
                                child: Text("Ampere"),
                                value: Puissance.ampere,
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _puissance = value;
                              });
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: widget.modifier ? "${widget.duree}" : "",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter(RegExp("[0-9]+")),
                        ],
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Duree",
                        ),
                        onSaved: (val) {
                          _duree = int.parse(val);
                        },
                      ),
                      //TODO: Switch to Time picker
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
                        widget.modifier
                            ? JiramaState.modifyData({
                                "idAppareil": widget.appareil.id.toString(),
                                "nomAppareil": _nom,
                                "puissance": _puissanceValue.toString(),
                                "puissanceType":
                                    _puissance == Puissance.watt ? "w" : "a",
                                "duree": _duree.toString()
                              }, idReservation: widget.idReservation)
                            : JiramaState.saveData({
                                "nomAppareil": _nom,
                                "puissance": _puissanceValue.toString(),
                                "puissanceType":
                                    _puissance == Puissance.watt ? "w" : "a",
                                "duree": _duree.toString()
                              }, idReservation: widget.idReservation);
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

class JiramaPriceDialog extends StatefulWidget {
  JiramaPriceDialog({@required this.idReservation, Key key}) : super(key: key);
  final int idReservation;
  @override
  _JiramaPriceDialogState createState() => _JiramaPriceDialogState();
}

class _JiramaPriceDialogState extends State<JiramaPriceDialog> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  double prixKW;
  @override
  Widget build(BuildContext context) {
    final JiramaState jiramaState = Provider.of<JiramaState>(context);
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
                  child: TextFormField(
                    initialValue:
                        "${Provider.of<ReservationState>(context, listen: false).reservationsById[widget.idReservation]["prixKW"] ?? ""}",
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter(RegExp("[0-9.]+")),
                      LengthLimitingTextInputFormatter(50),
                    ],
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Prix KW",
                    ),
                    onSaved: (val) {
                      prixKW = double.parse(val);
                    },
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
                        JiramaState.patchPrixKW({"prixKW": prixKW.toString()},
                            idReservation: widget.idReservation);
                        if(jiramaState.jiramaByIdReservation[widget.idReservation]
                                    .length >
                                0)
                            Navigator.of(context).pop(null);
                        else {
                          Navigator.of(context).pop(null);
                          showDialog(
                                builder: (BuildContext context) {
                                  return _JiramaDialog(idReservation: widget.idReservation);
                                },
                                context: context);
                        }
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
