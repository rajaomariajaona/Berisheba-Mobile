import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class PayerState extends ChangeNotifier {
  int __isLoading = 0;
  int get isLoading => __isLoading;
  set _isLoading(int val) {
    __isLoading = val;
    notifyListeners();
  }

  Map<int, Map<String, dynamic>> _stats = {};
  Map<int, List<Payer>> _payer = {};
  Map<int, Map<String, dynamic>> get statsByIdReservation => _stats;
  Map<int, List<Payer>> get payerByIdReservation => _payer;
  Future fetchData(int idReservation) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      _isLoading = idReservation;
      var response = await _dio.get("/payer/$idReservation");
      _stats[idReservation] = response.data["stats"];
      _payer[idReservation] = [];
      (response.data["data"] as List<dynamic>).forEach((dynamic item) {
        _payer[idReservation].add(Payer(
            idReservation: idReservation,
            sommePayee: item["sommePayee"] + 0.0,
            typePaiement: item["paiementTypePaiement"]["typePaiement"]));
      });
      notifyListeners();
      _isLoading = 0;
      return true;
    } catch (error) {
      print(error);
      _isLoading = 0;
      return false;
    }
  }

  static Future<bool> saveData(dynamic data, {@required idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.post("/payer/$idReservation", data: data);
      _refresh(idReservation);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> modifyData(dynamic data,
      {@required idReservation, @required typePaiement}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.put("/payer/$idReservation/$typePaiement", data: data);
      _refresh(idReservation);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> removeData(
      {@required typePaiement, @required idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.delete("/payer/$idReservation/$typePaiement");
      _refresh(idReservation);
      return true;
    } catch (error) {
      print(error);
      print(error?.response?.data);
      return false;
    }
  }

  static void _refresh(int idReservation) {
    GlobalState().channel.sink.add("payer $idReservation");
  }

  PayerState() {
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg.contains("payer") ||
          msg.contains("jirama") ||
          msg.contains("autres") ||
          msg.contains("constituer")) {
        if (_payer.containsKey(int.parse(msg.split(" ")[1])))
          await this.fetchData(int.parse(msg.split(" ")[1]));
      }
    });
  }
}

class Payer {
  final String typePaiement;
  final double sommePayee;
  final int idReservation;
  const Payer(
      {@required this.typePaiement,
      @required this.sommePayee,
      @required this.idReservation});

  bool operator ==(payer) =>
      payer is Payer &&
      payer.typePaiement == typePaiement &&
      payer.idReservation == idReservation;
  int get hashCode => typePaiement.hashCode ^ idReservation.hashCode;
}
