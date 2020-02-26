import 'dart:io';
import 'dart:math';
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
        Container(padding: EdgeInsets.all(15)),
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Client: ",
                style: TextStyle(fontSize: 25),
              ),
              Text(
                  "Client: Nom Client\nTelephone: 033 xx xxx xx\nAdresse: Mbola tsy hita an' xD"),
            ]),
        Container(padding: EdgeInsets.all(25)),
        Table.fromTextArray(context: context, data: <List<String>>[
          <String>["Description", "Prix"],
          for (var i in Iterable.generate(10))
            <String>["Description $i", "${Random().nextInt(100000)}"],
        ]),
        Container(padding: EdgeInsets.all(5)),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("Prix total : 12341234 ar"),
                Text("Remise : 10234 ar"),
                Text("avance: 12414123 ar"),
                Text("Reste: 123412141 ar")
              ])
        ]),
        Container(padding: EdgeInsets.all(25)),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  "Si vous avez des questions concernant ce facture,\ncontactez-nous: 034 11 641 54",
                  )
            ])
      ]);
    }));
    final File fichier =
        File("${(await getExternalStorageDirectory()).path}/test.pdf");
    await fichier.writeAsBytes(pdf.save());
  }
}
