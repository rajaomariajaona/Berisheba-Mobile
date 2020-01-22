import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaterielPortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MaterielState materielState = Provider.of<MaterielState>(context);
    return WillPopScope(
      onWillPop: () async {
        if (materielState.isSearching) {
          materielState.isSearching = false;
          return false;
        } else {
          return true;
        }
      },
      child: Column(children: <Widget>[
        ExpandableNotifier(
            child: ScrollOnExpand(
          scrollOnExpand: false,
          scrollOnCollapse: true,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  ScrollOnExpand(
                    scrollOnExpand: true,
                    scrollOnCollapse: false,
                    child: ExpandableNotifier(
                      initialExpanded: true,
                      child: ExpandablePanel(
                        tapHeaderToExpand: true,
                        tapBodyToCollapse: true,
                        theme: ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center),
                        header: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Dates et nombres de personne",
                              style: Theme.of(context).textTheme.body2,
                            )),
                        collapsed: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Nombre de jours : 3.5",
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Nombre en moyenne : 50",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        expanded: Container(
                          height: 200,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                for (var _ in Iterable.generate(50))
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        "loremIpsum",
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                      )),
                              ],
                            ),
                          ),
                        ),
                        builder: (_, collapsed, expanded) {
                          return Padding(
                            padding: EdgeInsets.all(10),
                            child: Expandable(
                              collapsed: collapsed,
                              expanded: expanded,
                              theme: ExpandableThemeData(crossFadePoint: 0),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ]),
    );
  }
}
