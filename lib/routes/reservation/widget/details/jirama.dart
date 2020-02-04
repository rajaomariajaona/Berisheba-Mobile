import 'package:berisheba/tools/formatters/CaseInputFormatter.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReservationJirama extends StatelessWidget {
  final int _idReservation;
  const ReservationJirama(this._idReservation, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = {
      "consommation": 20,
      "appareil": {"nomAppareil": "Ordinateur", "puissance": 2.5},
      "duree": 1200
    };
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
                collapsed: Container(
                  child: Text("Consommation: ${data["consommation"]} kw"),
                ),
                expanded: Container(
                  height: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              _JiramaItem(data: data),
                              Divider(),
                              _JiramaItem(data: data),
                              Divider(),
                              _JiramaItem(data: data),
                              Divider()
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _JiramaDialog(),
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
    @required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        "${data["appareil"]["nomAppareil"]} ",
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Puissance: ${data["appareil"]["puissance"]} w"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("duree: ${data["duree"]} s"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum Puissance { watt, ampere }

class _JiramaDialog extends StatefulWidget {
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
                        textCapitalization: TextCapitalization.characters,
                        // validator: validators["nom"],
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter(RegExp("[A-Za-z ]")),
                          LengthLimitingTextInputFormatter(50),
                          CapitalizeWordsInputFormatter()
                        ],
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Nom de l'appareil",
                        ),
                        onSaved: (val){
                          _nom = val;
                        },
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
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
                      if(_formState.currentState.validate()){
                        _formState.currentState.save();
                        print({
                          "nomAppareil": _nom,
                          "puissance": _puissanceValue,
                          "puissanceType": _puissance == Puissance.watt ? "w" : "a",
                          "duree": _duree
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
