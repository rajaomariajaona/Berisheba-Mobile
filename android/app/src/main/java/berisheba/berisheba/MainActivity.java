package berisheba.berisheba;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

import android.content.Intent;
import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;

import java.io.IOException;
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;

public class MainActivity extends FlutterActivity {
    private static final int WRITE_REQUEST_CODE = 77777; //unique request code
    Result _result;
    Byte[] _data;
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor(), "com.msvcode.filesaver/save")
            .setMethodCallHandler(
                    new MethodCallHandler() {
                      @Override
                      public void onMethodCall(MethodCall call, Result result){
                        if (call.method.equals("saveFile")){
                          //save result & data as class variable, so it can be accessed in other function
                          _result = result;
                          _data = call.argument("data");
                          createFile(call.argument("mime"), call.argument("name"));
                        } else {
                          result.notImplemented();
                        }
                      }
                    }
            );
  }

  // create text file
  private void createFile(String mime, String fileName) {
    // when you create document, you need to add Intent.ACTION_CREATE_DOCUMENT
    Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);

    // filter to only show openable items.
    intent.addCategory(Intent.CATEGORY_OPENABLE);

    // Create a file with the requested Mime type
    intent.setType(mime);
    intent.putExtra(Intent.EXTRA_TITLE, fileName);

    startActivityForResult(intent, WRITE_REQUEST_CODE);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    if (requestCode == WRITE_REQUEST_CODE) {
      switch (resultCode) {
        case Activity.RESULT_OK:
          if (data != null && data.getData() != null) {
            //now write the data
            writeInFile(data.getData()); //data.getData() is Uri
          }
          break;
        case Activity.RESULT_CANCELED:
          _result.error("CANCELED", "User cancelled", null);
          break;
      }
    }
  }

  private byte[] parseStringToByteArray(String raw){

        String[] splitted = raw.substring(1, raw.length()-1).split(", ");
        byte[] data = new byte[splitted.length];
        for(int i = 0; i < splitted.length; i++){
            data[i] = Byte.parseByte(splitted[i]);
        }
        return data;
    }

  private void writeInFile(Uri uri) {
    OutputStream outputStream;
    try {
      outputStream = getContentResolver().openOutputStream(uri);
      ByteArrayOutputStream bos = new ByteArrayOutputStream();
      bos.write(parseStringToByteArray(_data));
      bos.writeTo(outputStream);
      bos.close();
      _result.success("Success");
    } catch (IOException e) {
      _result.error("ERROR", "Unable to write", null);
    }
  }
}
