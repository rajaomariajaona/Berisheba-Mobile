import 'package:flutter/material.dart';

class MaterielPortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlatButton(
        child: Text("asdf"),
        onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              maintainState: true,
              fullscreenDialog: false,
              builder: (ctx){
                WidgetsBinding.instance.addPostFrameCallback((callback){
                  showDialog(
                  context: ctx,
                  builder: (_ctx){
                    return Dialog(
                    child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.yellow,
                  ));
                  }
                );
                });
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Dialog(
                    child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.green,
                  )
                  ),
                );
              }
            )
          );
        },
      ),
    );
  }
}


