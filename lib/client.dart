
import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'package:http/http.dart' as http;

part "client.g.dart";

class Client = _Client with _$Client;

abstract class _Client with Store{
  @observable
    Map<String, dynamic> clients;
  @action
    Future<void> getClient() async{
      clients = await json.decode((await http.get("http://192.168.43.63:3000/api/clients")).body);
  }
}