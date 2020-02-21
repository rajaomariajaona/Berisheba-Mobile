import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class StatistiquePortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Lol();
  }
}

class Lol extends StatefulWidget {
  const Lol({
    Key key,
  }) : super(key: key);

  @override
  _LolState createState() => _LolState();
}

class _LolState extends State<Lol> {
  String path;
  @override
  Widget build(BuildContext context) {
    
    return Column(children: <Widget>[
      Flexible(
              child: PdfViewer(
          filePath: path,
        ),
      ),
      IconButton(icon: Icon(Icons.refresh), onPressed: () async {
        path = "${(await getExternalStorageDirectory()).path}/test2.pdf";
        setState((){}); 
      })
    
    ]);
  }
}
