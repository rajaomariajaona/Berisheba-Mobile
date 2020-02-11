import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaterielItem extends StatefulWidget {
  final int _idMateriel;

  const MaterielItem(
    this._idMateriel, {
    Key key,
  }) : super(key: key);

  @override
  State createState() => _MaterielItemState();
}

class _MaterielItemState extends State<MaterielItem> {
  @override
  Widget build(BuildContext context) {
    final MaterielState materielState = Provider.of<MaterielState>(context);
    Map<String, dynamic> _materiel =
        materielState.listMaterielByIdMateriel[widget._idMateriel];
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        selected: materielState.isSelected(widget._idMateriel),
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
          "${_materiel["nomMateriel"]}",
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16),
        ),
        onLongPress: () {
          materielState.isDeletingMateriel = true;
          setState(() {
            materielState.addSelected(_materiel["idMateriel"]);
          });
        },
        trailing: materielState.isDeletingMateriel
            ? Checkbox(
                value: materielState.isSelected(_materiel["idMateriel"]),
                onChanged: (val) {
                  setState(() {
                    if (val)
                      materielState.addSelected(_materiel["idMateriel"]);
                    else
                      materielState.deleteSelected(_materiel["idMateriel"]);
                  });
                },
              )
            : null,
      ),
    );
  }
}
