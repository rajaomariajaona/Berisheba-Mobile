import 'package:berisheba/routes/ustensile/ustensile_state.dart';
import 'package:berisheba/routes/ustensile/widgets/ustensile_formulaire.dart';
import 'package:berisheba/routes/reservation/widget/reservation_details.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/tools/widgets/confirm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Actions { supprimer, modifier }

class UstensileItem extends StatefulWidget {
  final int _idUstensile;

  const UstensileItem(
    this._idUstensile, {
    Key key,
  }) : super(key: key);

  @override
  State createState() => _UstensileItemState();
}

class _UstensileItemState extends State<UstensileItem> {
  @override
  Widget build(BuildContext context) {
    final UstensileState ustensileState = Provider.of<UstensileState>(context);
    Map<String, dynamic> _ustensile =
        ustensileState.listUstensileByIdUstensile[widget._idUstensile];
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        selected: ustensileState.isSelected(widget._idUstensile),
        leading: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          color: Config.primaryBlue,
                          style: BorderStyle.solid,
                          width: 1))),
              padding: EdgeInsets.symmetric(horizontal: 17, vertical: 3),
              child: Icon(
                Icons.dashboard,
                size: 30,
              ),
            )
          ],
        ),
        contentPadding: EdgeInsets.fromLTRB(0, 5, 10, 5),
        title: Text(
          "${_ustensile["nomUstensile"]}",
          maxLines: 3,
          overflow: TextOverflow.clip,
          style: TextStyle(fontSize: 16),
        ),
        subtitle: Text("Nombre total: ${_ustensile["nbStock"]}"),
        onLongPress: () {
          ustensileState.isDeletingUstensile = true;
          setState(() {
            ustensileState.addSelected(_ustensile["idUstensile"]);
          });
        },
        trailing: ustensileState.isDeletingUstensile
            ? Checkbox(
                value: ustensileState.isSelected(_ustensile["idUstensile"]),
                onChanged: (val) {
                  setState(() {
                    if (val)
                      ustensileState.addSelected(_ustensile["idUstensile"]);
                    else
                      ustensileState.deleteSelected(_ustensile["idUstensile"]);
                  });
                },
              )
            : PopupMenuButton(
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    child: Text("modifier"),
                    value: Actions.modifier,
                  ),
                  PopupMenuItem(
                      child: Text("supprimer"), value: Actions.supprimer),
                ],
                onSelected: (Actions action) async {
                  switch (action) {
                    case Actions.supprimer:
                      await Confirm.showDeleteConfirm(context: context)
                          .then((bool isOk) {
                        if (isOk) {
                          UstensileState.removeData(_ustensile["idUstensile"]);
                        }
                      });
                      break;
                    case Actions.modifier:
                      var t =
                          await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UstensileFormulaire(
                          ustensile: _ustensile,
                        ),
                      ));
                      break;
                    default:
                  }
                },
              ),
      ),
    );
  }
}
