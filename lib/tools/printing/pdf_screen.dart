import 'dart:io';

import 'package:berisheba/tools/others/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';

class PDFScreen extends StatefulWidget {
  final String pathPDF;
  PDFScreen({this.pathPDF = ""});

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  bool canShare = false;
  String sharePath;
  File shareFile;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _permissionCheck().then((isOk) async {
        canShare = isOk;
        if (isOk) {
          var path = await _prepareStorage();
          sharePath = "$path/facture.pdf";
          shareFile = await File(widget.pathPDF).copy(sharePath);
        }
      });
      setState(() {});
    });
    super.initState();
  }

  Future<String> _prepareStorage() async {
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
    return path;
  }

  Future<bool> _permissionCheck() async {
    bool ok = false;
    PermissionHandler permissionHandler = PermissionHandler();
    await permissionHandler
        .checkPermissionStatus(PermissionGroup.storage)
        .then((permissionStatus) async {
      if (permissionStatus != PermissionStatus.granted) {
        await permissionHandler
            .requestPermissions([PermissionGroup.storage]).then(
                (Map<PermissionGroup, PermissionStatus> result) {
          if (result[PermissionGroup.storage] == PermissionStatus.granted)
            ok = true;
        });
      } else {
        ok = true;
      }
    });
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Facture"),
          actions: <Widget>[
            if (canShare) ...[
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  if (shareFile != null) {
                    try {
                      await saveFile("application/pdf", "facture.pdf",
                          "${await shareFile.readAsBytes()}");
                    } catch (error) {
                      print(error.toString());
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () async {
                  await FlutterShare.shareFile(
                    title: 'Facture',
                    text: 'Facture ',
                    filePath: sharePath,
                  );
                },
              ),
            ]
          ],
        ),
        path: widget.pathPDF);
  }
}
