import 'package:berisheba/main.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/connected_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:imei_plugin/imei_plugin.dart';

class AuthorizationState extends ChangeNotifier {
  Map<String, dynamic> _details = {};
  Map<String, dynamic> get details => _details;
  bool _isAuthorized = true;
  set isAuthorized(bool val) {
    if (_isAuthorized != val) {
      _isAuthorized = val;
      if (!_isAuthorized && ((MyApp.notAuthorized != null) ? !MyApp.notAuthorized.isCurrent : true)) {
        GlobalState().navigatorState.currentState.pushNamed("not-authorized");
      }
      notifyListeners();
    }
  }

  static Future saveData(Map<String, dynamic> data) async {
    var deviceid = await ImeiPlugin.getId();
    await Dio(BaseOptions(
      baseUrl: Config.baseURI,
      connectTimeout: 5000,
      receiveTimeout: 3000,
      contentType: Headers.formUrlEncodedContentType,
    )).post("/device", data: {
      "deviceid": deviceid,
      ...data
    });
  }

  Future fetchData() async {
    var deviceid = await ImeiPlugin.getId();
    try {
      await Dio(BaseOptions(
        baseUrl: Config.baseURI,
        connectTimeout: 5000,
        receiveTimeout: 3000,
        contentType: Headers.formUrlEncodedContentType,
      )).get("/device/$deviceid").then((response) async {
        _details = response.data["data"];
        if (_details["authorized"] == true) this.isAuthorized = true;
      });
    } catch (error) {
      if (error is DioError &&
          error.type == DioErrorType.RESPONSE &&
          error?.response?.statusCode == 404) {
        _details = {
          "deviceid": "$deviceid",
          "authorized": "neant",
          "utilisateur": null,
          "email": null,
          "information": "",
          "description": null
        };
      } else {
        ConnectedState().setIsConnected(false);
      }
    }
    notifyListeners();
  }

  bool get isAuthorized => _isAuthorized;
  static Future checkAuthorizationAndInternet() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    var info = [androidInfo.device, androidInfo.brand, androidInfo.model];
    var deviceid = await ImeiPlugin.getId();
    try {
      await Dio(BaseOptions(
        baseUrl: Config.baseURI,
        connectTimeout: 5000,
        receiveTimeout: 3000,
        contentType: Headers.formUrlEncodedContentType,
      )).post("/device", data: {
        "deviceid": deviceid,
        "information": info.join(", ")
      }).then((response) async {});
    } catch (error) {
      if (error is DioError &&
          error.type == DioErrorType.RESPONSE &&
          error?.response?.statusCode == 401) {
        AuthorizationState().isAuthorized = false;
      } else {
        ConnectedState().setIsConnected(false);
      }
    }
  }

  static final AuthorizationState _singleton = AuthorizationState._internal();

  factory AuthorizationState() {
    return _singleton;
  }

  AuthorizationState._internal();
}
