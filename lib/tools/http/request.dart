import 'dart:convert';
import 'dart:io';

import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ResponseType { ok, error, authorization }

class RestRequest {
  Map<String, dynamic> getData({@required url}){
    http.get(url);
    return null;
  }
}