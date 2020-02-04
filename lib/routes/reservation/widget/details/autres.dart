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
    (autresState.autresByIdReservation[_idReservation] ?? {})
        .forEach((Autre autre, double prixAutre) {
      _listAutres.add(_AutresItem(
        autre: autre,
        prixAutre: prixAutre,
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
                      "Autres",
                      style: Theme.of(context).textTheme.body2,
                    )),
                collapsed: autresState.isLoading == _idReservation ? const Loading() : Container(
                  child:
                      Text("Prix: ${autresState.statsByIdReservation[_idReservation]["somme"] ?? 0}"),
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
    @required this.autre,
    @required this.prixAutre,
    @required this.idReservation,
  }) : super(key: key);
  final int idReservation;
  final Autre autre;
  final double prixAutre;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        "${autre.motif} ",
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text("prixAutre: $prixAutre",overflow: TextOverflow.ellipsis,),
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
            AutresState.removeData(idAutre: autre.id, idReservation: idReservation);
          } else if (value == "edit") {
            showDialog(
                builder: (BuildContext context) {
                  return _AutresDialog(
                    autre: autre,
                    prixAutre: prixAutre,
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

class _AutresDialog extends StatefulWidget {
  _AutresDialog({this.autre, this.prixAutre, @required this.idReservation}) {
    modifier = autre != null && prixAutre != null;
  }
  final int idReservation;
  final Autre autre;
  final double prixAutre;
  bool modifier;
  @override
  State<StatefulWidget> createState() => _AutresDialogState();
}

class _AutresDialogState extends State<_AutresDialog> {
  String _motif;
  int _prixAutre;
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
                            widget.modifier ? "${widget.autre.motif}" : "",
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter(RegExp("[A-Za-z ]")),
                          LengthLimitingTextInputFormatter(50),
                          CapitalizeWordsInputFormatter()
                        ],
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Motif",
                        ),
                        onSaved: (val) {
                          _motif = val;
                        },
                      ),
                      TextFormField(
                        initialValue: widget.modifier ? "${widget.prixAutre}" : "",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter(RegExp("[0-9]+")),
                        ],
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Prix",
                        ),
                        onSaved: (val) {
                          _prixAutre = int.parse(val);
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
                                "idAutre": widget.autre.id.toString(),
                                "motif": _motif,
                                "prixAutre": _prixAutre.toString()
                              }, idReservation: widget.idReservation)
                            : AutresState.saveData({
                                "motif": _motif,
                                "prixAutre": _prixAutre.toString()
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
