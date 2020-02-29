import 'package:flutter/services.dart';

Future<String> saveFile(String mime, String name, String data) async {
  const platform =
      MethodChannel("com.msvcode.filesaver/save"); //unique channel identifier
  try {
    final result = await platform.invokeMethod("saveFile", {
      "mime": mime,
      "name": name,
      "data": data,
    }); //name in native code

    return result;
  } on PlatformException catch (_) {
    print(_.toString());
    return null;
  }
}
