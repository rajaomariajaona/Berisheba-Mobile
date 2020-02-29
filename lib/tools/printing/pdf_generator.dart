import 'dart:io';
import 'dart:ui';

import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/file_saver.dart';
import 'package:berisheba/tools/others/handle_dio_error.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as images;
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';

class PdfGenerator {
  bool canShare = false;
  Document pdf;
  PdfGenerator() {
    pdf = Document();
  }
  Future<String> saveFacture(int idReservation) async {
    Map<String, dynamic> donnee;
    Dio _dio = await RestRequest().getDioInstance();
    try {
      donnee = (await _dio.get("/facture/$idReservation")).data;
    } catch (error) {
      HandleDioError(error);
    }
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
                      Text("Ambatofotsy-Gara"),
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
                  "Client: ${donnee["nomClient"]} ${donnee["prenomClient"]}\nTelephone: ${donnee["numTelClient"]}\nAdresse: ${donnee["adresseClient"]}"),
            ]),
        Container(padding: EdgeInsets.all(25)),
        Table.fromTextArray(context: context, data: <List<String>>[
          <String>["Description", "Prix"],
          <String>[
            "Sejour: (nombre de jours: ${donnee["nbJours"]}, nombre de personne en moyenne: ${donnee["nbPersonne"]})",
            "${donnee["prixTotalChambre"]} ar"
          ],
          for (var autre in (donnee["autresMotifs"] ?? []))
            <String>[autre.keys.toList()[0], "${autre.values.toList()[0]} ar"],
          if (donnee["appareilListe"] != null)
            <String>[
              "Jirama : ${donnee["appareilListe"].join(", ")}",
              "${donnee["prixJirama"]} ar"
            ],
        ]),
        Container(padding: EdgeInsets.all(5)),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (donnee["avance"] != null && donnee["avance"] != 0)
                  Text("Avance : ${donnee["avance"]} ar"),
                if (donnee["remise"] != null && donnee["remise"] != 0)
                  Text("Remise : ${donnee["remise"]} ar"),
                Text("Prix total : ${donnee["prixTotal"]} ar"),
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
    PermissionHandler permissionHandler = PermissionHandler();
    await permissionHandler
        .checkPermissionStatus(PermissionGroup.storage)
        .then((permissionStatus) async {
      if (permissionStatus != PermissionStatus.granted) {
        await permissionHandler.requestPermissions([PermissionGroup.storage]);
      } else {
        canShare = true;
      }
    });
    List<StorageInfo> storageInfos = await PathProviderEx.getStorageInfo();
    var path;
    if (storageInfos.length > 1) {
      path = storageInfos[1].rootDir;
    } else if (storageInfos.length > 0) {
      path = storageInfos[0].rootDir;
    } else {
      path = (await getExternalStorageDirectory()).path;
    }
    var dir = Directory("$path/berisheba");
    dir.exists().then((isExist) async {
      if (!isExist) {
        await dir.create();
      }
    });
    final File fichier = File("$path/berisheba/facture.pdf");
    await fichier.writeAsBytes(pdf.save());
    try {
      await saveFile("application/pdf", "facture.pdf", "${pdf.save()}");
    } catch (error) {
      print(error.toString());
    }
    return "$path/berisheba/facture.pdf";
  }
}
