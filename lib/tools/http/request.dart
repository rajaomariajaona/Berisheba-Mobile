import 'dart:convert';

import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:dio/dio.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          } else {
            options.headers["Authorization"] =
                "Bearer ${pref.getString("TOKEN")}";
            return options;
          }
        });
      }, onError: (DioError error) async {
        if (error?.response?.statusCode != 401) {
          return error.response.data;
        } else {
          RequestOptions options = error?.response?.request;
          await _refreshToken(options).catchError((error) {
            if (error is DioError) {
              GlobalState().isAuthorized = false;
              _dio.resolve({});
            }
          });
        }
      }),
    );
    return _dio;
  }

  Future<dynamic> _refreshToken(RequestOptions options) async {
    try {
      await Dio(BaseOptions(
        baseUrl: Config.baseURI,
        connectTimeout: 5000,
        receiveTimeout: 3000,
        contentType: Headers.formUrlEncodedContentType,
      )).post("/device", data: {"deviceid": await ImeiPlugin.getImei()}).then(
          (response) async {
        String token = response.data["token"];
        await this._writeToken(token);
        options.headers["Authorization"] = "Bearer $token";
        return options;
      });
    } catch (error) {
      if (error is DioError) {
        GlobalState().isAuthorized = false;
        return _dio.reject("Device not Authorized by admin");
      } else {
        print(error);
      }
    }
  }
}
