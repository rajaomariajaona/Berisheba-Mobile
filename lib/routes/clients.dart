import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';

class Clients extends StatefulWidget {
  @override
  State createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  String message = "Test";
  var imei;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ImeiPlugin.getImei().then((im) {
      setState(() {
        imei = im;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("$imei"),
    );
  }
}
