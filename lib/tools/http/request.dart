import 'dart:convert';

import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO: Test connection coupee et Test token refresh
class RestRequest {
  static final BaseOptions _options = BaseOptions(
    baseUrl: "${Config.apiURI}",
    connectTimeout: 5000,
    receiveTimeout: 3000,
    contentType: Headers.formUrlEncodedContentType,
  );
  Dio _dio = Dio(RestRequest._options);

  Future _writeToken(String token) async {
    await SharedPreferences.getInstance().then((pref) async {
      pref.setString("TOKEN", token);
    });
  }

  Future<Dio> getDioInstance() async {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: (RequestOptions options) async {
        await SharedPreferences.getInstance().then((pref) async {
          if (!pref.containsKey("TOKEN")) {
            await _refreshToken(options);
            print(options.headers["Authorization"]);
          } else {
            options.headers["Authorization"] =
                "Bearer ${pref.getString("TOKEN")}";
            return options;
          }
        });
      }, onError: (DioError error) async {
        switch (error.type) {
          case DioErrorType.RESPONSE:
            if (error?.response?.statusCode != 401) {
              _dio.reject(error);
            } else {
              _dio.lock();
              RequestOptions options = error?.response?.request;
              print(options.headers["Authorization"]);
              await _refreshToken(options).whenComplete(() async {
                print(options.headers["Authorization"]);
                _dio.unlock();
              }).then((_) async {
                await _dio.request(options.path, options: options);
              }).catchError((error) {
                if (error is DioError) {
                  GlobalState().isAuthorized = false;
                  _dio.resolve({});
                }
              });
            }
            break;
          case DioErrorType.RECEIVE_TIMEOUT:
          case DioErrorType.CONNECT_TIMEOUT:
            print("TIMEOUT ERROR RECEIVE OR CONNECT");
            _dio.resolve({});
            GlobalState().isConnected = false;
            break;
          case DioErrorType.DEFAULT:
            if (error.message.contains("SocketException")) {
              _dio.resolve({});
              GlobalState().isConnected = false;
            } else {
              _dio.reject(error);
            }
            break;
          default:
            print("OTHER");
        }
        _dio.unlock();
      }),
    );
    return _dio;
  }

  Future<dynamic> _refreshToken(RequestOptions options) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    var info = [androidInfo.device, androidInfo.brand,androidInfo.model];
    var deviceid = await ImeiPlugin.getId();
    try {
      _dio.interceptors.requestLock.lock();
      _dio.interceptors.responseLock.lock();
      await Dio(BaseOptions(
        baseUrl: Config.baseURI,
        connectTimeout: 5000,
        receiveTimeout: 3000,
        contentType: Headers.formUrlEncodedContentType,
      )).post("/device", data: {"deviceid": deviceid, "information": info.join(", ")}).then((response) async {
        String token = response.data["token"];
        await this._writeToken(token);
        options.headers["Authorization"] = "Bearer $token";
        return options;
      });
    } catch (error) {
      if (error is DioError && error.type == DioErrorType.RESPONSE) {
        GlobalState().isAuthorized = false;
        return _dio.reject("Device not Authorized by admin");
      } else {
        print(error);
      }
    }
    _dio.interceptors.requestLock.unlock();
    _dio.interceptors.responseLock.unlock();
  }
}
