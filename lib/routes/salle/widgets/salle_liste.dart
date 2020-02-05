import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/routes/salle/widgets/salle_detail.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalleItem extends StatefulWidget {
  final int _idSalle;

  const SalleItem(
    this._idSalle, {
    Key key,
  }) : super(key: key);

  @override
  State createState() => _SalleItemState();
}

class _SalleItemState extends State<SalleItem> {
  @override
  Widget build(BuildContext context) {
    final SalleState salleState = Provider.of<SalleState>(context);
    Map<String, dynamic> _salle =
        salleState.listSalleByIdSalle["${widget._idSalle}"];
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        selected: salleState.isSelected(_salle["idSalle"]),
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
                Icons.contact_phone,
                size: 30,
              ),
            )
          ],
        ),
        contentPadding: EdgeInsets.fromLTRB(0, 5, 10, 5),
        title: Text(
          "${_salle["nomSalle"]} ${_salle["prenomSalle"]}",
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16),
        ),
        onTap: () {
          if (TabState.index == 1) {
            if (salleState.isDeletingSalle) {
              setState(() {
                if (salleState.isSelected(_salle["idSalle"]))
                  salleState.deleteSelected(_salle["idSalle"]);
                else
                  salleState.addSelected(_salle["idSalle"]);
              });
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SalleDetail(widget._idSalle);
              }));
            }
          }else{
            Navigator.of(context).pop(_salle["idSalle"]);
          }
        },
        onLongPress: () {
          salleState.isDeletingSalle = true;
          setState(() {
            salleState.addSelected(_salle["idSalle"]);
          });
        },
        trailing: salleState.isDeletingSalle
            ? Checkbox(
                value: salleState.isSelected(_salle["idSalle"]),
                onChanged: (val) {
                  setState(() {
                    if (val)
                      salleState.addSelected(_salle["idSalle"]);
                    else
                      salleState.deleteSelected(_salle["idSalle"]);
                  });
                },
              )
            : null,
      ),
    );
  }
}
