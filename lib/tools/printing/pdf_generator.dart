import 'dart:io';
import 'dart:ui';

import 'package:image/image.dart' as images;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfGenerator {
  Document pdf;
  PdfGenerator() {
    pdf = Document();
  }
  Future savePdf() async {
    var data = await rootBundle.load("assets/logo.png");
    var img = images.decodeImage(data.buffer.asUint8List());
    pdf.addPage(Page(build: (context) {
      return Column(children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "Berisheba",
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                      Text("PK 21 RN7"),
                      Text("Antananarivo 101")
                    ]),
              ),
              Spacer(flex: 1),
              Flexible(
                  flex: 2,
                  child: Image(PdfImage(
                    pdf.document,
                    image: img.data.buffer.asUint8List(),
                    width: img.width,
                    height: img.height,
                  )))
            ]),
      ]);
    }));
    final File fichier =
        File("${(await getExternalStorageDirectory()).path}/test2.pdf");
    await fichier.writeAsBytes(pdf.save());
  }
}
