import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/tools/formatters/case_input_formatter.dart';
import 'package:berisheba/tools/formatters/second_to_string_formatter.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:berisheba/routes/reservation/states/jirama_state.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:provider/provider.dart';

class ReservationJirama extends StatelessWidget {
  final int _idReservation;
  final bool readOnly;
  const ReservationJirama(this._idReservation, {this.readOnly, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final JiramaState jiramaState = Provider.of<JiramaState>(context);
    List<Widget> _listJirama = [];
    (jiramaState.jiramaByIdReservation[_idReservation])
        .forEach((Appareil appareil, int duree) {
      _listJirama.add(_JiramaItem(
        readOnly: readOnly,
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
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                            Text(
                                "Consommation: ${jiramaState.statsByIdReservation[_idReservation]["consommation"] ?? ""} kw"),
                            Text(
                                "Prix: ${jiramaState.statsByIdReservation[_idReservation]["prix"] ?? ""}"),
                          ]),
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
                                if (readOnly)
                                  Container()
                                else ...[
                                  RawMaterialButton(
                                      constraints: BoxConstraints(
                                          minWidth: 0, minHeight: 0),
                                      padding: EdgeInsets.all(3),
                                      child: Text(
                                        "Kw",
                                        style: TextStyle(
                                            color: Config.primaryBlue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () async {
                                        await showDialog(
                                            builder: (BuildContext context) {
                                              return JiramaPriceDialog(
                                                  idReservation:
                                                     _idReservation);
                                            },
                                            context: context);
                                      }),
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
                                  )
                                ],
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
  const _JiramaItem(
      {Key key,
      @required this.appareil,
      @required this.duree,
      @required this.idReservation,
      @required this.readOnly})
      : super(key: key);
  final bool readOnly;
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
                    "duree: ${SecondToStringFormatter.format(duree)}",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: readOnly
          ? null
          : PopupMenuButton(
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
  _JiramaDialog({this.appareil, this.duree, @required this.idReservation, Key key}): super(key: key);
  final int idReservation;
  final Appareil appareil;
  final int duree;

  @override
  State<StatefulWidget> createState() => _JiramaDialogState();
}

class _JiramaDialogState extends State<_JiramaDialog> {
  Puissance _puissance = Puissance.watt;
  String _nom;
  double _puissanceValue;
  Duration _duree;
  bool modifier = false;
  @override
  void initState() {
    modifier = (widget.appareil != null);
    if (modifier)
      _duree = Duration(seconds: widget.duree);
    else
      _duree = Duration(seconds: 0);
    super.initState();
  }

  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  Map<String, Function(String)> _validators = {
    "nom": (String value) {
      if (value.trim().isEmpty) {
        return "Champs vide";
      }
      return null;
    },
    "puissance": (String value) {
      if (value.trim().isEmpty) {
        return "Champs vide";
      }
      if (double.tryParse(value) == null) {
        return "Valeur incorrecte";
      }
      return null;
    }
  };
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
                        validator: _validators["nom"],
                        initialValue:
                            modifier ? "${widget.appareil.nom}" : "",
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
                              validator: _validators["puissance"],
                              initialValue: modifier
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
                      Picker(
                        adapter: NumberPickerAdapter(data: [
                          NumberPickerColumn(
                              initValue: _duree.inDays,
                              begin: 0,
                              end: 99,
                              onFormatValue: (int value) =>
                                  (value < 10) ? '0$value' : '$value'),
                          NumberPickerColumn(
                              initValue: _duree.inHours % 24,
                              begin: 0,
                              end: 23,
                              onFormatValue: (int value) =>
                                  (value < 10) ? '0$value' : '$value'),
                          NumberPickerColumn(
                              initValue: _duree.inMinutes % 60,
                              begin: 0,
                              end: 59,
                              onFormatValue: (int value) =>
                                  (value < 10) ? '0$value' : '$value'),
                        ]),
                        delimiter: [
                          PickerDelimiter(
                              column: 1,
                              child: Container(
                                width: 10.0,
                                alignment: Alignment.center,
                                child: const Text(
                                  ":",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                          PickerDelimiter(
                              column: 3,
                              child: Container(
                                width: 10.0,
                                alignment: Alignment.center,
                                child: const Text(
                                  ":",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                        ],
                        hideHeader: true,
                        title: const Text("Choisir"),
                        footer: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("Jours"),
                            Text("Heures"),
                            Text("Minutes")
                          ],
                        ),
                        onSelect: (Picker picker, int index, List value) {
                          Duration _selected = Duration(
                              days: value[0],
                              hours: value[1],
                              minutes: value[2]);
                          if ((_duree.inSeconds == 0 &&
                                  _selected.inSeconds != 0) ||
                              (_duree.inSeconds != 0 &&
                                  _selected.inSeconds == 0)) {
                            setState(() {
                              _duree = _selected;
                            });
                          } else {
                            _duree = _selected;
                          }
                        },
                      ).makePicker()
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
                    onPressed: _duree.inSeconds == 0
                        ? null
                        : () {
                            if (_formState.currentState.validate()) {
                              _formState.currentState.save();
                              modifier
                                  ? JiramaState.modifyData({
                                      "idAppareil":
                                          widget.appareil.id.toString(),
                                      "nomAppareil": _nom,
                                      "puissance": _puissanceValue.toString(),
                                      "puissanceType":
                                          _puissance == Puissance.watt
                                              ? "w"
                                              : "a",
                                      "duree": _duree.inSeconds.toString()
                                    }, idReservation: widget.idReservation)
                                  : JiramaState.saveData({
                                      "nomAppareil": _nom,
                                      "puissance": _puissanceValue.toString(),
                                      "puissanceType":
                                          _puissance == Puissance.watt
                                              ? "w"
                                              : "a",
                                      "duree": _duree.inSeconds.toString()
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
                        if (jiramaState
                                .jiramaByIdReservation[widget.idReservation]
                                .length >
                            0)
                          Navigator.of(context).pop(null);
                        else {
                          Navigator.of(context).pop(null);
                          showDialog(
                              builder: (BuildContext context) {
                                return _JiramaDialog(
                                    idReservation: widget.idReservation);
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
