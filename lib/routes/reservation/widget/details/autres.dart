import 'package:berisheba/tools/formatters/CaseInputFormatter.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:berisheba/routes/reservation/states/autres_state.dart';
import 'package:provider/provider.dart';

class ReservationAutres extends StatelessWidget {
  final int _idReservation;
  const ReservationAutres(this._idReservation, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final AutresState autresState = Provider.of<AutresState>(context);
    List<Widget> _listAutres = [];
    (autresState.autresByIdReservation[_idReservation])
        .forEach((Appareil appareil, int duree) {
      _listAutres.add(_AutresItem(
        appareil: appareil,
        duree: duree,
        idReservation: _idReservation,
      ));
      _listAutres.add(const Divider());
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
                    child: Text(
                      "JIRAMA",
                      style: Theme.of(context).textTheme.body2,
                    )),
                collapsed: autresState.isLoading == _idReservation ? const Loading() : Container(
                  child:
                      Text("Consommation: ${autresState.statsByIdReservation[_idReservation]["consommation"] ?? 0} kw"),
                ),
                expanded: Container(
                  height: autresState.autresByIdReservation[_idReservation].length > 0 ? 250: 50,
                  child: autresState.isLoading == _idReservation ? const Loading() : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: _listAutres,
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
                                    _AutresDialog(
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

class _AutresItem extends StatelessWidget {
  const _AutresItem({
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
                  child: Text("Puissance: ${appareil.puissance} w", overflow: TextOverflow.ellipsis),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text("duree: $duree s",overflow: TextOverflow.ellipsis,),
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
            AutresState.removeData(idAppareil: appareil.id, idReservation: idReservation);
          } else if (value == "edit") {
            showDialog(
                builder: (BuildContext context) {
                  return _AutresDialog(
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

class _AutresDialog extends StatefulWidget {
  _AutresDialog({this.appareil, this.duree, @required this.idReservation}) {
    modifier = appareil != null && duree != null;
  }
  final int idReservation;
  final Appareil appareil;
  final int duree;
  bool modifier;
  @override
  State<StatefulWidget> createState() => _AutresDialogState();
}

class _AutresDialogState extends State<_AutresDialog> {
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
                        textCapitalization: TextCapitalization.characters,
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
                            ? AutresState.modifyData({
                                "idAppareil": widget.appareil.id.toString(),
                                "nomAppareil": _nom,
                                "puissance": _puissanceValue.toString(),
                                "puissanceType":
                                    _puissance == Puissance.watt ? "w" : "a",
                                "duree": _duree.toString()
                              }, idReservation: widget.idReservation)
                            : AutresState.saveData({
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
