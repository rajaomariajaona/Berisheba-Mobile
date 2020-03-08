import 'package:flutter/material.dart';
class Confirm{
  static Future<bool> showDeleteConfirm({@required BuildContext context}){
    return showDialog(
      context: context,
      builder: (ctx){
        return AlertDialog(
          title: Text("Voulez vous vraiment supprimer?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Oui"),
              onPressed: (){
                Navigator.of(ctx).pop(true);
              },
            ),
            FlatButton(
              child: Text("Non"),
              onPressed: (){
                Navigator.of(ctx).pop(false);
              },
            )
          ],
        );
      }
    ) ?? false;
  }
}