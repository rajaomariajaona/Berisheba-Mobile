import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestNative extends StatefulWidget {
  TestNative({Key key}) : super(key: key);

  @override
  _TestNativeState createState() => _TestNativeState();
}

class _TestNativeState extends State<TestNative> {
  static const platform = MethodChannel("test.channel");
  String _resultat = "LOLOXOXO";
  Future<void> getText() async{
      try{
        _resultat = await platform.invokeMethod("getHelloWorld");
      }catch(e){
        _resultat = "error";
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            child: Text(_resultat),
          ),
          RaisedButton(
            child: Text("Click me"),
            onPressed: (){
              setState((){
                _resultat = "LOLO";
              });
            },
          ),
          RaisedButton(
            child: Text("Click me 2"),
            onPressed: () async{
              await getText();
              setState(() {

              });
            },
          )
        ],
      ),
    );
  }
}