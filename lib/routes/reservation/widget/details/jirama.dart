import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class ReservationJirama extends StatelessWidget {
  final int _idReservation;
  const ReservationJirama(this._idReservation, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = {"consommation": 20,"appareil": {"nomAppareil" : "Ordinateur", "puissance": 2.5},"duree": 1200};
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
                          )
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
      title: Text("${data["appareil"]["nomAppareil"]} ",overflow: TextOverflow.ellipsis,),
      subtitle: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: <Widget>[
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8.0),
                  child: Text("Puissance: ${data["appareil"]["puissance"] } w"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8.0),
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
