import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/formatters/case_input_formatter.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:berisheba/routes/reservation/states/autres_state.dart';
import 'package:provider/provider.dart';

class ReservationAutres extends StatelessWidget {
  final int _idReservation;
  final bool readOnly;
  const ReservationAutres(this._idReservation, {this.readOnly, Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final AutresState autresState = Provider.of<AutresState>(context);
    List<Widget> _listAutres = [];
    (autresState.autresByIdReservation[_idReservation] ?? {})
        .forEach((Autre autre, double prixAutre) {
      _listAutres.add(_AutresItem(
        readOnly: readOnly,
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
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Autres",
                      style: Theme.of(context).textTheme.body2,
                    )),
                collapsed: autresState.isLoading == _idReservation
                    ? const Loading()
                    : Container(
                        child: Text(
                            "Prix Total: ${autresState.statsByIdReservation[_idReservation]["somme"] ?? 0}"),
                      ),
                expanded: Container(
                  height:
                      autresState.autresByIdReservation[_idReservation].length >
                              0
                          ? 250
                          : 50,
                  child: autresState.isLoading == _idReservation
                      ? const Loading()
                      : Column(
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
                                if (readOnly)
                                  Container()
                                else
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AutresDialog(
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
  const _AutresItem(
      {Key key,
      @required this.autre,
      @required this.prixAutre,
      @required this.idReservation,
      @required this.readOnly})
      : super(key: key);
  final bool readOnly;
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
      subtitle: Text(
        "prixAutre: $prixAutre",
        overflow: TextOverflow.ellipsis,
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
              onSelected: (dynamic value) async {
                if (value == "delete") {
                  await AutresState.removeData(
                      idAutre: autre.id, idReservation: idReservation);
                  await Provider.of<ConflitState>(context, listen: false)
                      .fetchConflit(idReservation)
                      .then((bool containConflit) async {
                    if (containConflit) {
                      await GlobalState()
                          .navigatorState
                          .currentState
                          .pushNamed("conflit/:$idReservation");
                    }
                  });
                } else if (value == "edit") {
                  showDialog(
                      builder: (BuildContext context) {
                        return AutresDialog(
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

class AutresDialog extends StatefulWidget {
  AutresDialog(
      {this.autre, this.prixAutre, @required this.idReservation, Key key})
      : super(key: key);
  final int idReservation;
  final Autre autre;
  final double prixAutre;

  @override
  State<StatefulWidget> createState() => _AutresDialogState();
}

class _AutresDialogState extends State<AutresDialog> {
  bool modifier = false;

  String _motif;
  int _prixAutre;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  @override
  void initState() {
    modifier = (widget.autre != null && widget.prixAutre != null);
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
                    children: <Widget>[
                      TextFormField(
                        initialValue: modifier ? "${widget.autre.motif}" : "",
                        textCapitalization: TextCapitalization.words,
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
                        initialValue: modifier ? "${widget.prixAutre}" : "",
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
                    onPressed: () async {
                      if (_formState.currentState.validate()) {
                        _formState.currentState.save();
                        modifier
                            ? await AutresState.modifyData({
                                "idAutre": widget.autre.id.toString(),
                                "motif": _motif,
                                "prixAutre": _prixAutre.toString()
                              }, idReservation: widget.idReservation)
                            : await AutresState.saveData({
                                "motif": _motif,
                                "prixAutre": _prixAutre.toString()
                              }, idReservation: widget.idReservation);
                        Provider.of<ConflitState>(context, listen: false)
                            .fetchConflit(widget.idReservation)
                            .then((bool containConflit) {
                          if (containConflit) {
                            Navigator.of(context)
                                .pushNamed("conflit/:${widget.idReservation}");
                          }
                        });
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
